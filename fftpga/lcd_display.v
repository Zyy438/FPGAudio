/*
10/7/2021
Zyy ZHou(22670661)
this module is to get the modulus of the audio signal in frequency domain and thus represent it in 
the lcd display
*/
module lcd_display(
	input                lcd_clk,  //lcd clock signal
	input                sys_rst, 
	
	input     [10:0]     pixel_xpos,  //pixel position on x axis
	input     [10:0]     pixel_ypos,  //pixel position on y axis
	
	input     [6:0]      line_cnt,   //indicating which line in the lcd it should be 
	input     [15:0]     line_length, //the length of the line, coming fromt the fft module, the 
												//modulus value
	output               data_req,
	output               wr_over,    //a frame is written over
	output    [15:0]     lcd_data    //pixel color, RGB565, 16bits
);

//parameter define
parameter H_LCD_DISP = 11'd480;        //480 raws
localparam BLACK = 16'b00000_000000_00000;
localparam WHITE = 16'b11111_111111_11111;

//reg define

//wire define

//***********************************************************************
//             main code
//***********************************************************************

//request for a pixel data
assign data_req = ((pixel_ypos == line_cnt * 4'd4 + 4'd8 - 4'd1) &&(pixel_xpos == H_LCD_DISP - 1))?1'b1:1'b0;
//the module will request for a pixel data if it is in a display region. note that the line is because we divide the 272 rows into 64 segments. so 
//there will be around 4 raws to show the magnitude of a frequency index. THus there will be 16 rows
//not showing anything. to make the image in the middle, the lcd will start to show the magnitude of the first 
//index of a frame in the 8th row.

assign lcd_data = ((pixel_ypos == line_cnt * 4'd4 + 4'd8 - 4'd1) &&(pixel_xpos <= line_length))?WHITE:BLACK;
//if the pixel's x position is smaller than the magniture, then the lcd_data in this pixel will be white

assign wr_over = ((pixel_ypos == line_cnt * 4'd4 + 4'd8) &&(pixel_xpos == H_LCD_DISP - 1))?1'b1:1'b0;
//if a frame is finished, it will let line_cnt increase 1

endmodule
