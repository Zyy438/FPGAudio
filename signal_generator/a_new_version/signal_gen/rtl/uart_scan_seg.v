/*
created on 26/06/2021 by Zyy Zhou (22670661)
LED number module designed for ELEC5552 design2 fir filter
detect whether there is a data flow coming from the uart port
and change the number shown in LED accordingly
*/

module uart_scan_seg (
	input                  sys_clk,
	input                  sys_rst,
	input                  uart_en,  //enable this module if signal uart_en 
	
	output  reg   [5:0]    sel,      //select which segment to be turned on
	output  reg   [7:0]    seg_led  //indicate the word being shown in the selected segment
);

//parameter define
parameter	SEG0 = 6'b111111; //no segment turned on
parameter	SEG1 = 6'b011111; //segment 1 turned on
parameter	SEG2 = 6'b101111; //segment 2 turned on
parameter	SEG3 = 6'b110111; //the segment will be selected at low level 
parameter	SEG4 = 6'b111011;
parameter	SEG5 = 6'b111101;
parameter	SEG6 = 6'b111110;

parameter	WORD0 = 2'd0;
parameter	WORD1 = 2'd1;
parameter	WORD2 = 2'd2;

parameter   MAX_COUNT = 28'd100000000; //the "load" word will stay 2 sec
parameter   CNT_MAX2 =  23'd50000; //count 50000clk to jump to next segment
parameter   CNT_MAX3 =  50000000; //the word will iterate every 1 sec
								          //when there is no signal coming from the uart_port
								
//reg define
reg  [1:0]  word_sel;  //3 different states of the word shown
reg         word_sel2; //to select word to show when no signal is coming

reg         uart_en_0;
reg         uart_en_1; //used to detect the rising edge of the uart_en sign
reg         start_flag; //used to indicate that the "load" word is being shown
reg  [27:0] count_clk; //a counter enabled when the word "load" is shown
reg  [22:0] count_clk2; //another counter to count the time to jump to next segment
reg  [26:0] count_clk3; //another counter to count the time to switch the word shown
								//when there is no signal coming from the uart_port
reg         next_seg; //when it becomes 1'b1 jump to next led segment
reg         next_word; //when it becomes 1'b1 jump to next word when no signal coming from port

//wire define
wire        uart_en_ris;  //indicate rising edge of the uart_en signal

//************************************************************************
//                 main code
//************************************************************************
//detect the rising edge of uart_en signal
assign    uart_en_ris = (~uart_en_0) && uart_en_1;

//delay the uart_en_0 signal for two clk period to detect the rising edge
always @ (posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst) begin
		uart_en_0 <= 1'b0;
		uart_en_1 <= 1'b0; //reset the two signal if reset button pressed
	end
	else begin
		uart_en_1 <= uart_en;
		uart_en_0 <= uart_en_1; //delay the uart_en_0 signal, non-blocking assignment
	end
end

always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)
		word_sel <= WORD0;
	else if (uart_en_ris) begin //start showing word "load" if there is a signal coming from the uart port
		word_sel <= WORD1;
		start_flag <= 1'b1;
	end
	else if (count_clk == MAX_COUNT) begin //if the time is 2s
		word_sel <= WORD2; //show  word "load"
		start_flag <= 1'b0;  //end the state showing word "load" 
	end
	else begin
		word_sel <= word_sel;
		start_flag <= start_flag; //remain current state during other time
	end
end

always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)
		count_clk <= 27'd0; //reset the clk signal when reset button is pressed
	else if (start_flag) begin //if start showing the word "load"
		if (count_clk < MAX_COUNT) 
			count_clk <= count_clk + 1; //increase the time if the time is not enough
		else
			//if time is enough, the start_flag signal as well as count_clk signal will be reset
			count_clk <= 27'd0;  
	end
	else 
		count_clk <= 27'd0;
end

//this is to generate a next_seg signal to switch the state of the sel signal
//this signal will become 1'b1 every 0.1 second
always @ (posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst) begin
		count_clk2 <= 22'd0;
		next_seg <= 1'b0;
	end
	else if (count_clk2 < CNT_MAX2) begin
		count_clk2 <= count_clk2 + 1;
		next_seg <= 1'b0;
	end
	else begin
		count_clk2 <= 27'd0;
		next_seg <= 1'b1;
	end	
end

//this is to generate a next_seg2 signal to switch the word shown when no signal coming from port
//this signal will become 1'b1 every 1 second
always @ (posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst) begin
		count_clk3 <= 27'd0;
		next_word <= 1'b0;
	end
	else if (count_clk3 < CNT_MAX3) begin
		count_clk3 <= count_clk3 + 1;
		next_word <= 1'b0;
	end
	else begin
		count_clk3 <= 27'd0;
		next_word <= 1'b1;
	end	
end

//to iterate the segment select. residual visual will happen as long as the iterate frequency is high
always @ (posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)
		sel <= SEG0;
	else if (next_seg == 1) //if 0.1s
		case (sel)   //jump to the next segment
		SEG0 :   sel <= SEG1;
		SEG1 :   sel <= SEG2;
		SEG2 :   sel <= SEG3;
		SEG3 :   sel <= SEG4;
		SEG4 :   sel <= SEG5;
		SEG5 :   sel <= SEG6;
		SEG6 :   sel <= SEG1;
		endcase
	else
		sel <= sel; //stay in this segment if time is not to 0.1s
end

//to iterate the word shown when the data is not transmitted
always @ (posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)
		word_sel2 <= 1'd0;
	else if (next_word == 1'b1) //if 1s
		case (word_sel2)   //jump to the next segment
		1'd0 :   word_sel2 <= 1'd1;
		1'd1 :   word_sel2 <= 1'd0;
		endcase
	else
		word_sel2 <= word_sel2; //stay in this word if time is not to 1s
end


always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst)
		seg_led <= 8'b11111111;
/*	else if (next_seg == 1'b1)
		if (word_sel == WORD1)
*/
//the led will turn on accordingly when there is a low level input
	else  if (word_sel == WORD1)
		case (sel)    //which segment is selected
			SEG0 :  seg_led <= 8'b1111_1111;
			SEG1 :  seg_led <= 8'b1100_0111;  //"L"
			SEG2 :  seg_led <= 8'b1100_0000;  //"O"
			SEG3 :  seg_led <= 8'b1000_1000;  //"A"
			SEG4 :  seg_led <= 8'b1010_0001;  //"d"
			SEG5 :  seg_led <= 8'b1000_0110;  //"E"
			SEG6 :  seg_led <= 8'b1010_0001;  //"d"
		endcase
	else if (word_sel == WORD2) begin
		if (word_sel2 == 1'b0)
			case (sel)
				SEG1 :  seg_led <= 8'b1000_0110;  //"E"
				SEG2 :  seg_led <= 8'b1100_0111;  //"L"
				SEG3 :  seg_led <= 8'b1000_0110;  //"E"
				SEG4 :  seg_led <= 8'b1100_0110;  //"C"
				SEG5 :  seg_led <= 8'b1111_1111;
				SEG6 :  seg_led <= 8'b1111_1111;
			endcase
		else
			case (sel)
				SEG1 :  seg_led <= 8'b1001_0010;  //"5"
				SEG2 :  seg_led <= 8'b1001_0010;  //"5"
				SEG3 :  seg_led <= 8'b1111_1001;  //"1"
				SEG4 :  seg_led <= 8'b1010_0100;  //"2"
				SEG5 :  seg_led <= 8'b1111_1111;
				SEG6 :  seg_led <= 8'b1111_1111;
			endcase
		end
/*	else if (word_sel == WORD3)
		case (sel)
			SEG1 :  seg_led <= 8'b1000_1000;  //"A"
			SEG2 :  seg_led <= 8'b1001_0010;  //"S"
			SEG3 :  seg_led <= 8'b1000_1001;  //"H"
			SEG4 :  seg_led <= 8'b1100_0111;  //"L"
			SEG5 :  seg_led <= 8'b1000_0110;  //"E"
			SEG6 :  seg_led <= 8'b1001_0001;  //"y"

			SEG0 :  seg_led <= 8'b1111_1111;
			SEG1 :  seg_led <= 8'b1111_1111;
			SEG2 :  seg_led <= 8'b1000_1001;  //"H"
			SEG3 :  seg_led <= 8'b1000_1000;  //"A"
			SEG4 :  seg_led <= 8'b1000_1100;  //"P"
			SEG5 :  seg_led <= 8'b1000_1100;  //"P"
			SEG6 :  seg_led <= 8'b1001_0001;  //"y"
			
			SEG1 :  seg_led <= 8'b1111_1111;
			SEG2 :  seg_led <= 8'b1000_0011;  //"b"
			SEG3 :  seg_led <= 8'b1011_1111;  //"-"
			SEG4 :  seg_led <= 8'b1010_0001;  //"d"
			SEG5 :  seg_led <= 8'b1000_1000;  //"a"
			SEG6 :  seg_led <= 8'b1001_0001;  //"y"
			
		endcase
*/
	else
		seg_led <= 8'b11111111;
end

endmodule
