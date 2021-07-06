module lcd_dis (
	input               sys_clk,
	input               sys_rst,
	
	output              lcd_de,  //data enable signal
	output              lcd_hs,  //from driver, next raw signal, always 1, dont mind it too much
	output              lcd_vs,  //from driver, next frame signal, always 1, dont mind it
	output              lcd_clk, //output to the lcd interface
	output    [15:0]    lcd_rgb, //main signal
	output              lcd_rst, //synchronized with system rst signal
	output              lcd_bl   //light up the lcd!
);

//parameter define

//reg define

//wire define
wire             lcd_pclk;
wire  [10:0]     pixel_x;
wire  [10:0]     pixel_y;
wire  [10:0]     h_res;
wire  [10:0]     v_res;
wire  [15:0]     pixel_data;  //the rgb data transmitted between modules
wire  [15:0]     lcd_rgb_o;   //the output rgb data. comming from the lcd_driver module.
//wire  [15:0]     led_rgb_i;

//***********************************************************************
//                    main code
//***********************************************************************

assign lcd_rgb = lcd_de ? lcd_rgb_o : {16{1'bz}}; //if sending data then output else high resistor
//assign loc_rgb_i = lcd_rgb;

lcd_driver u_lcd_driver (
	//input signals
	.lcd_pclk             (lcd_pclk),   //divided clk signal from clk_div module
	.sys_rst              (sys_rst),    //shared sys_rst
	.pixel_data           (pixel_data), //rgb data signal comming from lcd_show module
	//output signals
	.pixel_x              (pixel_x),    //indicating the position, tell the lcd_show module
	.pixel_y              (pixel_y),
	.h_res                (h_res),      //send resolution signal to the lcd_show module
	.v_res                (v_res),
	.lcd_de               (lcd_de),     //high level when data is being transmitted
	.lcd_hs               (lcd_hs),
	.lcd_vs               (lcd_vs),
	.lcd_bl               (lcd_bl),
	.lcd_clk              (lcd_clk),
	.lcd_rgb              (lcd_rgb_o), //give the data not directly to the output
	.lcd_rst              (lcd_rst)
);

clk_div u_clk_div (
	//input signals
	.sys_clk              (sys_clk),
	.sys_rst              (sys_rst),
	//output signals
	.lcd_pclk             (lcd_pclk) //give to the lcd_driver and driver give to the output to drive the screen
);

lcd_show u_lcd_show (
	//input signals 
	.sys_clk              (sys_clk),
	.sys_rst              (sys_rst),
	.pixel_x              (pixel_x), //position of the pixel, comming from the lcd driver
	.pixel_y              (pixel_y),
	.h_res                (h_res),   //resolution signal, comming from the lcd driver
	.v_res                (v_res),	
	//output signals
	.pixel_data           (pixel_data)
);
endmodule
