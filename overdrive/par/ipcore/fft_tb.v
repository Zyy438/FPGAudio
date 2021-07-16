// ================================================================================
// Legal Notice: Copyright (C) 1991-2008 Altera Corporation
// Any megafunction design, and related net list (encrypted or decrypted),
// support information, device programming or simulation file, and any other
// associated documentation or information provided by Altera or a partner
// under Altera's Megafunction Partnership Program may be used only to
// program PLD devices (but not masked PLD devices) from Altera.  Any other
// use of such megafunction design, net list, support information, device
// programming or simulation file, or any other related documentation or
// information is prohibited for any other purpose, including, but not
// limited to modification, reverse engineering, de-compiling, or use with
// any other silicon devices, unless such use is explicitly licensed under
// a separate agreement with Altera or a megafunction partner.  Title to
// the intellectual property, including patents, copyrights, trademarks,
// trade secrets, or maskworks, embodied in any such megafunction design,
// net list, support information, device programming or simulation file, or
// any other related documentation or information provided by Altera or a
// megafunction partner, remains with Altera, the megafunction partner, or
// their respective licensors.  No other licenses, including any licenses
// needed under any third party's intellectual property, are provided herein.
// ================================================================================
//

`timescale 1ns / 1ps
module fft_tb;


   //inputs
   reg clk;    
   reg reset_n;
   reg sink_valid;
   reg[16 - 1:0] sink_real;
   reg[16 - 1:0] sink_imag;
   wire [7:0]    fftpts_in;
   wire [7:0]    fftpts_out;
   wire                 inverse;
   wire                 sink_sop;
   wire                 sink_eop;
   wire                 source_ready;
   wire                 sink_ready;
   wire [1:0]           sink_error;
   
   //outputs
   wire                 source_sop;
   wire                 source_eop;
   wire                 source_valid;
   wire [1:0]           source_error;
   wire [5:0] source_exp;   
   wire [16 - 1: 0] source_real;
   wire [16 - 1: 0] source_imag;
   parameter                        NUM_FRAMES_c = 4;
   parameter                        MAXVAL_c = 2**(16 -1);
   parameter                        OFFSET_c = 2**(16);
   parameter MAXVAL_EXP_c = 2**5;
   parameter OFFSET_EXP_c = 2**6;
   integer  fftpts_array[NUM_FRAMES_c-1:0];
   
   
   reg             start;
   //number of input frames
   integer frames_in_index;
   //number of output frames
   integer frames_out_index;
   // signal the end of the input data stream and output data stream.
   integer cnt;
   reg    end_test;
   wire end_input;
   wire end_output;
   
   integer fft_rf, fft_if;
   integer expf;   
   integer data_rf,data_if;           
   integer data_real_in_int,data_imag_in_int;
   integer fft_real_out_int,fft_imag_out_int;
     integer exponent_out_int;

initial
   begin




    
     fftpts_array[0]=128;
     fftpts_array[1]=128;
     fftpts_array[2]=128;
     fftpts_array[3]=128;
     data_rf = $fopen("fft_real_input.txt","r");
     data_if = $fopen("fft_imag_input.txt","r");
     fft_rf = $fopen("fft_real_output_ver.txt");
     fft_if =$fopen("fft_imag_output_ver.txt");
     expf = $fopen("fft_exponent_output_ver.txt");
     #0 clk = 1'b0;
     #0 reset_n = 1'b0;
     #92 reset_n = 1'b1;
  end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Clock Generation                                                                         
   ///////////////////////////////////////////////////////////////////////////////////////////////
   always
     begin
       if (end_test == 1'b1 & end_output == 1'b1) 
         begin
           clk = 1'b0;
           $finish;
         end
       else
         begin
           #5 clk = 1'b1;
           #5 clk = 1'b0;
         end
     end

   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Set FFT Direction     
   // '0' => FFT      
   // '1' => IFFT
   assign inverse = 1'b0;


  //no input error
  assign sink_error = 2'b0;
     
     
  // for example purposes, the ready signal is always asserted.
  assign source_ready = 1'b1;

   ///////////////////////////////////////////////////////////////////////////////////////////////
   // All FFT MegaCore input signals are registered on the rising edge of the input clock, clk and 
   // all FFT MegaCore output signals are output on the rising edge of the input clock, clk. 
   //////////////////////////////////////////////////////////////////////////////////////////////

  // start valid for first cycle to indicate that the file reading should start.
  always @ (posedge clk)
  begin
     if (reset_n == 1'b0)
       start <= 1'b1;
     else
       begin
         if (sink_valid == 1'b1 & sink_ready == 1'b1)
           start <= 1'b0;
       end
   end

  //sop and eop asserted in first and last sample of data
  always @ (posedge clk)
  begin
    if (reset_n == 1'b0)
      cnt <= 0;
    else
      begin
        if (sink_valid == 1'b1 & sink_ready == 1'b1)
          begin
             if (cnt == fftpts_array[frames_in_index] - 1)
               cnt <= 0;
             else
               cnt <= cnt + 1;
          end
      end
  end

  assign fftpts_in =  fftpts_array[frames_in_index];

  // count the input frames and increment the index
  always @(posedge clk)
    begin
       if (reset_n == 1'b0)
         frames_in_index <= 0;
       else
         begin
            if (sink_eop == 1'b1 & sink_valid == 1'b1 & sink_ready == 1'b1 & frames_in_index < NUM_FRAMES_c -1)
              frames_in_index <= frames_in_index + 1;
         end
    end 

   // count the output frames and increment the index
   always @(posedge clk)
    begin
       if (reset_n == 1'b0)
        frames_out_index <= 0;
       else
         begin
            if (source_eop == 1'b1 &  source_valid == 1'b1 & source_ready == 1'b1 & frames_out_index < NUM_FRAMES_c -1)
              frames_out_index <= frames_out_index + 1;
         end
    end 

   // signal when all of the input data has been sent to the DUT
   assign end_input = (sink_eop == 1'b1 & sink_valid == 1'b1 & sink_ready == 1'b1 & frames_in_index == NUM_FRAMES_c - 1) ? 1'b1 : 1'b0;
    
   // signal when all of the output data has be received from the DUT
   assign end_output = (source_eop == 1'b1 & source_valid == 1'b1 & source_ready == 1'b1 & frames_out_index == NUM_FRAMES_c - 1) ? 1'b1 : 1'b0;
  

   // generate start and end of packet signals
   assign sink_sop = (cnt == 0) ? 1'b1 : 1'b0 ;
   assign sink_eop = ( cnt == fftpts_array[frames_in_index] - 1 ) ? 1'b1 : 1'b0;

   //halt the input when done
    always @(posedge clk)
      begin
        if (reset_n == 1'b0)
          end_test <= 1'b0;
        else
          begin
            if (end_input == 1'b1)
             end_test <= 1'b1; 
          end
      end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   // Read input data from files. Data is generated on the negative edge of the clock, clk, in the
   // testbench and registered by the core on the positive edge of the clock                                                                    \n";
   ///////////////////////////////////////////////////////////////////////////////////////////////
   integer rc_x;
   integer ic_x;
   always @ (posedge clk)
     begin
        if(reset_n==1'b0)
          begin
             sink_real<=16'b0;
             sink_imag<=16'b0;
             sink_valid <= 1'b0;
          end
        else
          begin
             // send in NUM_FRAMES_c of data or until the end of the file
             if((end_test == 1'b1) || (end_input == 1'b1))
               begin
                  sink_real<=16'b0;
                  sink_imag<=16'b0;
                  sink_valid <= 1'b0;
               end
             else
               begin
                  if ((sink_valid == 1'b1 & sink_ready == 1'b1 ) ||
                      (start == 1'b1 & !(sink_valid == 1'b1 & sink_ready == 1'b0)))
                    begin
                       rc_x = $fscanf(data_rf,"%d",data_real_in_int);
                       sink_real <= data_real_in_int;
                       ic_x = $fscanf(data_if,"%d",data_imag_in_int); 
                       sink_imag <= data_imag_in_int;
                       sink_valid <= 1'b1;
                    end 
                  else
                    begin
                       sink_real<=sink_real;
                       sink_imag<=sink_imag;
                       sink_valid <= 1'b1;
                    end
               end
          end
     end

   //////////////////////////////////////////////////////////////////////////////////////////////
   // Write Real and Imginary Data Components and Block Exponent to Disk                         
   //////////////////////////////////////////////////////////////////////////////////////////////
   always @ (posedge clk) 
     begin
        if((reset_n==1'b1) & (source_valid == 1'b1 & source_ready == 1'b1))
          begin
             fft_real_out_int = source_real;
             fft_imag_out_int = source_imag;
             $fdisplay(fft_rf, "%d", (fft_real_out_int < MAXVAL_c) ? fft_real_out_int : fft_real_out_int - OFFSET_c);
             $fdisplay(fft_if, "%d", (fft_imag_out_int < MAXVAL_c) ? fft_imag_out_int : fft_imag_out_int - OFFSET_c);
             exponent_out_int = source_exp;
            $fdisplay(expf, "%d", (exponent_out_int < MAXVAL_EXP_c) ? exponent_out_int : exponent_out_int - OFFSET_EXP_c);
          end
        end

    ///////////////////////////////////////////////////////////////////////////////////////////////
   // FFT Module Instantiation                                                               
   /////////////////////////////////////////////////////////////////////////////////////////////
   fft dut(
                      .clk(clk),
                      .reset_n(reset_n),
                      .inverse(inverse),
                      .sink_real(sink_real),
                      .sink_imag(sink_imag),
                      .sink_sop(sink_sop),
                      .sink_eop(sink_eop),
                      .sink_valid(sink_valid),
                      .sink_error(sink_error),
                      .source_error(source_error),
                      .source_ready(source_ready),
                      .sink_ready(sink_ready),
                      .source_real(source_real),
                      .source_imag(source_imag),
                      .source_exp(source_exp),
                      .source_valid(source_valid),
                      .source_sop(source_sop),
                      .source_eop(source_eop)
                      );
endmodule                                                                                                 
