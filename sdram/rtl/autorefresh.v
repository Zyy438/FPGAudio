/*
written by Zyy Zhou(22670661) UWA
used for ELEC 5552 design unit project 4 fir filter design
autorefresh module for sdram to keep the data in capacitors
for every 64ms all units need to be refreshed. (15us between each refreshing process)
*/

module  autorefresh (
	//system input signals
	input                             sys_clk,
	input                             sys_rst,
	//communication with top level entity (arbit)
	input                             ref_en,
	output   wire                     ref_req,
	output    reg                     ref_end_flag,
	//output to the port and communicate with sdram chip
	output    reg        [3:0]        ref_cmd,
	output    wire      [11:0]        ref_addr,
	//communication bewteen this module and the initiallization module(it shall send autofresh request after initiallization completed
	input                             init_end_flag
);

//===========================================================================
//                      parameter define
//===========================================================================
//parameter define
localparam              DELAY_15US = 10'd750;
localparam              CMD_AUTOREFRESH = 4'b0001;
localparam              CMD_NOP = 4'b0111;
localparam              CMD_PRECHARGE = 4'b0010;

//reg define
reg         [3:0]       cmd_cnt;
reg         [9:0]       ref_cnt;
reg                     flag_ref;
//wire define



//===========================================================================
//                          main code
//===========================================================================
assign  ref_req = (ref_cnt >= DELAY_15US)? 1'b1: 1'b0;
assign  ref_addr = 12'b 0100_0000_0000;

//a counter to count how many clk period has passed. for every 15us an autorefresh request will be sent after initiallization
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		ref_cnt <= 10'd0;
	end
	else if (ref_cnt >= DELAY_15US)begin
		ref_cnt <= 10'd0;
	end
	else if (init_end_flag == 1'b1)begin
		ref_cnt <= ref_cnt + 1;
	end
	//maybe delete this else structure? or let ref_cnt <= ref_cnt?
	else begin
		ref_cnt <= 10'd0;
	end
	//maybe delete this else structure? or let ref_cnt <= ref_cnt?
end

//define a flag signal and indicates that the chip is being refreshed when the signal is 1
//when the ref_end_flag is 1 then the refreshing procedure is stopped then set the signal as 0
//the refreshing precedure needs to be engaged by the ref_en signal
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst) begin
		flag_ref <= 1'b0;
	end
	else if(ref_end_flag == 1'b1)begin   //after initiallization 
		flag_ref <= 1'b0;
	end
	else if(ref_en == 1'b1) begin
		flag_ref <= 1'b1;
	end
	else begin
		flag_ref <= 1'b0;
	end
end

//set a counter to count how many clks are passed after working procedure intiallized.
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		cmd_cnt <= 4'd0;
	end
	else if(flag_ref == 1'b1) begin
		cmd_cnt <= cmd_cnt + 1;
	end
	else begin
		cmd_cnt <= 4'd0;
	end
end

//output different instructions in different cmd_cnt periods to implement a complete refreshing procedure
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		ref_cmd <= 4'b0;
	end
	else
	case (cmd_cnt)
		4'd1:    ref_cmd <= CMD_PRECHARGE;
		4'd2:    ref_cmd <= CMD_AUTOREFRESH;
		default: ref_cmd <= CMD_NOP;
	endcase
end

endmodule
