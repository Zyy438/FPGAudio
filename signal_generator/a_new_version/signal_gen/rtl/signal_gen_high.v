module signal_gen_high(
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

			7 'd 1     :rd_reg <= #1 8 'b 00001100; //     12 0xC 

			7 'd 2     :rd_reg <= #1 8 'b 00011000; //     24 0x18 

			7 'd 3     :rd_reg <= #1 8 'b 00100100; //     36 0x24 

			7 'd 4     :rd_reg <= #1 8 'b 00110000; //     48 0x30 

			7 'd 5     :rd_reg <= #1 8 'b 00111011; //     59 0x3B 

			7 'd 6     :rd_reg <= #1 8 'b 01000110; //     70 0x46 

			7 'd 7    :rd_reg <= #1 8 'b 01010000; //     80 0x50 

			7 'd 8    :rd_reg <= #1 8 'b 01011001; //     89 0x59 

			7 'd 9    :rd_reg <= #1 8 'b 01100010; //     98 0x62 

			7 'd 10    :rd_reg <= #1 8 'b 01101001; //    105 0x69 

			7 'd 11    :rd_reg <= #1 8 'b 01110000; //    112 0x70 

			7 'd 12    :rd_reg <= #1 8 'b 01110101; //    117 0x75 

			7 'd 13    :rd_reg <= #1 8 'b 01111001; //    121 0x79 

			7 'd 14    :rd_reg <= #1 8 'b 01111100; //    124 0x7C 

			7 'd 15    :rd_reg <= #1 8 'b 01111110; //    126 0x7E 

			7 'd 16    :rd_reg <= #1 8 'b 01111111; //    127 0x7F 

			7 'd 17    :rd_reg <= #1 8 'b 01111110; //    126 0x7E 

			7 'd 18    :rd_reg <= #1 8 'b 01111100; //    124 0x7C 

			7 'd 19    :rd_reg <= #1 8 'b 01111001; //    121 0x79 

			7 'd 20    :rd_reg <= #1 8 'b 01110101; //    117 0x75 

			7 'd 21    :rd_reg <= #1 8 'b 01110000; //    112 0x70 

			7 'd 22    :rd_reg <= #1 8 'b 01101001; //    105 0x69 

			7 'd 23    :rd_reg <= #1 8 'b 01100010; //     98 0x62 

			7 'd 24    :rd_reg <= #1 8 'b 01011001; //     89 0x59 

			7 'd 25    :rd_reg <= #1 8 'b 01010000; //     80 0x50 

			7 'd 26    :rd_reg <= #1 8 'b 01000110; //     70 0x46 

			7 'd 27    :rd_reg <= #1 8 'b 00111011; //     59 0x3B 

			7 'd 28    :rd_reg <= #1 8 'b 00110000; //     48 0x30 

			7 'd 29    :rd_reg <= #1 8 'b 00100100; //     36 0x24 

			7 'd 30    :rd_reg <= #1 8 'b 00011000; //     24 0x18 

			7 'd 31    :rd_reg <= #1 8 'b 00001100; //     12 0xC 

			7 'd 32    :rd_reg <= #1 8 'b 00000000; //      0 0x0 

			7 'd 33    :rd_reg <= #1 8 'b 11110100; //    -12 0xF4 

			7 'd 34    :rd_reg <= #1 8 'b 11101000; //    -24 0xE8 

			7 'd 35    :rd_reg <= #1 8 'b 11011100; //    -36 0xDC 

			7 'd 36    :rd_reg <= #1 8 'b 11010000; //    -48 0xD0 

			7 'd 37    :rd_reg <= #1 8 'b 11000101; //    -59 0xC5 

			7 'd 38    :rd_reg <= #1 8 'b 10111010; //    -70 0xBA 

			7 'd 39    :rd_reg <= #1 8 'b 10110000; //    -80 0xB0 

			7 'd 40    :rd_reg <= #1 8 'b 10100111; //    -89 0xA7 

			7 'd 41    :rd_reg <= #1 8 'b 10011110; //    -98 0x9E 

			7 'd 42    :rd_reg <= #1 8 'b 10010111; //   -105 0x97 

			7 'd 43    :rd_reg <= #1 8 'b 10010000; //   -112 0x90 

			7 'd 44    :rd_reg <= #1 8 'b 10001011; //   -117 0x8B 

			7 'd 45    :rd_reg <= #1 8 'b 10000111; //   -121 0x87 

			7 'd 46    :rd_reg <= #1 8 'b 10000100; //   -124 0x84 

			7 'd 47    :rd_reg <= #1 8 'b 10000010; //   -126 0x82 

			7 'd 48    :rd_reg <= #1 8 'b 10000001; //   -127 0x81 

			7 'd 49    :rd_reg <= #1 8 'b 10000010; //   -126 0x82 

			7 'd 50   :rd_reg <= #1 8 'b 10000100; //   -124 0x84 

			7 'd 51   :rd_reg <= #1 8 'b 10000111; //   -121 0x87 

			7 'd 52   :rd_reg <= #1 8 'b 10001011; //   -117 0x8B 

			7 'd 53   :rd_reg <= #1 8 'b 10010000; //   -112 0x90 

			7 'd 54   :rd_reg <= #1 8 'b 10010111; //   -105 0x97 

			7 'd 55   :rd_reg <= #1 8 'b 10011110; //    -98 0x9E 

			7 'd 56   :rd_reg <= #1 8 'b 10100111; //    -89 0xA7 

			7 'd 57   :rd_reg <= #1 8 'b 10110000; //    -80 0xB0 

			7 'd 58   :rd_reg <= #1 8 'b 10111010; //    -70 0xBA 

			7 'd 59   :rd_reg <= #1 8 'b 11000101; //    -59 0xC5 

			7 'd 60   :rd_reg <= #1 8 'b 11010000; //    -48 0xD0 

			7 'd 61   :rd_reg <= #1 8 'b 11011100; //    -36 0xDC 

			7 'd 62   :rd_reg <= #1 8 'b 11101000; //    -24 0xE8  

			7 'd 63   :rd_reg <= #1 8 'b 11110100; //    -12 0xF4

	  default : rd_reg <= #1 0;
	  endcase
	end
end

//the count signal will +<=1 for every clk period
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		count <= 7'd0;
	end
	else if(count <= 7'd62) begin
		count <= count + 7'd1;
	end
	else begin
		count <= 7'd0;
	end
end
endmodule 