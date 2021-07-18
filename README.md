
# OVERDRIVE

An overdrive guitar pedal achieved by FPGA board.   
This project is an overdrive guitar pedal achieved by FPGA board, using Verilog language.  
The structure is based on FFTPGA (or FIRPGA, fir module replaced by an overdrive module)
The FPGA used in this project is ALETRA EP4CE10F17C8.  
The audio decoder chip used in this project is WM8978.  
The lcd display used in this project is ALIENTEK 4.3' RGBLCD 480 * 272  
Software used is Quartus 13.1 as well as Modelsim  

## How to use

1. download the portfolio file firpga.7z.
2. open the .qpf file in the 'par' folder by Quartus 13.1 or higher.
3. Assign the pins according to the FPGA used and compile the project
4. Program the .sof file to the FPGA board
5. Connect the FPGA with your guitar(throuogh .adcdat port)
6. Connect the FPGA with an guitar amplifier or an audio interface(throuogh .dacdat port)
7. connect the FPGA with a LCD display (change the parameters if different resolution screens are applied, the default resolution in this project is 480*272)
8. play the audio files and you shall see the spectrum of the audio on the lcd display
9. if the input signal 'key0' becomes 0, the output sound will be origional sound. Otherwise it will be overdrive sound.
10. To adjust the amount of distortion, plz go adjust the parameter 'threshold' in the u_overdrive module. The lower it is, the more distortion there will be.

## Default tone

https://user-images.githubusercontent.com/73535458/126059102-9cc2f543-d324-4aa7-ae13-00e42ddf886e.mp4

