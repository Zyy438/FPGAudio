/*
10/7/2021
Zyy Zhou (22670661)
a module to control the data flow between the lcd display and the fft. it will firstly receive the signal 
of the modulus value(fft_data) (fft_sop,fft_eop,fft_valid) then use two state machines to manage the data
flow between the lcd display and the fft
*/
module lcd_fifo_ctrl(
	input            sys_clk,
	input            sys_rst,
	input            lcd_clk,
	//signals coming from the fft module
	input    [15:0]  fft_data,
	input            fft_sop,
	input            fft_eop,
	input            fft_valid,
	//signals connect to the lcd_show
	input            data_req,
	input            wr_over,
	output reg [6:0] rd_cnt,    //signal counting which one it is in a data segment
	//signals connect to the fifo
	output   [15:0]  fifo_wr_data,   //data signal, just the input fft_data,modulus value
	output           fifo_wr_req,    //write request
	output reg       fifo_rd_req     //request for reading
); 

//parameter define
parameter  TRANSFORM_LENGTH = 128;

//reg define
reg [1:0]    wr_state;       //indicate the state of the write action, totally 3 states
reg [1:0]    rd_state;       //indicate the state of the read action,totally 3 states.
reg [6:0]    wr_cnt;         //count how many data written
reg          wr_en;          //write enable,pulled high to enable the fifo_wr_req signal
reg          fft_valid_r;
reg [15:0]   fft_data_r;     //temporary registers to store the data

//wire define

//***************************************************************************************
//                 main code
//***************************************************************************************
//signals to send write request to the fifo and the data
//if the fft is valid and the fft_sop signal is high, fifo_wr_request will become high
assign fifo_wr_req = fft_valid_r && wr_en;
assign fifo_wr_data = fft_data_r;
//delay the data for a period! then assign them to the outptu fifo_wr_req and fifo_wr_data
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst)begin
		fft_data_r <= 16'd0;
		fft_valid_r <= 1'd0;
	end
	else begin
		fft_data_r <= fft_data;
		fft_valid_r <= fft_valid;
	end
end

always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		wr_state <= 2'd0;  //go to the initiate state if reset button pressed
		wr_en <= 1'd0;
		wr_cnt <= 7'd0;
	end
	else begin
		case (wr_state)
			2'd0: begin
				if(fft_sop) begin  //if it is the start of a data segment
					wr_state <=2'd1; //go to next write state
					wr_en <= 1'b1;
				end
				else begin
				wr_state <= 2'd0;
				wr_en <= 1'b0;
				end
			end
			
			2'd1: begin
				if(fifo_wr_req)      //if we are still sending request, then keep counting
					wr_cnt <= wr_cnt + 1'b1;
				else 
					wr_cnt <= wr_cnt;
				
				if(wr_cnt < TRANSFORM_LENGTH/2-1'b1)begin  //we just need half of the data since its symetric
					wr_en <= 1'b1;    //keep sending request if its not half of the data\
					wr_state <= 2'd1; //stay in this state,its not over!
				end
				else begin
					wr_en <= 1'b0;    //stop requesting writting data if all data are written
					wr_state <= 2'd2; //its over, go to next state
				end
			end
			2'd2: begin
				if((rd_cnt == TRANSFORM_LENGTH/4)&&wr_over) begin //if half of the length is read
					wr_cnt <= 7'd0;
					wr_state <= 2'd0;  //reset and wait for the next frame
				end
				else
					wr_state <= 2'd2;
			end
			default: wr_state <=2'd0;
		endcase
	end
end


always @(posedge lcd_clk or negedge sys_rst) begin //read part, notice its input clk is lcd clk now!
	if(!sys_rst)begin
		rd_state <= 2'd0;
		rd_cnt <= 7'd0;
		fifo_rd_req <= 1'b0;
	end
	else begin
		case (rd_state)
			2'd0: begin  //if it is the first state(initialed)
				if (data_req) begin  //if there is a requirement for data
					fifo_rd_req <= 1'b1;
					rd_state <= 2'd1; //go to next state
				end
				else begin 
					fifo_rd_req <= 1'b0; 
					rd_state <= 2'd0;
				end
			end
			2'd1: begin
				fifo_rd_req <= 1'b0; //just pull read request for one clk period
				rd_state <= 2'd2;
			end
			2'd2:begin	
				if(wr_over)begin
					rd_state <=2'd0;
					if (rd_cnt == TRANSFORM_LENGTH/2-1)
						rd_cnt <= 7'd0;
					else 
						rd_cnt <= rd_cnt +1'b1;
				end
				else
					rd_state <= 2'd2;
				end
				default: rd_state <= 2'd0;
		endcase
	end
end
endmodule


