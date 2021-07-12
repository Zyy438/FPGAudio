/*
created on 28/06/2021
Zyy Zhou(22670661)
This module is for the ELEC5552 design2 fir filter design
to enable the LCD screen. mainly confirm the position of the current pixel
*/

module lcd_driver(
	input                     lcd_pclk, //clk signal for the lcd
	input                     sys_rst,
	input         [15:0]      pixel_data,
	
	//connect to RGB LCD input
	output         [10:0]      pixel_x,  //position of pixel on x axis
	output         [10:0]      pixel_y,  //position of pixel on y axis
	output         [10:0]      h_res, //screen's resolution on x axis, give it to the data_r module
	output         [10:0]      v_res, //screen's resolution on y axis
	output                     lcd_de, //data enabled
	output                     lcd_hs, //next_raw
	output                     lcd_vs, //next frame
	output   reg               lcd_bl, //light or not
	output                     lcd_clk, //clk signal for the lcd
	output         [15:0]      lcd_rgb, //RGB data, indicate the color for each pixel
	output   reg               lcd_rst 
);

//parameter define
/*
the screen used in this project is ALIENTEK LCD 4.3 resolution 480*272
there will be delays before and after the transmission of every raw and frame. Also, the
signal indicating next raw and frame will take time as well.
different screens have different such delays. below shows the parameters for the screen used.
*/
//transmission for a raw
parameter H_SYNC = 11'd41;  //raw syn
parameter H_BACK = 11'd2;   //after raw syn
parameter H_DISP = 11'd480; //data time
parameter H_FRONT = 11'd2;  //delay after data ends
parameter H_TOTAL = 11'd525;//period of a raw    525clk need for a raw
//transmission for a frame
parameter V_SYNC = 11'd10;  //frame syn
parameter V_BACK = 11'd2;   //after frame syn
parameter V_DISP = 11'd272; //data time
parameter V_FRONT = 11'd2;  //after data ends
parameter V_TOTAL = 11'd286;//period of a frame  286 raw period for a frame

//reg define
//reg     [10:0]     h_sync;
//reg     [10:0]     h_back;
//reg     [10:0]     h_total;   //total clk period needed for a raw
reg     [10:0]     h_cnt;     //used to count which pixel we are in a raw at the moment
//reg     [10:0]     v_sync;
//reg     [10:0]     v_back;
//reg     [10:0]     v_total;   //total clk period needed for a frame
reg     [10:0]     v_cnt;     //used to count which raw it is at the moment

//wire define
wire               lcd_en;     
wire               data_req;  

//*******************************************************************
//               main  code
//*******************************************************************
assign      v_res = V_DISP;  //resolution (for a vector)equals the clk period of the data time
assign      h_res = H_DISP;  //resolution for a raw
assign      lcd_hs = 1'b1;   //these two signals shall always be high 
assign      lcd_vs = 1'b1;   //according to the time analysis pic in 'README.md'

assign      lcd_clk = lcd_pclk; //output clk is just the input clk, synchronized
assign      lcd_de = lcd_en;    //indicating that the data is being sent
										  //enabled when it comes to the clk periods transmitting data

//if it is in the data transmission time within a raw and within a frame, then lcd_en pulls high
//indicating the data is being transmitted
//data transmission start from H_SYNV+H_BACK and cost H_DISP clk period
//the same for a frame. these requiurement must be satisfied at same time
assign      lcd_en = ((h_cnt >= H_SYNC+H_BACK) && (h_cnt < H_SYNC+H_BACK+H_DISP)
							&& (v_cnt >= V_SYNC+V_BACK) && (v_cnt < V_SYNC+V_BACK+V_DISP))
							? 1'b1 : 1'b0;
//request data 1 clk period before the data transmission begins. so that the 
//data will already be there as long as transmission begins
assign      data_req = ((h_cnt >= H_SYNC+H_BACK) && (h_cnt < H_SYNC+H_BACK+H_DISP)
							&& (v_cnt >= V_SYNC+V_BACK) && (v_cnt < V_SYNC+V_BACK+V_DISP))
							? 1'b1 : 1'b0;
//the position of the pixel, should take out the delay time 
assign      pixel_x = data_req ? (h_cnt-(H_SYNC+H_BACK-1'b1)):11'd0;
assign      pixel_y = data_req ? (v_cnt-(V_SYNC+V_BACK-1'b1)):11'd0;

//if in the data transmission time then send the input rgb data to the screen
assign      lcd_rgb = lcd_en ? pixel_data : 16'd0;

//count which pixel it is in a raw
always @(posedge lcd_pclk or negedge sys_rst) begin //we are driven not by system clk this time
	if (!sys_rst)
		h_cnt <= 11'd0;           //reset the pixel counter
	else if (h_cnt == H_TOTAL-1) //if it is the end of a raw
		h_cnt <= 11'd0;
	else
		h_cnt <= h_cnt+1;         //else go to next pixel of the raw
end

//count which raw it is in a frame at the moment
always @(posedge lcd_pclk or negedge sys_rst) begin
	if (!sys_rst)
		v_cnt <= 11'd0;            //reset the raw counter
	else if (h_cnt == H_TOTAL-1) begin //if it comes to the last pixel of the raw
		if (v_cnt == V_TOTAL-1)    //if it is the last raw period of a frame
			v_cnt <= 11'd0;         //go to next frame and reset the raw counter
		else 
			v_cnt <= v_cnt+1;       //else go to next raw
	end  
	else
		v_cnt <= v_cnt;            //stay in this raw if its not the last pixel
end
/*
so now we can know which pixel in a raw and which raw we are at the moment thus we know the 
position of the pixel in x and y axis. the position moves from the first pixel to the last pixel
of the first raw, then go to next raw and moves from the first pixel to the last pixel of the
second raw... when it comes next frame, move back to the first raw.
*/

always @(posedge lcd_pclk or negedge sys_rst) begin
	if (!sys_rst) begin //if press the reset button turn off the light as well
		lcd_rst <= 1'b0;
		lcd_bl <= 1'b0; //control the light of the screen. if low then turn off the light
	end
	else begin
		lcd_rst <= 1'b1;
		lcd_bl <= 1'b1;
	end
end

endmodule
