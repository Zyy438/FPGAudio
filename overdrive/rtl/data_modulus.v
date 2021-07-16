/*
9/7/2021 
written by Zyy Zhou (22670661)
used for ELEC5551 design project2 fir filter

the output of the fft module has 32 bits. However, it is actually a complex number. Thus getting its modulus to
be the length of the bar is necessary. In this module, an ip-core called sqrt is used to ge the desquare number
of the square sum of the real and imaginary part.

also, the incoming signal fft_sop, fft_eop, as well as fft_valid are all delayed 3 clk periods.
*/

module data_modulus (
	input              sys_clk,
	input              sys_rst,
	//connect to fft module interface
	input     [15:0]         source_real,  //real part of the fft data
	input     [15:0]         source_imag,  //imaginary part ofthe fft data
	input                    source_sop,
	input                    source_eop,  //start and the end of a data segment (1 and 128)
	input                    source_valid, //coming from the fft module
	
	
	output    [15:0]         data_modulus, //modulus of the data, go to the lcd part as the length of the bar
	output     reg           data_sop,     //this is just a processing module of the output fft data,
	output     reg           data_eop,     //there will be 3 clk period delay compared to the input sop and eop.
	output     reg           data_valid   //delay this signal for 3 clk period as welll	
); 

//parameter define

//reg define
reg     [31:0]       source_data;      //32 bits data coming from the fft
reg     [15:0]         data_real;    //real part of the incoming data
reg     [15:0]         data_imag;    //imaginary part of the incoming data
//the regs below are used to delay the data_sop, data_eop and data_valid for 3 clk periods.
reg                    data_sop1;
reg                    data_sop2;
reg                    data_eop1;
reg                    data_eop2;
reg                    data_valid1;
reg                    data_valid2;

//wire define

//*************************************************************************************
//                      main   code
//*************************************************************************************

always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		source_data <= 32'd0;
		data_real <= 16'd0;
		data_imag  <= 16'd0;
	end
	else begin
		if(source_real[15] == 1'b0)      //the complement, find out source code according to it
			data_real <= source_real;
		else
			data_real <= ~source_real + 1'b1;
		
		if(source_imag[15] == 1'b0)      //do the same thing for the imaginary part
			data_imag <= source_imag;
		else
			data_imag <= ~source_imag + 1'b1;
		//now we get the imaginary and real part of the fft output data
		
		//calculate the square sum if the two parts, do not do de-square yet
		source_data <= (data_real*data_real)+(data_imag*data_imag);
	end
end
 
//now, the reg source_data is the quare sum of the two parts, we just need to do a de_square on it and 
//we can ge the length of the bar(actually the magnitude of the point in the spectrum)
//use the sqrt ip-core to do it!

sqrt sqrt_inst(
	.clk            (sys_clk),
	.radical        (source_data),
	
	.q              (data_modulus), //output
	.remainder      ()
);

//delay the sop, eop, and valid signal for 3 clk period cause the calculation in this module 
//totally costs 3 clk periods.

always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		data_sop <= 1'b0;
		data_sop1 <= 1'b0;
		data_sop2 <= 1'b0;
		data_eop <= 1'b0;
		data_eop1 <= 1'b0;
		data_eop2 <= 1'b0;
		data_valid <= 1'b0;
		data_valid1 <= 1'b0;
		data_valid2 <= 1'b0;
	end
	else begin
		//for data valid
		data_valid1 <= source_valid;
		data_valid2 <= data_valid1;
		data_valid <= data_valid2;
		//for data_sop
		data_sop1 <= source_sop;
		data_sop2 <= data_sop1;
		data_sop <= data_sop2;
		//for data_eop
		data_eop1 <= source_eop;
		data_eop2 <= data_eop1;
		data_eop <= data_eop2;
	end
end

endmodule
