/*
25/06/2021
written by Zyy Zhou (22670661)
used for UWA unit ELEC5552 design2  fir filter desin
to communicate with laptop and load coefficients
*/

module uart_sender (
	input              sys_clk,
	input              sys_rst,
	input              uart_en,  //connected to the output of the receiver
										  //to indicate the sender that the receiver has completed receiving a frame
	input     [7:0]    uart_data,//the data coming from the receiver, we now send it back to the laptop!
										  
	output      reg    uart_send
);

//parameter define
parameter CLK_FREQ = 50000000; //clock frequency
parameter UART_BPS = 9600;  //bit rate of the interface
localparam BPS_CNT = CLK_FREQ/UART_BPS; //how many clock period per bit

//reg define
reg            uart_en_0;
reg            uart_en_1; //uart_en_1 and 0 are used to detect edge of the input signal
reg    [15:0]  count_clk; //counter for the system
reg    [3:0]   count_data_s; //count how many bit sent
reg            flag_s; //indicate whether the signal is being sent
reg    [7:0]   data_s; //the data being sent

//wire define
wire           start_falg; 
//the start_flag signal should be 1 when a negedge of the input signal is detected

//***************************************************************
//                     main  code
//***************************************************************
assign  start_flag = (~uart_en_1) & uart_en_0; 
//detect the risinging edge of the input signal uart_en
//delay the uart_en_1 signal as 2 clk duration
always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)	begin
		uart_en_1 <= 1'b0;
		uart_en_0 <= 1'b0;
	end
	else begin
		uart_en_0 <= uart_en;
		uart_en_1 <= uart_en_0; //non blocking assignment uart_en_1 will be lagging
	end
end

always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst) begin
		flag_s <= 1'b0; //if rst pressed, the system is not sending any signal
	end
	else begin
		if (start_flag == 1'b1)  begin//if a falling edge is detected
			flag_s <= 1'b1; //start sending
			data_s <= uart_data; //load the data coming from the receiver!
		end
		else if ((count_data_s == 4'd9)&&(count_clk==BPS_CNT/2)) begin//if 9 data is sent and in the middle of the duration
			flag_s <= 1'b0;
			data_s <= 8'd0; //stop sending the data
		end
		else begin
			flag_s <= flag_s;
			data_s <= data_s;
		end
	end
end

always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst) begin
		count_data_s <= 4'd0;
		count_clk <= 16'd0;  //reset all the counter
	end
	else if (flag_s ==1'b1) begin //start sending
		if (count_clk < BPS_CNT-1) begin//if not finishing sending the bit
			count_clk <= count_clk + 1'b1;
			count_data_s <= count_data_s;   //start counting clk
		end
		else begin
			count_clk <= 16'd0; //restart counting
			count_data_s <= count_data_s + 1'b1; //go to next bit
		end
	end
	else begin
		count_data_s <= 4'd0;
		count_clk <= 16'd0;  //not sending anything, reset counters
	end
end

always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)
		uart_send <= 1'b0;
	else if (flag_s ==1'b1)	begin
		case (count_data_s)
			4'd0  :  uart_send <= 1'b0; //start bit
			4'd1  :  uart_send <= data_s [0];
			4'd2  :  uart_send <= data_s [1];
			4'd3  :  uart_send <= data_s [2];
			4'd4  :  uart_send <= data_s [3];
			4'd5  :  uart_send <= data_s [4];
			4'd6  :  uart_send <= data_s [5];
			4'd7  :  uart_send <= data_s [6];
			4'd8  :  uart_send <= data_s [7];
			4'd9  :  uart_send <= 1'b1; //end bit	
			default:;
			endcase
	end
	else
		uart_send <= 1'b1; //not sending
end

endmodule
