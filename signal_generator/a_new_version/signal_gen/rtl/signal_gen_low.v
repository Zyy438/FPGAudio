/*
Yuyang Zhou
30/07/2021
for lianying medical test
single bit data synchronization between two clk domains
two clk domains, hold the input signal and wait for the receiver
*/

/*
module sync(
	input        sys_clka,
	input        sys_clkb,
	input        sys_rst,
	input        datain,
	//output signal
	output       data_sync
);

//parameter define


//reg define
//sync from main a to b
reg    temp_reg0;
reg    temp_reg1;
reg    temp_reg2;
//sync from main b to a
reg    temp_reg3;
reg    temp_reg4;
//data hold, temporarily save the state of input data a
reg    data_hold;
//signal indicating that the hold signal is successfully received
reg    data_pull_down;


//wire define

//*****************************************************************
//               main code
//*****************************************************************
assign    data_sync <= temp_reg2;

always @(posedge sys_clka or negedge sys_rst) begin
	if(!sys_rst) begin
		data_hold <<= 1'b0;
	end
	else if (datain) begin
		data_hold <<= 1'b1;
	end
	else if (data_pull_down) begin
		data_hold <<= 1'b0;
	end
	else begin
		data_hold <<= data_hold;
	end
end

always @(posedge sys_clkb or negedge sys_rst) begin
	if(!sys_rst) begin
		temp_reg0 <<= 1'b0;
		temp_reg1 <<= 1'b0;
		temp_reg2 <<= 1'b0;
	end
	else begin
		temp_reg0 <<= data_hold;
		temp_reg1 <<= temp_reg0;
		temp_reg2 <<= temp_reg1;
	end
end

//synchonize signal temp_reg2 from domain b to domain a
//if temp_reg2 becomes 1, it means that the pulse is received and we can then pull down the hold signal
always @(posedge sys_clka or negedge sys_rst) begin
	if(!sys_rst) begin
		temp_reg3 <<= 1'b0;
		temp_reg4 <<= 1'b0;
		data_pull_down <<= 1'b0;
	end
	else begin
		temp_reg3 <<= temp_reg2;
		temp_reg4 <<= temp_reg3;
		data_pull_down <<= temp_reg4;  
	end
end
endmodule
*/






/*
Yuyang Zhou
08/08/2021
D flipflop 
*/

/*
module sync(
	//input signal
	input           sys_clk,
	input           sys_rst,
	input           data_in,
	//output signal
	output          data_out
);


//parameter define


//reg define
reg         data_out_reg;
reg         data_tem;
//wire define


//********************************************************************
//********************************************************************
assign      data_out <= data_out_reg;

always @(posedge sys_clk) begin
	if (!sys_rst) begin
		data_out_reg <<= 1'b0;
	end
	else begin
		data_out_reg <<= data_in;
	end
end
endmodule
*/

/*
module sync(
	input        sys_clk,
   input        sys_rst,
	input        data_in,
	//output signal
	output       data_out
);

reg  [2:0] data_tem;


assign   data_out <= data_tem;

always @(posedge sys_clk or negedge sys_rst) begin
	if (!sys_rst) begin
		data_tem <<= 3'd0;
	end
	else if (data_tem < 3'd5) begin
		data_tem <<= data_tem +1;
	end
	else begin
		data_tem <<= 3'd0;
	end
end

endmodule
*/


/*
module sync (
	//clock signal and reset signal
	input   sys_clk,
	input   sys_rst,
	//data input from different fir filters
	input   fir1,
	input   fir2,
	input   fir3,
	input   fir4,
	//select signal
	input   [2:0]  select,
	//data output
	output  select_output
);

//reg define
reg      select_output_reg;

//*******************************************************
//            main code
//********************************************************
assign   select_output <= select_output_reg;

always @(posedge sys_clk or negedge sys_rst)begin
	if(!sys_rst)
		select_output_reg <<= 1'b0;
	else
	case (select)
		2'b00: select_output_reg <<= fir1;
		2'b01: select_output_reg <<= fir2;
		2'b10: select_output_reg <<= fir3;
		2'b11: select_output_reg <<= fir4;
	default: select_output_reg <<= fir1;
	endcase
end
endmodule
*/


// module sine_rom()
module signal_gen_low(
	input            sys_clk,     // clock
	input            sys_rst,     //reset button
	
	output  [7:0]    rd           //data output
); 

//reg define
reg    [6:0]   count;      //counter signal, plus one for every clk period  
reg    [7:0]   rd_reg;

//***************************************************************************
//                            main code
//***************************************************************************
//the output is defined as a wire output, need to use reg parameter in always block
assign    rd = rd_reg;

//memory part, the output data for each counter state
always @ (posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		rd_reg <= 8'b00000000;
	end
	else begin
		case(count)
			7 'd 0     :rd_reg <= #1 8 'b 00000000; //      0 0x0 
			7 'd 1     :rd_reg <= #1 8 'b 00000110; //      6 0x6 
			7 'd 2     :rd_reg <= #1 8 'b 00001100; //     12 0xC 
			7 'd 3     :rd_reg <= #1 8 'b 00010010; //     18 0x12 
			7 'd 4     :rd_reg <= #1 8 'b 00011000; //     24 0x18 
			7 'd 5     :rd_reg <= #1 8 'b 00011110; //     30 0x1E 
			7 'd 6     :rd_reg <= #1 8 'b 00100100; //     36 0x24 
			7 'd 7     :rd_reg <= #1 8 'b 00101010; //     42 0x2A 
			7 'd 8     :rd_reg <= #1 8 'b 00110000; //     48 0x30 
			7 'd 9     :rd_reg <= #1 8 'b 00110110; //     54 0x36 
			7 'd 10    :rd_reg <= #1 8 'b 00111011; //     59 0x3B 
			7 'd 11    :rd_reg <= #1 8 'b 01000001; //     65 0x41 
			7 'd 12    :rd_reg <= #1 8 'b 01000110; //     70 0x46 
			7 'd 13    :rd_reg <= #1 8 'b 01001011; //     75 0x4B 
			7 'd 14    :rd_reg <= #1 8 'b 01010000; //     80 0x50 
			7 'd 15    :rd_reg <= #1 8 'b 01010101; //     85 0x55 
			7 'd 16    :rd_reg <= #1 8 'b 01011001; //     89 0x59 
			7 'd 17    :rd_reg <= #1 8 'b 01011110; //     94 0x5E 
			7 'd 18    :rd_reg <= #1 8 'b 01100010; //     98 0x62 
			7 'd 19    :rd_reg <= #1 8 'b 01100110; //    102 0x66 
			7 'd 20    :rd_reg <= #1 8 'b 01101001; //    105 0x69 
			7 'd 21    :rd_reg <= #1 8 'b 01101100; //    108 0x6C 
			7 'd 22    :rd_reg <= #1 8 'b 01110000; //    112 0x70 
			7 'd 23    :rd_reg <= #1 8 'b 01110010; //    114 0x72
			7 'd 24    :rd_reg <= #1 8 'b 01110101; //    117 0x75 
			7 'd 25    :rd_reg <= #1 8 'b 01110111; //    119 0x77 
			7 'd 26    :rd_reg <= #1 8 'b 01111001; //    121 0x79 
			7 'd 27    :rd_reg <= #1 8 'b 01111011; //    123 0x7B 
			7 'd 28    :rd_reg <= #1 8 'b 01111100; //    124 0x7C 
			7 'd 29    :rd_reg <= #1 8 'b 01111101; //    125 0x7D 
			7 'd 30    :rd_reg <= #1 8 'b 01111110; //    126 0x7E 
			7 'd 31    :rd_reg <= #1 8 'b 01111110; //    126 0x7E 
			7 'd 32    :rd_reg <= #1 8 'b 01111111; //    127 0x7F 
			7 'd 33    :rd_reg <= #1 8 'b 01111110; //    126 0x7E 
			7 'd 34    :rd_reg <= #1 8 'b 01111110; //    126 0x7E 
			7 'd 35    :rd_reg <= #1 8 'b 01111101; //    125 0x7D 
			7 'd 36    :rd_reg <= #1 8 'b 01111100; //    124 0x7C 
			7 'd 37    :rd_reg <= #1 8 'b 01111011; //    123 0x7B 
			7 'd 38    :rd_reg <= #1 8 'b 01111001; //    121 0x79 
			7 'd 39    :rd_reg <= #1 8 'b 01110111; //    119 0x77 
			7 'd 40    :rd_reg <= #1 8 'b 01110101; //    117 0x75 
			7 'd 41    :rd_reg <= #1 8 'b 01110010; //    114 0x72 
			7 'd 42    :rd_reg <= #1 8 'b 01110000; //    112 0x70 
			7 'd 43    :rd_reg <= #1 8 'b 01101100; //    108 0x6C 
			7 'd 44    :rd_reg <= #1 8 'b 01101001; //    105 0x69 
			7 'd 45    :rd_reg <= #1 8 'b 01100110; //    102 0x66 
			7 'd 46    :rd_reg <= #1 8 'b 01100010; //     98 0x62 
			7 'd 47    :rd_reg <= #1 8 'b 01011110; //     94 0x5E 
			7 'd 48    :rd_reg <= #1 8 'b 01011001; //     89 0x59 
			7 'd 49    :rd_reg <= #1 8 'b 01010101; //     85 0x55 
			7 'd 50    :rd_reg <= #1 8 'b 01010000; //     80 0x50 
			7 'd 51    :rd_reg <= #1 8 'b 01001011; //     75 0x4B 
			7 'd 52    :rd_reg <= #1 8 'b 01000110; //     70 0x46 
			7 'd 53    :rd_reg <= #1 8 'b 01000001; //     65 0x41 
			7 'd 54    :rd_reg <= #1 8 'b 00111011; //     59 0x3B 
			7 'd 55    :rd_reg <= #1 8 'b 00110110; //     54 0x36 
			7 'd 56    :rd_reg <= #1 8 'b 00110000; //     48 0x30 
			7 'd 57    :rd_reg <= #1 8 'b 00101010; //     42 0x2A 
			7 'd 58    :rd_reg <= #1 8 'b 00100100; //     36 0x24 
			7 'd 59    :rd_reg <= #1 8 'b 00011110; //     30 0x1E 
			7 'd 60    :rd_reg <= #1 8 'b 00011000; //     24 0x18 
			7 'd 61    :rd_reg <= #1 8 'b 00010010; //     18 0x12 
			7 'd 62    :rd_reg <= #1 8 'b 00001100; //     12 0xC 
			7 'd 63    :rd_reg <= #1 8 'b 00000110; //      6 0x6 
			7 'd 64    :rd_reg <= #1 8 'b 00000000; //      0 0x0 
			7 'd 65    :rd_reg <= #1 8 'b 11111010; //     -6 0xFA 
			7 'd 66    :rd_reg <= #1 8 'b 11110100; //    -12 0xF4 
			7 'd 67    :rd_reg <= #1 8 'b 11101110; //    -18 0xEE 
			7 'd 68    :rd_reg <= #1 8 'b 11101000; //    -24 0xE8 
			7 'd 69    :rd_reg <= #1 8 'b 11100010; //    -30 0xE2 
			7 'd 70    :rd_reg <= #1 8 'b 11011100; //    -36 0xDC 
			7 'd 71    :rd_reg <= #1 8 'b 11010110; //    -42 0xD6 
			7 'd 72    :rd_reg <= #1 8 'b 11010000; //    -48 0xD0 
			7 'd 73    :rd_reg <= #1 8 'b 11001010; //    -54 0xCA 
			7 'd 74    :rd_reg <= #1 8 'b 11000101; //    -59 0xC5 
			7 'd 75    :rd_reg <= #1 8 'b 10111111; //    -65 0xBF 
			7 'd 76    :rd_reg <= #1 8 'b 10111010; //    -70 0xBA 
			7 'd 77    :rd_reg <= #1 8 'b 10110101; //    -75 0xB5 
			7 'd 78    :rd_reg <= #1 8 'b 10110000; //    -80 0xB0 
			7 'd 79    :rd_reg <= #1 8 'b 10101011; //    -85 0xAB 
			7 'd 80    :rd_reg <= #1 8 'b 10100111; //    -89 0xA7 
			7 'd 81    :rd_reg <= #1 8 'b 10100010; //    -94 0xA2 
			7 'd 82    :rd_reg <= #1 8 'b 10011110; //    -98 0x9E 
			7 'd 83    :rd_reg <= #1 8 'b 10011010; //   -102 0x9A 
			7 'd 84    :rd_reg <= #1 8 'b 10010111; //   -105 0x97 
			7 'd 85    :rd_reg <= #1 8 'b 10010100; //   -108 0x94 
			7 'd 86    :rd_reg <= #1 8 'b 10010000; //   -112 0x90 
			7 'd 87    :rd_reg <= #1 8 'b 10001110; //   -114 0x8E 
			7 'd 88    :rd_reg <= #1 8 'b 10001011; //   -117 0x8B 
			7 'd 89    :rd_reg <= #1 8 'b 10001001; //   -119 0x89 
			7 'd 90    :rd_reg <= #1 8 'b 10000111; //   -121 0x87 
			7 'd 91    :rd_reg <= #1 8 'b 10000101; //   -123 0x85 
			7 'd 92    :rd_reg <= #1 8 'b 10000100; //   -124 0x84 
			7 'd 93    :rd_reg <= #1 8 'b 10000011; //   -125 0x83 
			7 'd 94    :rd_reg <= #1 8 'b 10000010; //   -126 0x82 
			7 'd 95    :rd_reg <= #1 8 'b 10000010; //   -126 0x82 
			7 'd 96    :rd_reg <= #1 8 'b 10000001; //   -127 0x81 
			7 'd 97    :rd_reg <= #1 8 'b 10000010; //   -126 0x82 
			7 'd 98    :rd_reg <= #1 8 'b 10000010; //   -126 0x82 
			7 'd 99    :rd_reg <= #1 8 'b 10000011; //   -125 0x83 
			7 'd 100   :rd_reg <= #1 8 'b 10000100; //   -124 0x84 
			7 'd 101   :rd_reg <= #1 8 'b 10000101; //   -123 0x85 
			7 'd 102   :rd_reg <= #1 8 'b 10000111; //   -121 0x87 
			7 'd 103   :rd_reg <= #1 8 'b 10001001; //   -119 0x89 
			7 'd 104   :rd_reg <= #1 8 'b 10001011; //   -117 0x8B 
			7 'd 105   :rd_reg <= #1 8 'b 10001110; //   -114 0x8E 
			7 'd 106   :rd_reg <= #1 8 'b 10010000; //   -112 0x90 
			7 'd 107   :rd_reg <= #1 8 'b 10010100; //   -108 0x94 
			7 'd 108   :rd_reg <= #1 8 'b 10010111; //   -105 0x97 
			7 'd 109   :rd_reg <= #1 8 'b 10011010; //   -102 0x9A 
			7 'd 110   :rd_reg <= #1 8 'b 10011110; //    -98 0x9E 
			7 'd 111   :rd_reg <= #1 8 'b 10100010; //    -94 0xA2 
			7 'd 112   :rd_reg <= #1 8 'b 10100111; //    -89 0xA7 
			7 'd 113   :rd_reg <= #1 8 'b 10101011; //    -85 0xAB 
			7 'd 114   :rd_reg <= #1 8 'b 10110000; //    -80 0xB0 
			7 'd 115   :rd_reg <= #1 8 'b 10110101; //    -75 0xB5 
			7 'd 116   :rd_reg <= #1 8 'b 10111010; //    -70 0xBA 
			7 'd 117   :rd_reg <= #1 8 'b 10111111; //    -65 0xBF 
			7 'd 118   :rd_reg <= #1 8 'b 11000101; //    -59 0xC5 
			7 'd 119   :rd_reg <= #1 8 'b 11001010; //    -54 0xCA 
			7 'd 120   :rd_reg <= #1 8 'b 11010000; //    -48 0xD0 
			7 'd 121   :rd_reg <= #1 8 'b 11010110; //    -42 0xD6 
			7 'd 122   :rd_reg <= #1 8 'b 11011100; //    -36 0xDC 
			7 'd 123   :rd_reg <= #1 8 'b 11100010; //    -30 0xE2 
			7 'd 124   :rd_reg <= #1 8 'b 11101000; //    -24 0xE8  
			7 'd 125   :rd_reg <= #1 8 'b 11101110; //    -18 0xEE 
			7 'd 126   :rd_reg <= #1 8 'b 11110100; //    -12 0xF4
			7 'd 127   :rd_reg <= #1 8 'b 11111010; //     -6 0xFA 
	  default : rd_reg <= #1 0;
	  endcase
	end
end

//the count signal will +<=1 for every clk period
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		count <= 7'd0;
	end
	else if(count <= 7'd126) begin
		count <= count + 7'd1;
	end
	else begin
		count <= 7'd0;
	end
end
endmodule 