/*
9/7/2021
Zyy Zhou(22670661)  
used for elec5552 design2 project
this module is the FFT top entity, one of the main modules in FFTPGA functioin
*/

module fft_top (
	input              sys_clk,
	input              sys_rst,
	
	//connect to the audio interface(WM8978 driver)
	input              audio_clk,
	input      [15:0]  audio_data,
	input              audio_valid,
	
	//connect to the lcd module
	output             data_sop,  //start of a signal segment
	output             data_eop,  //end of a signal segment
	output             data_valid,   //the above 3 signals are delayed for 3 clk period.
	output   [15:0]    data_modulus  //the length of the bar
);

//parameter define


//reg define


//wire define
wire    [15:0]        audio_data_w;
wire                  fifo_rdreq;
wire                  iffo_rdempty;
//go to the fft module (from fifo)
wire                  fft_rst_n;
wire                  fft_sop;
wire                  fft_eop;
wire                  fft_valid;
wire                  fft_ready;
//go to the data modulus module(from fft)
wire    [15:0]        source_real;
wire    [15:0]        source_imag;
wire                  source_valid;
wire                  source_sop;
wire                  source_eop;

//****************************************************************
//                  main    code
//****************************************************************
//it is actually not a perfect fifo because there is no full data warning,thus data may be lost
audio_in_fifo fifo_inst(
	.aclr            (~sys_rst),
	.wrclk           (audio_clk),   //the audio interface write the fifo, the fft just read
	.wrreq           (audio_valid), //if there is a audio coming then request for writing
	.data            (audio_data),  //data ccoming from the audio interface [16bits]
	.rdclk           (sys_clk),     //fft is reading the data in it and it works in 50MHz
	.rdreq           (fifo_rdreq),  //coming from the fft_ctrl module indicating there is a read request
	.q               (audio_data_w), //output of the data in the fifo
	.rdempty         (fifo_rd_empty) //output signal, indicating that there is no signal in the fifo
);

//fifo control module
fft_fifo_ctrl  u_fft_ctrl(
	.sys_clk           (sys_clk),
	.sys_rst           (sys_rst),
	//connect to the fifo
	.fifo_rd_empty     (fifo_rd_empty),  //coming from the fifo, no data in the fifo if it is 1
	.fifo_rdreq        (fifo_rdreq),  //send a read request signal to the fifo
	//connect to the FFT
	.fft_eop           (fft_eop),  //indicating fft the start or end of a data segment 
	.fft_sop           (fft_sop),
	.fft_valid         (fft_valid),
	.fft_rst_n         (fft_rst_n), //go to the fft and release it after 32 clk periods when sys_rst is pressed
	.fft_ready         (fft_ready)  //coming from the fft module, indicating that it is fuckin ready
);

//FFT ip-core
fft u_fft(
	.clk               (sys_clk),  //the ip-core works in a 50MHz frequency clk signl
	//connected to the fifo_ctrl module
	.reset_n           (fft_rst_n), //not directly connect to sys_rst, it is controlled by the fifo_ctrl module
	.sink_ready        (fft_ready), 
	.sink_real         (audio_data_w), //coming from the fifo (not fifo_ctrl), it is the audio data in time domain
	.sink_imag         (16'd0),   //there is only real data in the input data
	.sink_sop          (fft_sop),  //input from the fifo ctrl
	.sink_eop          (fft_eop),  //input from the fifo ctrl
	.sink_valid        (fft_valid),  //output to the fifo_ctrl
	.inverse           (1'b0),     //never inverse
	.sink_error        (1'b0),     //no error we are perfect!
	//connected to the data_modulus module
	.source_ready      (1'b1),
	.source_real       (source_real),  //real part of the fft output data (16bits)
	.source_imag       (source_imag),
	.source_sop        (source_sop),
	.source_eop        (source_eop),
	.source_valid      (source_valid),
	.source_exp        (), //wtf is this?
	.source_error      ()  //no error in this side as well
);

//data_modulus module
data_modulus u_data_modulus (
	.sys_clk           (sys_clk),
	.sys_rst           (sys_rst),
	//connect to the fft module
	.source_real       (source_real),
	.source_imag       (source_imag), //real and imaginary data coming from the fft module
	.source_sop        (source_sop),
	.source_eop        (source_eop), // coming from the fft module
	.source_valid      (source_valid), //coming from the fft module
	//connect to the output of the whole fft_top module
	.data_modulus      (data_modulus),  //length of the bar
	.data_sop          (data_sop),    
	.data_eop          (data_eop),
	.data_valid        (data_valid)   //they are delayed for 3 clk periods
);

endmodule
