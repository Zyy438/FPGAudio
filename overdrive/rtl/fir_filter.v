/*
14/7/2021
Written by Zyy Zhou(22670661)
A fir module to get signal from the wm8978 ctrl module and then do fir filtering, then send the audio data to the fft module
order this time is 31, which means that we have 32 coefficients this time. It is designed to be a 3-stage pipline. The first stage is just 
to load the data and give them a delay. the input 16bits data will be going into a matrix called samples sequencially. then the 
different data will be combined with the corresponding parameters(coefficients) in the second stage. in the 3rd stage, the output will
add all the mults together and thus get the output data.

*/

module fir_filter(
	input                 aud_bclk,
	input                 rst_n,
	//audio in
	input                 rx_done,
	input         [15:0]  adc_data,
	//output signals 
	output    reg [33:0]  fir_data,
	output    reg         fir_valid
);

//parameter define
integer i;
parameter    coe0=16'hff72;
parameter    coe1=16'hffef;
parameter    coe2=16'h00c9;
parameter    coe3=16'h0201;
parameter    coe4=16'h02fe;
parameter    coe5=16'h028f;
parameter    coe6=16'hff93;
parameter    coe7=16'hfa0e;
parameter    coe8=16'hf3ff;
parameter    coe9=16'hf144;
parameter    coe10=16'hf645;
parameter    coe11=16'h05ce;
parameter    coe12=16'h1f1e;
parameter    coe13=16'h3d47;
parameter    coe14=16'h586a;
parameter    coe15=16'h6881;
parameter    coe16=16'h6881;
parameter    coe17=16'h586a;
parameter    coe18=16'h3d47;
parameter    coe19=16'h1f1e;
parameter    coe20=16'h05ce;
parameter    coe21=16'hf645;
parameter    coe22=16'hf144;
parameter    coe23=16'hf3ff;
parameter    coe24=16'hfa0e;
parameter    coe25=16'hff93;
parameter    coe26=16'h028f;
parameter    coe27=16'h02fe;
parameter    coe28=16'h0201;
parameter    coe29=16'h00c9;
parameter    coe30=16'hffef;
parameter    coe31=16'hff72;

//define the 32 coefficients of the filter

//reg define
reg   [15:0] samples [31:0];
//registers temporarily save the value combined by input 15bits data and the coefficients
reg   [33:0] mult0;
reg   [33:0] mult1;
reg   [33:0] mult2;
reg   [33:0] mult3;
reg   [33:0] mult4;
reg   [33:0] mult5;
reg   [33:0] mult6;
reg   [33:0] mult7;
reg   [33:0] mult8;
reg   [33:0] mult9;
reg   [33:0] mult10;
reg   [33:0] mult11;
reg   [33:0] mult12;
reg   [33:0] mult13;
reg   [33:0] mult14;
reg   [33:0] mult15;
reg   [33:0] mult16;
reg   [33:0] mult17;
reg   [33:0] mult18;
reg   [33:0] mult19;
reg   [33:0] mult20;
reg   [33:0] mult21;
reg   [33:0] mult22;
reg   [33:0] mult23;
reg   [33:0] mult24;
reg   [33:0] mult25;
reg   [33:0] mult26;
reg   [33:0] mult27;
reg   [33:0] mult28;
reg   [33:0] mult29;
reg   [33:0] mult30;
reg   [33:0] mult31;
//wire define

//*****************************************************************************************************
//                            main code
//*****************************************************************************************************

//////////////////////////////////////
///           stage 1              ///
//////////////////////////////////////

always @(posedge aud_bclk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<31;i=i+1)
			samples[i]<=0;
	end
	else if(rx_done)begin    //a pipline to iterate the data input
		samples[0]<=adc_data;
		samples[1]<=samples[0];
		samples[2]<=samples[1];
		samples[3]<=samples[2];
		samples[4]<=samples[3];
		samples[5]<=samples[4];
		samples[6]<=samples[5];
		samples[7]<=samples[6];
		samples[8]<=samples[7];
		samples[9]<=samples[8];
		samples[10]<=samples[9];
		samples[11]<=samples[10];
		samples[12]<=samples[11];
		samples[13]<=samples[12];
		samples[14]<=samples[13];
		samples[15]<=samples[14];
		samples[16]<=samples[15];
		samples[17]<=samples[16];
		samples[18]<=samples[17];
		samples[19]<=samples[18];
		samples[20]<=samples[19];
		samples[21]<=samples[20];
		samples[22]<=samples[21];
		samples[23]<=samples[22];
		samples[24]<=samples[23];
		samples[25]<=samples[24];
		samples[26]<=samples[25];
		samples[27]<=samples[26];
		samples[28]<=samples[27];
		samples[29]<=samples[28];
		samples[30]<=samples[29];
		samples[31]<=samples[30];
		end
		else begin
		samples[0]<=samples[0];
		samples[1]<=samples[1];
		samples[2]<=samples[2];
		samples[3]<=samples[3];
		samples[4]<=samples[4];
		samples[5]<=samples[5];
		samples[6]<=samples[6];
		samples[7]<=samples[7];
		samples[8]<=samples[8];
		samples[9]<=samples[9];
		samples[10]<=samples[10];
		samples[11]<=samples[11];
		samples[12]<=samples[12];
		samples[13]<=samples[13];
		samples[14]<=samples[14];
		samples[15]<=samples[15];
		samples[16]<=samples[16];
		samples[17]<=samples[17];
		samples[18]<=samples[18];
		samples[19]<=samples[19];
		samples[20]<=samples[20];
		samples[21]<=samples[21];
		samples[22]<=samples[22];
		samples[23]<=samples[23];
		samples[24]<=samples[24];
		samples[25]<=samples[25];
		samples[26]<=samples[26];
		samples[27]<=samples[27];
		samples[28]<=samples[28];
		samples[29]<=samples[29];
		samples[30]<=samples[30];
		samples[31]<=samples[31];
	end
end

//////////////////////////////////////
///           stage 2              ///
//////////////////////////////////////

//multiple with coefficients0
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult0 <= 34'd0;
	else
		mult0 <=samples[0]*coe0;
end

//multiple with coefficients1
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult1 <= 34'd0;
	else
		mult1 <=samples[1]*coe1;
end

//multiple with coefficients2
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult2 <= 34'd0;
	else
		mult2 <=samples[2]*coe2;
end

//multiple with coefficients3
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult3 <= 34'd3;
	else
		mult3 <=samples[3]*coe3;
end

//multiple with coefficients4
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult4 <= 34'd0;
	else
		mult4 <=samples[4]*coe4;
end

//multiple with coefficients5
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult5 <= 34'd0;
	else
		mult5 <=samples[5]*coe5;
end

//multiple with coefficients6
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult6 <= 34'd0;
	else
		mult6 <=samples[6]*coe6;
end

//multiple with coefficients7
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult7 <= 34'd0;
	else
		mult7 <=samples[7]*coe7;
end

//multiple with coefficients8
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult8 <= 34'd0;
	else
		mult8 <=samples[8]*coe8;
end

//multiple with coefficients9
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult9 <= 34'd0;
	else
		mult9 <=samples[9]*coe9;
end

//multiple with coefficients10
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult10 <= 34'd0;
	else
		mult10 <=samples[10]*coe10;
end

//multiple with coefficients11
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult11 <= 34'd0;
	else
		mult11 <=samples[11]*coe11;
end

//multiple with coefficients12
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult12 <= 34'd0;
	else
		mult12 <=samples[12]*coe12;
end

//multiple with coefficients13
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult13 <= 34'd0;
	else
		mult13 <=samples[13]*coe13;
end

//multiple with coefficients14
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult14 <= 34'd0;
	else
		mult14 <=samples[14]*coe14;
end

//multiple with coefficients15
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult15 <= 34'd0;
	else
		mult15 <=samples[15]*coe15;
end

//multiple with coefficients16
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult16 <= 34'd0;
	else
		mult16 <=samples[16]*coe16;
end

//multiple with coefficients17
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult17 <= 34'd0;
	else
		mult17 <=samples[17]*coe17;
end

//multiple with coefficients18
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult18 <= 34'd0;
	else
		mult18 <=samples[18]*coe18;
end

//multiple with coefficients19
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult19 <= 34'd0;
	else
		mult19 <=samples[19]*coe19;
end

//multiple with coefficients20
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult20 <= 34'd0;
	else
		mult20 <=samples[20]*coe20;
end

//multiple with coefficients21
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult21 <= 34'd0;
	else
		mult21 <=samples[21]*coe21;
end

//multiple with coefficients22
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult22 <= 34'd0;
	else
		mult22 <=samples[22]*coe22;
end

//multiple with coefficients23
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult23 <= 34'd0;
	else
		mult23 <=samples[23]*coe23;
end

//multiple with coefficients24
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult24 <= 34'd0;
	else
		mult24 <=samples[24]*coe24;
end

//multiple with coefficients25
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult25 <= 34'd0;
	else
		mult25 <=samples[25]*coe25;
end

//multiple with coefficients26
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult26 <= 34'd0;
	else
		mult26 <=samples[26]*coe26;
end

//multiple with coefficients27
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult27 <= 34'd0;
	else
		mult27 <=samples[27]*coe27;
end

//multiple with coefficients28
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult28 <= 34'd0;
	else
		mult28 <=samples[28]*coe28;
end

//multiple with coefficients29
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult29 <= 34'd0;
	else
		mult29 <=samples[29]*coe29;
end

//multiple with coefficients30
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult30 <= 34'd0;
	else
		mult30 <=samples[30]*coe30;
end

//multiple with coefficients31
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		mult31 <= 34'd0;
	else
		mult31 <=samples[31]*coe31;
end


//////////////////////////////////////
///           stage 3              ///
//////////////////////////////////////

//add all the mults together and get the output of the fir filter at the moment
always @(posedge aud_bclk or negedge rst_n)begin
	if(!rst_n)
		fir_data <= 34'd0;
	else 
		fir_data <= mult0+mult1+mult2+mult3+mult4+mult5+mult6+mult7+mult8+mult9+mult10+mult11+mult12+mult13+mult14+mult15+mult16+
		mult17+mult18+mult19+mult20+mult21+mult22+mult23+mult24+mult25+mult26+mult27+mult28+mult29+mult30+mult31;
end

endmodule
