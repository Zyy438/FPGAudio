/*
29/06/21
created by ALIENTEK .Co   
modified by Zyy Zhou (22670661)
this is an IIC protocol driver for WM8978 audio chip
used for ELEC5552 design2 unit
*/

/*
this module has a 1MHZ clk signal, synchronized with WM8978
this module is to send configuration signal to WM8978 chip through I2S protocol
if reset button pressed, start_init_count becomes 0 and start increasing.  it remains
the same value after a specific time passed.
when a specific time is passed, i2c_exec becomes high and let the register counter
init_reg_cnt increase by 1 (it will be increased for every time i2c_exec becomes high)
, thus go to the next register (in WM 8978 chip)being configured.
then, output the configuration signal through i2c_data output pin to the chip
the module will receice signal cfg_done from the chip as well, indicating that a 
signal has been successfully received by the chip. if this signal becomes high, i2c_exec will
be high again and moves to next register (init_reg_cnt += 1)
in different registers being configured, different configuration data will be 
sent through I2S bus (output i2c_data)
*/
module i2c_reg_cfg (
	input                  clk,        //1MHz
	input                  sys_rst,
	input                  i2c_done,   //i2c finish signal,coming from the chip indicating
												  //that a configuratino signal has been successfully 
												  //received and a register has been configured
												  
	output    reg          i2c_exec,   //i2c executing signal
	output    reg          cfg_done,   //configuration done
	output    reg  [15:0]  i2c_data    //data in the register
);

//parameter define 
parameter     WL = 6'd32;  //word length of a audio segment

localparam    RG_NUM = 5'd19;         //number of registers which need configuration
localparam    PHONE_VOLUME = 6'd30;   //set the volumn for a head set
localparam    SPEAK_VOLUME = 6'd45;   //set the volumn for an amplifier

//reg define
reg     [1:0]      wl;      //define the word length of an audio segment
reg     [7:0]      start_init_cnt;    //initialization counter
reg     [4:0]      init_reg_cnt;      //conunt the registers configured

//wire deine

//*************************************************************************
//                        main code
//*************************************************************************

//set the word length of an audio segment. in this project we already define
//WL=6'd32, which means wl<=2'b11 this parameter can be modified if different
//audio decoder chip is used.
always @(posedge clk or negedge sys_rst) begin
	if (!sys_rst)
		wl <= 2'b00;       //reset the word length if reset button pressed
	else begin
		case(WL)
			6'd16  :  wl <= 2'b00;
			6'd20  :  wl <= 2'b01;
			6'd24  :  wl <= 2'b10;
			6'd32  :  wl <= 2'b11;
			default:
				wl <= 2'b00;
		endcase
	end
end

//delay for a period of time after the chip turns on, making it stable
always @(posedge clk or negedge sys_rst) begin
	if(!sys_rst)
		start_init_cnt <= 8'd0;
	else if (start_init_cnt < 8'hff)
		start_init_cnt <= start_init_cnt + 1'b1;
end

//set a signal i2c_exec indicating the configuration of registers
always @(posedge clk or negedge sys_rst) begin
	if(!sys_rst)
		i2c_exec <= 1'b0;
	else if (init_reg_cnt == 5'd0 & start_init_cnt == 8'hfe) //not start configuration yet but end waiting
		i2c_exec <= 1'b1;             //indicating configuring
	else if (i2c_done && init_reg_cnt < RG_NUM) //if a register is configured(ack signal) but not all
		i2c_exec <= 1'b1;
	else
		i2c_exec <= 1'b0;
end

//a counter counts registers configured.  there are totally 19 registers need configuration
always @(posedge clk or negedge sys_rst) begin
	if(!sys_rst)
		init_reg_cnt <= 5'd0;
	else if (i2c_exec)       //if i2c_exec is 1 then go to next register
		init_reg_cnt <= init_reg_cnt + 1'b1;
end

//cfg_done signal
always @(posedge clk or negedge sys_rst) begin
	if(!sys_rst)
		cfg_done <= 1'b0;
	else if (i2c_done & (init_reg_cnt == RG_NUM))
		cfg_done <= 1'b1;
end

//configure the registers in the chip
always @(posedge clk or negedge sys_rst) begin
	if(!sys_rst)
		i2c_data <= 16'b0;
	else begin
		case (init_reg_cnt)
			//R0, reset
			5'd0 : i2c_data <= {7'd0,9'b1};
			// R1,VMIDSEL,BUFIOEN,BIASEN,PLLEN,BUFDCOPEN
         5'd1 : i2c_data <= {7'd1 ,9'b1_0010_1111};
         // R2,ENABLE BOOSTENR,BOOSTENL和ADCENR/L;enable ROUT1,LOUT1
         5'd2 : i2c_data <= {7'd2 ,9'b1_1011_0011};
         // R3,LOUT2,ROUT2 ENABLE AMPlIfier,RMIX,LMIX,DACENR、DACENL ENABLE
         5'd3: i2c_data <= {7'd3 ,9'b0_0110_1111};
         // R4,I2S AUDIO INTERFACE(bit4:3)，wordlength(wl)
         5'd4 : i2c_data <= {7'd4 ,{2'd0,wl,5'b10000}};
         // R6, MASTER MODE(BCLK LRC output by WM8978)
         5'd5 : i2c_data <= {7'd6 ,9'b0_0000_0001};
         // R7, slow clock，SAMPLE RATE 48KHz(bit3:1)
			5'd6 : i2c_data <= {7'd7 ,9'b0_0000_0001};
			// R10,DAC OVER SAMPLE RATE 128x(bit3)
			5'd7 : i2c_data <= {7'd10,9'b0_0000_1000};
			// R14,ADC OVER SAMPLE RATE 128x(bit3)
			5'd8 : i2c_data <= {7'd14,9'b1_0000_1000}; 
			// R43,INVROUT2(bit4),DRIVE the amplifier
			5'd9 : i2c_data <= {7'd43,9'b0_0001_0000};
			// R47,left channel，L2_2BOOSTVOL(bit6:4)
			5'd10: i2c_data <= {7'd47,9'b0_0111_0000};
			// R48,right_channel boost lecel (the same)
			5'd11: i2c_data <= {7'd48,9'b0_0111_0000};
			// R49,TSDEN(bit0),over temprature protection;SPKBOOST(bit2)
			5'd12: i2c_data <= {7'd49,9'b0_0000_0110};
			// R50,LEFT DAC OUTPUTS TO LEFT MIXER(bit0)
			5'd13: i2c_data <= {7'd50,9'b1};
			// R51,RIGHT DAC OUTPUTS TO RIGHT MIXER(bit0)
			5'd14: i2c_data <= {7'd51,9'b1};
			// R52,HEADSET LEFT VOLUMN(bit5:0)，ENABLE 0(bit7)
			5'd15: i2c_data <= {7'd52,{3'b010,PHONE_VOLUME}};
			// R53,HEADSET RIGHT VOLUMN(bit5:0)，ENABLE(bit7),(HPVU=1)
			5'd16: i2c_data <= {7'd53,{3'b110,PHONE_VOLUME}};
			// R54,AMPLIFIER LEFT VOLUMN(bit5:0)，ENABLE(bit7);
			5'd17: i2c_data <= {7'd54,{3'b010,SPEAK_VOLUME}};
			// R55,AMPLIFIER RIGHT VOLUMN(bit5:0)，ENABLE(SPKVU=1)
			5'd18: i2c_data <= {7'd55,{3'b110,SPEAK_VOLUME}};
		endcase
	end
end

endmodule
