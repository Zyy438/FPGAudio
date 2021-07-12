/* 
29/6/2021
created by ALIENTEK. Co
modified and explained by Zyy Zhou (22670661)
this module is to receive the audio input from WM8978 chip
*/
/*
this module is drived by the clk signal from WM 8978, since WM8978 chip is working in 
a master mode this time. it will generate the bclk signal. 
this module will be reset if reset button is pressed or the synchronization signal
aud_lrc has a rising or falling edge 
else it will start counting how many bits being received and start receiving data.
a frame usually has 32bits of data. so, after 32 aud_bclk period(rx_cnt=32), the data in
the temporary register will output the data in this frame. within the frame, the
data in each bit of the temporary register will be updated one by one.
a signal called rx_done will be output high for a period when datas in a frame are all read.
this is to indicate the chip that this frame is successfully received.
*/

module audio_receive #(parameter WL= 6'd32)(
	input                   aud_bclk,  //WM8978 synchronize clk
	input                   sys_rst,  
	input                   aud_lrc,   //synchronization signal
	input                   aud_adcdat,//audio input signal
	
	//user interface
	output      reg         rx_done,   //receive done
	output      reg  [31:0] adc_data   //data received
);

//parameter deine

//reg defin
reg                aud_lrc_d0;        //aud_lrc delay for a period
reg     [5:0]      rx_cnt;            //receive count
reg     [31:0]     adc_data_t;        //pre_output data

//wire define
wire               lrc_edge;          //edge signal

//************************************************************************
//                      main code
//************************************************************************
//detect edge of the aud_lrc signal
assign  lrc_edge = aud_lrc & (~aud_lrc_d0); //in this place we only sample the right channel of the audio data

//delay the aud_lrc_d0 for a aud_bclk period, to detect the rising edge of the
//synchronization signal aud_lrc
always @(posedge aud_bclk or negedge sys_rst) begin
	if(!sys_rst) 
		aud_lrc_d0 <= 1'b0;
	else
		aud_lrc_d0 <= aud_lrc;
end

//count the sampled audio data
always @(posedge aud_bclk or negedge sys_rst) begin
	if(!sys_rst)
		rx_cnt <= 6'd0;
	else if (lrc_edge == 1'b1)          //reset the counter if need to synchronize
		rx_cnt <= 6'd0;  
	else if (rx_cnt < 6'd35)	 //else count how many data sampled
		rx_cnt <= rx_cnt + 1'b1;
end


//store the sampled data in a temporary register. this is because that IIC protocol
//has only one receive signal and it can only transmit one bit at a clk period
always @(posedge aud_bclk or negedge sys_rst) begin
	if(!sys_rst) begin
		adc_data_t <= 32'b0;
	end
	else if (rx_cnt < WL)  //if not reach a word length
		adc_data_t[WL - 1'd1 - rx_cnt] <= aud_adcdat;  //assign the receive signal to the corresponding bit of the register
end

//output the stored signal to a register if a frame is completed
always @(posedge aud_bclk or negedge sys_rst) begin
	if(!sys_rst) begin
		rx_done <= 1'b0;
		adc_data <= 32'b0;
	end
	else if (rx_cnt == 6'd32) begin  //if 32 bits are received
		rx_done <= 1'b1;              //indicate that receiving done
		adc_data <= adc_data_t;			//output the received data as a cmplete vector
	end
	else 
		rx_done <= 1'b0;              //else not finishing receiving
end

endmodule
