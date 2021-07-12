/*
09/07/2021
written by Zyy zhou (22670661)
this moudule is used for ELEC5552 design2 FFTPGA, to control the data flow
between the fifo and the fast fourier transform ip-core.
since the audio input has a lower frequency clk 'aud_bclk'(around 12.28MHz)
when communicating with the fft module(working in a 50MHz clk), an fifo module 
between them can effectively reduce the chance that metastable state happens.

the module has two working state. this is controled by a state machine reg signal
called 'state'. when press the rst button, the signal will go to the first state
(state=1'b0), then it will hold the fft_rst_n signal for 32 clk period to let fft get reset.
after 32 clk period, it will release the fft_rst_n signal and go to next state.

in the second state, the module will firstly judge whether there is data in the fifo
by the signal fifo_rd_empty, if there is, it will pull the fft_valid signal high and enable 
the fft module. Then, start a counter to count which bit it is in the data segment and
so that enable the fft_eop signal as well as the fft_sop signal. the depth of the fft is 128 bits,
therefore, the counter will be reset to 10'd1 when it comes to 128.

the fft ip-core used in this project has a 128 sample width. So, a segment of signal
sent to the ip-core should have 128 bits. a reg counting this is called fft_cnt. 
It will be reset to 0 after it becomes 128. when it is 1, output sop shall be 1,
when it is 128, output fft_eop shall be 1.
*/

module fft_fifo_ctrl (
	//system clk and rst
	input             sys_clk,
	input             sys_rst,
	//connected to the fifo module
	input             fifo_rd_empty,  //indicating that there is no data in the fifo if '1'
	output            fifo_rdreq,     //send read request signal
	//coming from the fft ip-core
	input             fft_ready,      //indicating that the fft is ready if '1'
	
	//outputs to the fft ip-core
	output            fft_eop,        //sign of the end of a segment of signal
	output            fft_sop,        //sign of the start of a segment of sigal
   output    reg     fft_rst_n,      //if it is 0, it means that the rst button of the fft ip-core is pressed
   output    reg     fft_valid       //connected to the fft ip-core.	
);

//parameter define


//reg define
reg           state;         //working state of this module 
reg   [4:0]   delay_cnt;     //in the first state count a specific period of time and release the rst button of fft
reg   [9:0]   fft_cnt;       //
reg           rd_en;         //a signal to enable the output signal fifo_rdreq

//wire define


//******************************************************************************************
//                main code
//******************************************************************************************
//if there is data in the fifo and the module is in the second(state=1'b1) state
//pull the fifo_rdreq signal high to ask for a signal  
assign fifo_rdreq = rd_en && (~fifo_rd_empty); 
//if it is the first or last bit of a signal segment, the sop or eop signal shall pull high accordingly.
assign fft_sop = (fft_cnt == 10'd1)? fft_valid : 1'b0;
assign fft_eop = (fft_cnt == 10'd128)? fft_valid : 1'b0;

always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		state <= 1'b0;
		rd_en <= 1'b0;
		fft_valid <= 1'b0;
		fft_rst_n <= 1'b0;
		fft_cnt <= 10'd0;
		delay_cnt <= 5'd0;
	end
	else begin
		case (state)
			1'b0: begin //if we just pressed the reset button,delay for 32 clk period
				fft_valid <= 1'b0;
				fft_cnt <= 10'd0;  //do not start reuesting data
				
				if(delay_cnt < 5'd31) begin
					delay_cnt <= delay_cnt + 1'b1;
					fft_rst_n <= 1'b0;   //keep pressing the reset button if time is not enough
				end
				else begin
					delay_cnt <= delay_cnt;  //if the time is enough
					fft_rst_n <= 1'b1;   //release the reset button
				end
				
				if ((delay_cnt == 5'd31)&&(fft_ready)) //time is enough, and also the fft ip-core
																	//is ready, then go to next state and start sendig signal.
					state <= 1'b1;
				else 
					state <= 1'b0;
			end	
			1'b1: begin
				if (!fifo_rd_empty)
					rd_en <= 1'b1;
				else
					rd_en <= 1'b0;
				
				if (fifo_rdreq)  begin   //start communication, if there is data in the fifo
					fft_valid <= 1'b1;
					if(fft_cnt < 10'd128)    //start counting which bit it is at a signal segment at the moment	
						fft_cnt <= fft_cnt + 1'b1;
					else
						fft_cnt <= 10'd1;
				end
				else begin             //stop communication if there is no data in the fifo
					fft_valid <= 1'b0;
					fft_cnt <= fft_cnt;
				end
			end
			default:state <= 1'b0;	
		endcase
	end
end

endmodule
