/*
11/7/2021
Zyy Zhou (22670661)
this module is the top entity of the lcd part. used for ELEC5552 design2 project. 
this module receives data coming from the fft module (the modulus value of the fourier transformed data), as well as
the sop, eop and data_valid signal. then it will communicate with the lcd and display the length of the modulus value. thus
show the magnitude of the spectrum of the input audio in specific frequency index
*/
module lcd_top(
	input                    sys_clk,
	input                    sys_rst,
	//signals coming from the fft module.
	input       [15:0]       fft_data,
	input                    fft_sop,
	input                    fft_eop,
	input                    fft_valid,
	//signals going to the lcd
	output                    lcd_hs,
	output                    lcd_vs,
	output                    lcd_de,
	output      [15:0]        lcd_rgb,
	output                    lcd_bl,
	output                    lcd_rst,
	output                    lcd_pclk
);

//parameter define


//reg define


//wire define
//the output of the clk divide module, synchronization clk of the lcd module
wire             lcd_clk;
wire    [10:0]   pixel_x;
wire    [10:0]   pixel_y;
wire             fifo_empty;
wire    [6:0]    line_cnt;
wire             wr_over;
wire             data_req;
wire    [15:0]   pixel_data;
wire    [15:0]   fifo_wr_data;
wire             fifo_wr_req;
wire             fifo_rd_req;
wire    [15:0]   line_length;

//******************************************************************************************8
//                            main code
//********************************************************************************************

clk_div u_clk_div(
	.sys_clk            (sys_clk),
	.sys_rst            (sys_rst),
	//output 12.5Hz clk signal
	.lcd_pclk           (lcd_clk)
);

lcd_fifo_ctrl u_fifo_ctrl(
	.sys_clk            (sys_clk),
	.sys_rst            (sys_rst),
	.lcd_clk            (lcd_clk),  //clk signal coming from the clk-div module, 12.5KHz
	//signal coming from the fft module
	.fft_data           (fft_data),
	.fft_eop            (fft_eop),
	.fft_sop            (fft_sop),
	.fft_valid          (fft_valid),
	//signal connecting to the lcd_show
	.data_req           (data_req),
	.wr_over            (wr_over),
	.rd_cnt             (line_cnt),
	//signal connect to the fifo
	.fifo_wr_data       (fifo_wr_data),
	.fifo_wr_req        (fifo_wr_req),
	.fifo_rd_req        (fifo_rd_req)
);

lcd_driver u_lcd_driver(
	.lcd_pclk           (lcd_clk),//this is input signal here, check in the lcd_driver module
										   //the module's output clk signal to the lcd_display is lcd_clk
	.sys_rst            (sys_rst),
	//input coming from the lcd display
	.pixel_data         (pixel_data),
	//output to the lcd monitor
	.lcd_de             (lcd_de),
	.lcd_vs             (lcd_vs),
	.lcd_hs             (lcd_hs),
	.lcd_bl             (lcd_bl),
	.lcd_clk            (lcd_pclk),  //the output signal of the module, check in the lcd_driver
	.lcd_rgb            (lcd_rgb),
	.lcd_rst            (lcd_rst),
	.h_res              (),
	.v_res              (),//no need to tell the lcd_display module what the resolution is
	.pixel_x            (pixel_x),
	.pixel_y            (pixel_y)
);

lcd_display u_lcd_display(
	.lcd_clk            (lcd_clk),
	.sys_rst            (sys_rst&(~fifo_empty)),
	//signals coming from the the lcd_driver, indicating the position of the current pixel
	.pixel_xpos         (pixel_x),
	.pixel_ypos         (pixel_y),
	//signal coming from the fifo as well as lcd_fifo_ctrl
	.line_cnt           (line_cnt),
	.line_length        (line_length),
	//outputs
	.wr_over            (wr_over),
	.data_req           (data_req),
	.lcd_data           (pixel_data)
);

fifo u_fifo(
	.aclr               (~sys_rst),
	.data               (fifo_wr_data),
	.wrreq              (fifo_wr_req),
	.rdreq              (fifo_rd_req),
	.wrclk              (sys_clk),
	.rdclk              (lcd_clk),
	//output 
	.q                  (line_length),
	.rdempty            (fifo_empty),
	.wrfull             (),
	.rdusedw            ()
);
endmodule
