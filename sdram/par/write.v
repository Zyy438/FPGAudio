/*
Zyy Zhou (22670661)
write module of sdram, used for ELEC5552 design2 unit project 4 fir filter
this module is working in a form of finite state machine, 
it will be excited from the idle state by write_en signal
there situations will end the writing state:
1. the data has been completly written
2. need to refresh the memory units
3. a row has been fullt written, and need to jump to the next row
*/

module write (
	//system input signals 
	input                             sys_clk,
	input                             sys_rst,
	//communication between the module and the top level entity
	input                             write_en,  //coming from the arbit(top level entity) module and the module will be enabled by this signal
	output   reg                      write_end_flag,
	output   reg                      write_req,   
	//the refresh request will interrupt the writing process
	input                             ref_req,
	//interface to the sdram port
	output   reg    [3:0]             wr_cmd,
	output   reg    [11:0]            wr_addr,
	output   wire   [1:0]             wr_bank_addr,
	//interface to the data input port
	input                             wr_trigger   //trigger signal indicating that a data is coming in and need to be written
);


//========================================================================================
//                          parameter define
//========================================================================================
//----------------------------------parameter define------------------------------------------
//defining states of the writing module
localparam          IDLE = 3'b000;
localparam          WR_REQ = 3'b001;
localparam          WR_ACT = 3'b010;
localparam          WR_WR = 3'b011;
localparam          WR_PRECHARGE = 3'b100;  //after writing the sdram needs precharge and it will automatically turn to idle state
//defining the command used in this module
localparam          CMD_NOP = 4'b0111;
localparam          CMD_PRECHARGE = 4'b0010;
localparam          CMD_AREF = 4'b0001;
localparam          CMD_ACT = 4'b0011;
localparam          CMD_WR = 4'b0100;



//-------------------------------------reg define----------------------------------------------
reg                  [2:0]             wr_state;
reg                                    wr_flag;
//internal reg parameters  (write end flag is an output signal not internal but data_end is)
reg                                    precharge_end_flag;
reg                                    act_end_flag;
reg                                    sd_row_end;
reg                  [1:0]             burst_cnt;
reg                  [1:0]             burst_cnt_t;
reg                                    data_end_flag;  //indicating that a data has been fully written
//coutner
reg                  [3:0]             act_cnt;
reg                  [3:0]             break_cnt;
reg                  [6:0]             col_cnt;
reg                  [11:0]            row_addr;

//------------------------------------wire define----------------------------------------------
wire                 [8:0]             col_addr; //it is a combination of the column address and the burst cnt

//========================================================================================
//                                main code
//========================================================================================
//the column address is the input column cnt (9 bits) combined with the burst address
assign col_addr = {col_cnt + burst_cnt_t};
assign wr_bank_addr = 2'b00;

//writing flag signal, indicating that the writing process is ongoing. exited by wr_trigger signal.
always @(posedge sys_clk or sys_rst)begin
	if(!sys_rst)begin
		wr_flag <= 1'b0;
	end
	else if(wr_trigger == 1'b1 && wr_flag == 1'b0)begin //have to wait for every data being fully written (burst)
		wr_flag <= 1'b1;
	end
	else if(write_end_flag == 1'b1)begin
		wr_flag <= 1'b0;
	end
end

//act count signal, start counting after the act procedure is started
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		act_cnt <= 4'b0;
	end
	else if(wr_state == WR_ACT)begin
		act_cnt <= act_cnt + 1'b1;
	end
	else begin
		act_cnt <= 4'b0;
	end
end	

//act flag signal, indicating that a row has been successfully actived.
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		act_end_flag <= 1'b0;
	end
	else if (act_cnt == 'd3)begin
		act_end_flag <= 1'b1;
	end
	else begin
		act_end_flag <= 1'b0;
	end
end

//break count signal, enabled at precharge state
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		break_cnt <= 4'b0;
	end
	else if(wr_state == WR_PRECHARGE)begin
		break_cnt <= break_cnt + 1'b1;
	end
	else begin
		break_cnt <= 4'b0;
	end
end	

//precharge end flag signal, indicating that a precharge process is done
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		precharge_end_flag <= 1'b0;
	end
	else if (break_cnt == 'd3)begin
		precharge_end_flag <= 1'b1;
	end
	else begin
		precharge_end_flag <= 1'b0;
	end
end

//burst count signal, enabled at WR state
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		burst_cnt <= 2'b0;
	end
	else if(wr_state == WR_WR)begin
		burst_cnt <= burst_cnt + 1'b1;
	end
	else begin
		burst_cnt <= 2'b0;
	end
end	

//burst_cnt_t is a delayed version of burst_cnt signal
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		burst_cnt_t <= 2'b0;
	end
	else begin
		burst_cnt_t <= burst_cnt;
	end
end

//write data end flag, 9 bit => 512 numbers
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst)begin
		data_end_flag <= 1'b0;
	end
	else if(row_addr == 'd1 && col_addr == 9'd511)begin
		data_end_flag <= 1'b1;
	end
	else begin
		data_end_flag <= 1'b0;
	end
end

//column counter, plus 1 if a burst write process is done
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst)begin
		col_cnt <= 'd0;
	end
	else if (col_addr == 9'd511) begin
		col_cnt <= 'd0;
	end
	else if (burst_cnt == 2'd3) begin
		col_cnt <= col_cnt + 1'b1;
	end
	else begin
		col_cnt <= col_cnt;
	end
end

//defining the row address
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_clk)begin
		row_addr <= 12'b0;
	end
	else if (sd_row_end)begin
		row_addr <= row_addr + 1'b1;
	end
	else begin
		row_addr <= row_addr;
	end
end

//-------------------------------writing command--------------------------------------------
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst)begin
		wr_cmd <= CMD_NOP;
	end
	else 
	case (wr_state)
		WR_ACT:
			if(act_cnt == 4'd0)begin
				wr_cmd <= CMD_ACT;
			end
			else begin
				wr_cmd <= CMD_NOP;
			end
		WR_WR:
			if(burst_cnt == 'd0)begin
				wr_cmd <= CMD_WR;
			end
			else begin
				wr_cmd <= CMD_NOP;
			end
		WR_PRECHARGE:
			if(break_cnt == 'd0)begin
				wr_cmd <= CMD_PRECHARGE;
			end
			else begin
				wr_cmd <= CMD_NOP;
			end
	default:wr_cmd <= CMD_NOP;
	endcase
end

//-------------------------------writing address--------------------------------------------
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst)begin
		wr_addr <= 12'd0;
	end
	else 
	case(wr_state)
		WR_ACT:
			if(act_cnt == 'd0) begin
				wr_addr <= row_addr;
			end
			else begin
				wr_addr <= wr_addr;
			end
		WR_WR:
				wr_addr <= {3'b010, col_addr};
		WR_PRECHARGE:
			if(break_cnt == 'd0)begin
				wr_addr <= 12'b0100_0000_0000;
			end
	default:wr_addr <= wr_addr;
	endcase
end

//-----------------------------Finite state machine-----------------------------------------
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		wr_state <= IDLE;
	end
	else 
	case (wr_state)
		IDLE:
			if(wr_trigger == 1'b1) begin  //if there is a need for writing, then request for a write(go to arbit module
				wr_state <= WR_REQ;
			end
			else begin
				wr_state <= IDLE;
			end
		WR_REQ:
			if(write_en == 1'b1) begin
				wr_state <= WR_ACT;
			end
			else begin
				wr_state <= WR_REQ;
			end
		WR_ACT:
			if(act_end_flag == 1'b1) begin  //if finish activing the rows then go the write state
				wr_state <= WR_WR;
			end
			else begin
				wr_state <= WR_ACT;
			end
		WR_WR:
			if(data_end_flag == 1'b1) begin
				wr_state <= WR_PRECHARGE;
			end
			else if (ref_req == 1'b1 && wr_flag == 1'b1 && burst_cnt == 2'd3)begin  //need to wait the burst end then go refresh cause burst cause very short time
				wr_state <= WR_PRECHARGE;
			end
			else if (sd_row_end == 1'b1) begin   //if a row is end we have to end the writing process and active the next row
				wr_state <= WR_PRECHARGE;
			end
			else begin
				wr_state <= WR_WR;
			end	
		WR_PRECHARGE:
			if(ref_req == 1'b1 && wr_flag == 1'b1)begin //if need refreshing while writing data (at this time burst writing is finished)
				wr_state <= WR_REQ;                      //the arbit module will jump to the refresh state and now we just keep sending writing request
			end
			else if (sd_row_end == 1'b1 && wr_flag == 1'b1)begin //writing but it is the last bit of the row
				wr_state <= WR_ACT;                      //jump to the act state and active a new row
			end
			else if (data_end_flag == 1'b1) begin       //when the data is fully written
				wr_state <= IDLE;                        //wait for next write trigger
			end 
	default: wr_state <= IDLE; 
	endcase
end

endmodule
