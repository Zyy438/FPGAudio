# FPGAudio

This project is a set of audio processing functions on FPGA board, using Verilog language.
The FPGA used in this project is ALETRA EP4CE10F17C8. 
The audio decoder chip used in this project is WM8978.
The lcd display used in this project is ALIENTEK 4.3' RGBLCD 480 * 272
Software used is Quartus 13.1 as well as Modelsim

## Functions

There are different audio processing algorithms applied in the project and they are stored in different branches of the project. Below lists introduction of them.
1. FFTPGA
2. FIRPGA (still developing)
3. BEAMFORMING (not start yet)
4. OVERDRIVE (not start yet)

## Fpga_uart

Another repository called Fpga_uart is also used in this project, it is used to connect the FPGA board to the host laptop(PC) to load parameters of different algorithms.
