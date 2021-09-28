/*
25/06/2021
written by Zyy Zhou (22670661)
used for UWA unit ELEC5552 design2  fir filter desin
to make a sound and indicate that there is a signal coming from the port
*/


module uart_beep (
	input               sys_clk,
	input               sys_rst,
	input               uart_en,
	
	output     reg      beep_en
);

//parameter define
parameter       MAX_COUNT = 27'd5000000;

//reg define
reg    [26:0]   count;
reg             uart_en_0;
reg             uart_en_1; //two signals to detect the rising edge of the uart_en signal
reg             beep_flag; //signal indicating beep

//wire define
wire            uart_en_ris; //detect the rising edge of the uart_en signal

//***********************************************************
//                main  code
//***********************************************************
//rising edge detection (1 enabled)
assign uart_en_ris = (~uart_en_0) & uart_en_1; 
//delay the uart_en_0 signal for two time period
always @ (posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst) begin
		uart_en_1 <= 1'b0;
		uart_en_0 <= 1'b0;
	end
	else begin
		uart_en_0 <= uart_en;
		uart_en_1 <= uart_en_0;   //non-blocking assignment, causing the delay
	end
end

/*
enable the beep for MAX_COUNT period of clk signal after a rising edge of uart_en is detected
*/
always @ (posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)      //press the buttom to reset the counter
		beep_flag <= 1'b0;
	else if (uart_en_ris) begin //rising edge of the uart_en detected
		beep_flag <= 1'b1; //start beeping
		beep_en <= 1'b1;
	end
	else if (count == MAX_COUNT) begin //if the time is enough
		beep_flag <= 1'b0; 
		beep_en <= 1'b0; //stop beeping if time is enough
	end
end

/*
start counting clk when start beeping.
when counter reaches MAX_COUNT then beep__flag and beep_en will be disabled (see in the always above)
then beep will stop and the counter will be reset and wait for next beep
*/
always @ (posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)
		count <= 27'd0; //reset the counter and the beep output
	else if (beep_flag == 1'b1) begin  //start counting if start beeping
		if (count < MAX_COUNT)//keep counting if time is not enough
			count <= count + 1;
		else
			count <= 27'd0; //reset the counter if time is enough
	end
	else 
		count <= 27'd0; //reset the counter if not beeping
end

endmodule

