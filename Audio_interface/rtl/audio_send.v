/* 
29/6/2021
created by ALIENTEK. Co
modified and explained by Zyy Zhou (22670661)
this module is to receive the audio input from WM8978 chip
*/
/*
this is the send signal of the WM8978 chip audio module. if the reset button is pressed
or the aud_lrc synchronization signal comes, the counter for the bits will be reset.  
the output data will be loaded in a temporary register and wait to be sent if aud_lrc becomes
high. then the counter increase from 0 and the new data frame will be output one bit by one bit
  
*/
module audio_send #(parameter WL = 6'd32) (
	input                       sys_rst,
	//WM8978 interface
	input                       aud_bclk,
	input                       aud_lrc,  //synchronization signal
	output        reg           aud_dacdat, //audio data output 
	//user interface
	input         [31:0]        dac_data, //temporary data output
	output        reg           tx_done  //indicate that a frame is successfully sent
);

//parameter define

//reg define
reg             aud_lrc_d0;  //delay it for 1 aud_bclk period to detect rising edge
reg     [5:0]   tx_cnt;      //count how many data has been sent
reg     [31:0]  dac_data_t;  //temporarily save the bits being sent

//wire define
wire            lrc_edge;    //if lrc has a rising edge then it outputs 1 for a clk period

//*****************************************************************************
//                    main code
//*****************************************************************************

assign lrc_edge = aud_lrc ^ aud_lrc_d0; //detect rising edge of the synchronization signal

//delay the aud_lrc_d0 signal for a clock period so that detect the rising edge 
always @(posedge aud_bclk or negedge sys_rst) begin
	if(!sys_rst) 
		aud_lrc_d0 <= 1'b0;
	else begin
		aud_lrc_d0 <= aud_lrc;
	end
end
//so now lrc_edge will become 1 if there is a rising edge of synchronization signal

always @(posedge aud_bclk or negedge sys_rst) begin
	if(!sys_rst) begin
		tx_cnt <= 6'b0;         //reset the counter if reset button is pressed.
		dac_data_t <= 32'b0;
	end
	else if (lrc_edge) begin
		tx_cnt <= 6'b0;         //reset the counter if synchronization signal come
		dac_data_t <= dac_data;  //load the data in the temporary register 
	end
	else if (tx_cnt < 6'd35)   //if it is not the end of a frame 
		tx_cnt <= tx_cnt + 1'b1;   //go to next register
end

//set the tx_done output signal to indicate the chip that 32 bits data have been received (for only onr period)
always @(posedge aud_bclk or negedge sys_rst) begin
	if (!sys_rst) begin
		tx_done <= 1'b0;
	end
	else if(tx_cnt == 6'd32)
		tx_done <= 1'b1;
	else 
		tx_done <= 1'b0;
end

//serial output the audio data if a synchronization signal is received
always @(negedge aud_bclk or negedge sys_rst) begin
	if(!sys_rst) begin
		aud_dacdat <= 1'b0;
	end
	else if (tx_cnt < WL)                            //if its not the last bit of the frame
		aud_dacdat <= dac_data_t[WL - 1'd1 - tx_cnt]; //output from the lowest bit of the temporary signal
	else 
		aud_dacdat <= 1'b0;  
end

endmodule
