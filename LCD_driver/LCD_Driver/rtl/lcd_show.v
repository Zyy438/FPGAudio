module lcd_show (
	input                  sys_clk,
	input                  sys_rst,
	input       [10:0]     pixel_x,       //get the current pixel location
	input       [10:0]     pixel_y,       //get the current pixel location
	input       [10:0]     h_res,         //receive the resolution
	input       [10:0]     v_res,
	
	output  reg [15:0]     pixel_data
);

//parameter define
parameter WHITE = 16'b11111_111111_11111;
parameter BLACK = 16'b00000_000000_00000;
parameter RED   = 16'b11111_000000_00000;
parameter GREEN = 16'b00000_111111_00000;
parameter BLUE  = 16'b00000_000000_11111;
//in a frame of rgb signal, red accounts first 5 bits, 
//green accounts middle6 bits, blue accounts last 5 bits

//reg define

//wire define

//*************************************************************************
//                    main   code
//*************************************************************************
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst)
		pixel_data <= 16'b0;  //if rst then black
	else begin
		if ((pixel_x >= 11'd0)&&(pixel_x < h_res/5*1))  //divide a raw as 5 part, the first part is white
			pixel_data <= WHITE;
		else if ((pixel_x >= h_res/5*1)&&(pixel_x < h_res/5*2))  //second part
			pixel_data <= BLACK;
		else if ((pixel_x >= h_res/5*2)&&(pixel_x < h_res/5*3))  //second part
			pixel_data <= RED;
		else if ((pixel_x >= h_res/5*3)&&(pixel_x < h_res/5*4))  //second part
			pixel_data <= GREEN;
		else
			pixel_data <= BLUE;
		end
end
endmodule
