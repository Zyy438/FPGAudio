/*
25/06/2021
written by Zyy Zhou (22670661)
used for UWA unit ELEC5552 design2  fir filter desin
to communicate with laptop and load coefficients
*/

module uart_receive (
	input				sys_clk,
	input				sys_rst,
	input          uart_r,  //uart receive interface
	
	output    reg         uart_finish,  //to tell the sender that a frame has been fully received
	output    reg  [7:0]  uart_data
);

//parameter define 
parameter CLK_FRE = 50000000;  //frequency of the system
parameter UART_BPS = 9600; //Bit rate of the interface
localparam BPS_CNT =CLK_FRE/UART_BPS;  //how many clock period per bit

//reg define
reg     [7:0]     data_r; //8 bit data signal in a frame. use to temporarily store the received data
reg               flag_r; //indicate receiving the signal
reg     [3:0]     count_data_r; //count how many data received. 1'd8=4'b1000, thus 4 bits needed
reg     [15:0]    count_clk; //count the clock

reg               uart_r_0;
reg               uart_r_1; //uart_r_1 and 0 are used to detect edge of the input signal

//wire define
wire              start_flag; //signal indicating that an edge is detect and data transmission shall start

//*************************************************************
//                 main code
//*************************************************************
//the start_flag signal should be 1 when a negedge of the input signal is detected
//when the input signal is 0 at the moment and the signal in last two clk duration 
//is 1, the start flag should be one
assign  start_flag = uart_r_1 & (~uart_r_0); 

//delay the uart_r_1 signal as 2 clk duration
always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)	begin
		uart_r_1 <= 1'b0;
		uart_r_0 <= 1'b0;
	end
	else begin
		uart_r_0 <= uart_r;
		uart_r_1 <= uart_r_0; //non blocking assignment uart_r_1 will be lagging
	end
end

always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst) begin
		flag_r <= 1'b0; //if rst pressed, the system is not receiving any signal
	end
	else begin
		if (start_flag == 1'b1) begin //if a falling edge is detected
			flag_r <= 1'b1; //start receiving
		end
		else if ((count_data_r == 4'd9)&&(count_clk==BPS_CNT/2)) //if 9 data is read and in the middle of this duration
			flag_r <= 1'b0;
		else
			flag_r <= flag_r;
	end
end

//when start reading, start counting the data bit number and the clk number
always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst) begin
		count_clk <= 16'd0;
		count_data_r <= 4'd0; //reset the counter
	end
	else if (flag_r == 1'b1) begin
		if(count_clk < BPS_CNT-1) begin //still receiving
			count_clk <= count_clk + 1'b1;
			count_data_r <= count_data_r;  //receiving this bit
			//the first falling edge is the start signal so count_data_r does not have to recive data
		end
		else begin
			count_clk <= 16'd0;
			count_data_r <= count_data_r + 1;// receiving next data
		end
	end
	else begin //not receiving
		count_clk <= 16'd0;
		count_data_r <= 4'd0; //reset the counter
	end
end

//receive the signal and store it in a register (signal data_r)
always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)
		data_r <= 8'b0;  //reset the register 
	else if (flag_r) //if receiving
		if (count_clk == BPS_CNT/2) begin //the data will be most stable in the middle time of the bit
			case (count_data_r) //in which bit reciving?
				4'd1  :   data_r [0] <= uart_r_1; //start from 4'd1, 4'd0 is start bit and no data transmitted.
				4'd2  :   data_r [1] <= uart_r_1;
				4'd3  :   data_r [2] <= uart_r_1;
				4'd4  :   data_r [3] <= uart_r_1;
				4'd5  :   data_r [4] <= uart_r_1;
				4'd6  :   data_r [5] <= uart_r_1;
				4'd7  :   data_r [6] <= uart_r_1;
				4'd8  :   data_r [7] <= uart_r_1;
				default:;
			endcase
		end
		else data_r <= data_r;
	else
		data_r <= 8'b0; //clear signal if not receiving
end

//after receiving the signal, pump it to the output
always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst) begin
		uart_data <= 8'd0;
		uart_finish <= 1'd0; 
	end
	else if (count_data_r == 4'd9) begin //if end reading a frame
		uart_data <= data_r; //assign the signal to the output
		uart_finish <= 1'd1; //indicates that a frame is read
	end
	else begin
		uart_data <= 8'd0;
		uart_finish <= 1'd0; //no data and no enable signal output
	end
end

endmodule
