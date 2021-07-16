/*
created on 28/06/2021
Zyy Zhou(22670661)
This module is for the ELEC5552 design2 fir filter design
to divide the system clock and generate a 12.5 Hz output to the lcd_driver module
*/

module clk_div (
	input         sys_clk,
	input         sys_rst,
	
	output   reg  lcd_pclk
);

//parameter define

//reg define
reg        lcd_clk_25;  //divide the sys_clk and get a 25MHz signal
//wire define

//**************************************************************************
//                      main code
//**************************************************************************
always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)
		lcd_clk_25 <= 1'b0;
	else
		lcd_clk_25 <= ~lcd_clk_25;
end

always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)
		lcd_pclk <= 1'd0;
	else if (lcd_clk_25)
		lcd_pclk <= ~lcd_pclk;
	else
		lcd_pclk <= lcd_pclk;
end

endmodule
