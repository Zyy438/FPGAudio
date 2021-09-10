/*
written by Zyy Zhou (22670661)
used for ELEC5552 design 2 project 4 fir filter design
to implement communication between FPGA and sdram (not ddr), there should be an initialization process after releasing the reset
button. 

There should be basically 4 stages to complete the initialization:
step1: wait for 200us and do nothing to initialize internal elements inside the sdram.
step2: precharge the column wire into Vmm/2 for every storage unit
step3: refresh the storage unit and wait for 4 clk periods and then refresh the storage unit again and wait for 4 more clk periods
step4: assign signals to registers in the sdram to set the working mode
After completing all these stages then pull the init_end_flag signal high to indicate that the initialization is done
*/

module init (
	//system signals
	input                        sys_clk,     //50MHz, duration 20ns
	input                        sys_rst,
	//output signals
	output      reg   [3:0]      cmd_reg,
	output      reg  [11:0]      sdram_addr,
	output      reg              init_end_flag
	

);

// parameter define
//to initialize the sdram, 200us delay should be satisfied after the reset button is relased. 200us/20ns=10000 clk periods
localparam    delay_200_us = 14'd10000;
//commands to initialize the sdram (check the manual of the sdram chip. type used in this project:hy57v281620ftp)
localparam    NOP = 4'b0111;
localparam    PRECHARGE = 4'b0010;             //pre charge
localparam    AUTO_REFRESH = 4'b0001;          //auto refresh
localparam    MODSELECT = 4'b0000;             //mod selection


// reg define
reg           [3:0]             cnt_cmd;
reg           [13:0]            count_200_us;

//wire define
wire                            flag_200us;

//**********************************************************************
//                        main code
//**********************************************************************
//if 1000 clk periods are reached, then rise flag_200us signal to indicate that the delay is reached.
assign    flag_200us = (count_200_us <= 14'd10000) ? 1'b0 : 1'b1;
//increase the count_200_us signal by 1 after releasing the reset button for 10000 times
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		count_200_us <= 14'd0;
	end
	else if(count_200_us < 14'd10000) begin
		count_200_us <= count_200_us + 1;
	end
	else begin
		count_200_us <= 0;
	end
end

//when 200us is passed, start counting the clk period again.
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		cnt_cmd <= 4'd0;
	end
	else if (flag_200us == 1'b1 && init_end_flag == 1'b0) begin
		cnt_cmd <= cnt_cmd + 1;
	end
	else begin
		cnt_cmd <= 4'd0;
	end
end

//after 200us, output commands accordingly at different clk period.
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		cmd_reg <= NOP;
	end
	else if (flag_200us == 1'b1) begin
		case (cnt_cmd)
			0: cmd_reg <= PRECHARGE;
			1: cmd_reg <= AUTO_REFRESH;
			5: cmd_reg <= AUTO_REFRESH;
			9: cmd_reg <= MODSELECT;
		default: cmd_reg <= NOP;
		endcase
	end
	else begin
		cmd_reg <= NOP;
	end
end

//the output address will have different values when different instructions are executed.
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst) begin
		sdram_addr <= 12'b0;
	end
	else if (flag_200us ==1'b1) begin  //200us latency reached
		case (cnt_cmd)
		0: sdram_addr <= 12'b0100_0000_0000;
		9: sdram_addr <= 12'b0000_0011_0010;
		endcase
	end
	else begin
		sdram_addr <= 12'b0100_0000_0000;
	end
end

endmodule


