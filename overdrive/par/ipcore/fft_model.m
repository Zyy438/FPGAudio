% function [y, exp_out] = fft_model(x,N,INVERSE)         
%                                                                                           
%   calculates the complex block-floating point FFT/IFFT of length N of a                  
%   complex input vector x                                                                   
%                                                                                            
%   Inputs:   x          : Input complex vector of length B*N, where B is                     
%                          the number of blocks over which the length-N FFT is to          
%                          be applied. If the length of the vector is not                    
%                          an integral multiple of N, zeros are                               
%                          appended to the input sequence appropriately.                     
%             N          : Transform Length                                                  
%             INVERSE    : FFT direction                                                     
%                          0 => FFT                                                          
%                          1 => IFFT                                                          
%                                                                                          
%   Outputs   y          : The transform-domain complex vector output                        
%             exp_out    : Block exponent value                                               
%                                                                                            
%   2001-2009 Altera Corporation, All Rights Reserved 
%                                                                                                  
%   Automatically Generated: FFT MegaCore Function 13.1 Build 162 October, 2013                                                                                                   
%
function [y, exp_out] = fft_model(x,N,INVERSE) 
addpath(strcat(getenv('QUARTUS_ROOTDIR'),'/../ip/altera/fft/lib/'));
% Parameterization Space   
THROUGHPUT=4;
ARCH=0;
DATA_PREC=16;
TWIDDLE_PREC=8;
input_vector_length = length(x);                                                              
number_of_blocks = ceil(input_vector_length/N);                                               
% Zero-stuff last block if necessary                                                          
x = [x, zeros(1,number_of_blocks * N - input_vector_length)];                                 
y=[];                                                                                         
exp_out=[];                                                                                   
for i=1:number_of_blocks                                                                      
    rin = real(x((i-1)*N + 1: i*N));                                                          
    iin = imag(x((i-1)*N + 1: i*N));                                                          
    [roc,ioc,eoc] = Sfftmodel(rin,iin,N,THROUGHPUT,ARCH,DATA_PREC,TWIDDLE_PREC,INVERSE);      
    y = [y, roc+j*ioc];                                                                       
    exp_out = [exp_out, eoc];                                                                 
end                                                                                           
  
