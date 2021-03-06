![DSC_0095](https://user-images.githubusercontent.com/73535458/124514099-ddfa2a00-de0e-11eb-9fba-dc51d72d24b0.jpg)


# FPGAudio

This project is a set of audio processing functions on FPGA board, using Verilog language.  
The FPGA used in this project is ALETRA EP4CE10F17C8.  
The audio decoder chip used in this project is WM8978.  
The lcd display used in this project is ALIENTEK 4.3' RGBLCD 480 * 272  
Software used is Quartus 13.1 as well as Modelsim  

## Functions

There are different audio processing algorithms applied in the project and they are stored in different branches of the project. Please go to the branch page to see more details of the algorithm you want.  
1. [FFTPGA](https://github.com/Zyy438/FPGAudio/tree/FFTPGA)  
2. [FIRPGA](https://github.com/Zyy438/FPGAudio/tree/FIRPGA)    
3. [OVERDRIVE](https://github.com/Zyy438/FPGAudio/tree/OVERDRIVE) (Guitar effect pedal) 

## Fpga_uart

Another repository called Fpga_uart is also used in this project, it is used to connect the FPGA board to the host laptop(PC) to load parameters of different algorithms.  
An sdram repo may also be used for saving audio datas and implement delay function.  
Link to Fpga_uart:https://github.com/Zyy438/fpga_uart  
Link to Fpga_sdram:https://github.com/Zyy438/FPGA_sdram  (already moved to this repo, see in 'sdram' folder from main branch)
