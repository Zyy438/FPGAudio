/*
Zyy Zhou (22670661)
read module of sdram, used for ELEC5552 design2 unit project 4 fir filter
this module is working in a form of finite state machine, 
*/

module read (
	//system input signals 
	input                             sys_clk,
	input                             sys_rst,
	//communication between the module and the top level entity
	input                             read_en,  //coming from the arbit(top level entity) module and the module will be enabled by this signal
	output   reg                      read_end_flag,
	output   reg                      read_req,   
	//the refresh request will interrupt the rditing process
	input                             ref_req,
	//interface to the sdram port
	output   reg    [3:0]             rd_cmd,
	output   reg    [11:0]            rd_addr,
	output   wire   [1:0]             rd_bank_addr,
	//interface to the data input port
	input                             rd_trigger   //trigger signal indicating that a data is coming in and need to be rditten
	//output   reg    [15:0]            test_data
);


//========================================================================================
//                          parameter define
//========================================================================================
//----------------------------------parameter define------------------------------------------
//defining states of the rditing module
localparam          IDLE = 3'b000;
localparam          RD_REQ = 3'b001;
localparam          RD_ACT = 3'b010;
localparam          RD_RD = 3'b011;
localparam          RD_PRECHARGE = 3'b100;  //after rditing the sdram needs precharge and it will automatically turn to idle state
//defining the command used in this module
localparam          CMD_NOP = 4'b0111;
localparam          CMD_PRECHARGE = 4'b0010;
localparam          CMD_AREF = 4'b0001;
localparam          CMD_ACT = 4'b0011;
localparam          CMD_RD = 4'b0101;



//-------------------------------------reg define----------------------------------------------
reg                  [2:0]             rd_state;
reg                                    rd_flag;
//internal reg parameters  (read end flag is an output signal not internal but data_end is)
reg                                    precharge_end_flag;
reg                                    act_end_flag;
reg                                    sd_row_end;
reg                  [1:0]             burst_cnt;
reg                  [1:0]             burst_cnt_t;
reg                                    data_end_flag;  //indicating that a data has been fully rditten
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
assign rd_bank_addr = 2'b00;

//rditing request signal
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		read_req <= 1'b0;
	end
	else if (rd_trigger == 1'b1 && rd_state != RD_RD)begin
		read_req <= 1'b1;
	end
	else begin
		read_req <= 1'b0;
	end
end

//rditing flag signal, indicating that the rditing process is ongoing. exited by rd_trigger signal.
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		rd_flag <= 1'b0;
	end
	else if(rd_trigger == 1'b1 && rd_flag == 1'b0)begin //have to wait for every data being fully rditten (burst)
		rd_flag <= 1'b1;
	end
	else if(read_end_flag == 1'b1)begin
		rd_flag <= 1'b0;
	end
end

//act count signal, start counting after the act procedure is started
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		act_cnt <= 4'b0;
	end
	else if(rd_state == RD_ACT)begin
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
	else if(rd_state == RD_PRECHARGE)begin
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

//burst count signal, enabled at rd state
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		burst_cnt <= 2'b0;
	end
	else if(rd_state == RD_RD)begin
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

//read data end flag, 9 bit => 512 numbers
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

//column counter, plus 1 if a burst read process is done
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
	if(!sys_rst)begin
		row_addr <= 12'b0;
	end
	else if (sd_row_end)begin
		row_addr <= row_addr + 1'b1;
	end
	else begin
		row_addr <= row_addr;
	end
end

//-------------------------------rditing command--------------------------------------------
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst)begin
		rd_cmd <= CMD_NOP;
	end
	else 
	case (rd_state)
		RD_ACT:
			if(act_cnt == 4'd0)begin
				rd_cmd <= CMD_ACT;
			end
			else begin
				rd_cmd <= CMD_NOP;
			end
		RD_RD:
			if(burst_cnt == 'd0)begin
				rd_cmd <= CMD_RD;
			end
			else begin
				rd_cmd <= CMD_NOP;
			end
		RD_PRECHARGE:
			if(break_cnt == 'd0)begin
				rd_cmd <= CMD_PRECHARGE;
			end
			else begin
				rd_cmd <= CMD_NOP;
			end
	default:rd_cmd <= CMD_NOP;
	endcase
end

//-------------------------------rditing address--------------------------------------------
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst)begin
		rd_addr <= 12'd0;
	end
	else 
	case(rd_state)
		RD_ACT:
			if(act_cnt == 'd0) begin
				rd_addr <= row_addr;
			end
			else begin
				rd_addr <= rd_addr;
			end
		RD_RD:
				rd_addr <= {3'b010, col_addr};
		RD_PRECHARGE:
			if(break_cnt == 'd0)begin
				rd_addr <= 12'b0100_0000_0000;
			end
	default:rd_addr <= rd_addr;
	endcase
end

//-----------------------------Finite state machine-----------------------------------------
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		rd_state <= IDLE;
	end
	else 
	case (rd_state)
		IDLE:
			if(rd_trigger == 1'b1) begin  //if there is a need for rditing, then request for a read(go to arbit module
				rd_state <= RD_REQ;
			end
			else begin
				rd_state <= IDLE;
			end
		RD_REQ:
			if(read_en == 1'b1) begin
				rd_state <= RD_ACT;
			end
			else begin
				rd_state <= RD_REQ;
			end
		RD_ACT:
			if(act_end_flag == 1'b1) begin  //if finish activing the rows then go the read state
				rd_state <= RD_RD;
			end
			else begin
				rd_state <= RD_ACT;
			end
		RD_RD:
			if(data_end_flag == 1'b1) begin
				rd_state <= RD_PRECHARGE;
			end
			else if (ref_req == 1'b1 && rd_flag == 1'b1 && burst_cnt == 2'd3)begin  //need to wait the burst end then go refresh cause burst cause very short time
				rd_state <= RD_PRECHARGE;
			end
			else if (sd_row_end == 1'b1) begin   //if a row is end we have to end the rditing process and active the next row
				rd_state <= RD_PRECHARGE;
			end
			else begin
				rd_state <= RD_RD;
			end	
		RD_PRECHARGE:
			if(ref_req == 1'b1 && rd_flag == 1'b1)begin //if need refreshing while rditing data (at this time burst rditing is finished)
				rd_state <= RD_REQ;                      //the arbit module will jump to the refresh state and now we just keep sending rditing request
			end
			else if (sd_row_end == 1'b1 && rd_flag == 1'b1)begin //rditing but it is the last bit of the row
				rd_state <= RD_ACT;                      //jump to the act state and active a new row
			end
			else if (data_end_flag == 1'b1) begin       //when the data is fully rditten
				rd_state <= IDLE;                        //wait for next read trigger
			end 
	default: rd_state <= IDLE; 
	endcase
end

//------------------------------------------------------------------------------
//                         generate test data
//------------------------------------------------------------------------------
/*
always @(*)begin
	case(burst_cnt_t)
		0: test_data <= 16'd5;
		1: test_data <= 15'd4;
		2: test_data <= 16'd3;
		3:	test_data <= 16'd8;
	default:test_data <= 16'd0;
	endcase
end
*/
endmodule
