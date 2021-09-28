/*
written by Zyy Zhou(22670661)
used for ELEC5552 design project
data selection, monitor the signal input from uart module and then decide the output signal
*/
module signal_sel(
	input           sys_clk,
	input           sys_rst,
	//data input from two signal generators
	input   [7:0]   signal_high,
	input   [7:0]   signal_low,
	//input from uart
	input           uart_en,
	input   [7:0]   uart_data,
	//data output
	output  [7:0]   data_out
);


//reg define
reg                uart_en_edge1;
reg                uart_en_edge2;
reg	  [7:0]      uart_data_reg;
reg	  [7:0]      data_out_reg;
//wire define
wire               uart_en_ris;

//***********************************************************
//                main  code
//***********************************************************
assign uart_en_ris = (uart_en_edge1==1 && uart_en_edge2==0)? 1'b1:1'b0;
assign data_out = data_out_reg;

//delay the rise edge detection signal
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst)begin
   uart_en_edge1 <= 1'b0;
	uart_en_edge2 <= 1'b0;
	end
	else begin
	uart_en_edge1 <= uart_en;
	uart_en_edge2 <= uart_en_edge1;
	end
end

//at rising edge of the uart_en   load the uart data
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst) begin
		uart_data_reg <= 8'b0000_0000;
	end
	else if (uart_en_ris == 1'b1) begin
		uart_data_reg <= uart_data;
	end
	else begin
		uart_data_reg <= uart_data_reg;
	end
end

//check the uart data and decide with input to be the output signal
always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)begin
		data_out_reg <= signal_low;
	end
	else if (uart_data_reg != 8'b0000_0000)begin
		data_out_reg <= signal_high;
	end
	else begin
		data_out_reg <= signal_low;
	end
end

endmodule
