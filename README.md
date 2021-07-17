
# FIRPGA

This project is a set of audio processing functions on FPGA board, using Verilog language.  
The FPGA used in this project is ALETRA EP4CE10F17C8.  
The audio decoder chip used in this project is WM8978.  
The lcd display used in this project is ALIENTEK 4.3' RGBLCD 480 * 272  
Software used is Quartus 13.1 as well as Modelsim  

## how to use

1. download the portfolio file firpga.7z.
2. open the .qpf file in the 'par' folder by Quartus 13.1 or higher.
3. Assign the pins according to the FPGA used and compile the project
4. Program the .sof file to the FPGA board
5. Connect the FPGA with an audio input(throuogh .adcdat port)
6. Connect the FPGA with an amplifier(throuogh .dacdat port)
7. connect the FPGA with a LCD display (change the parameters if different resolution screens are applied, the default resolution in this project is 480*272)
8. play the audio files and you shall see the spectrum of the audio on the lcd display
9. if the input signal 'key0' becomes 0, the output sound will be filtered by a fir filter. The effect can be heard, or seen from the spectrum shown by the lcd display. 

note: an fft ip-core is used in the fft module. The ip-core can only last for 60 mins after compilation if a liscence is not provided. Which means, if you do not purchase the ip-core, the spectrum will disappear after 60mins since the project is compiled. However, if the spectrum is not needed, delecting the fft module as well as the lcd module will pose no influence to the fir filter and the WM8978 driver.

## Linear time invarient system

### time invarient

A system is called a time invarient system if its response to the input signal does not change as time goes by. Which means, for a time invarient system, the output of the system will be moved for n time index if the input is moved for n time index. This can be discribed by a relationship shown below[1]:

![image](https://user-images.githubusercontent.com/73535458/126027039-24c93670-bdee-4519-b00d-acd13603f8a9.png)

### linear system

Usually, a system is called a linear system when it satisfies superposition principle. We can say that a system is a linear system when it satisfies the requirements shown below:

![image](https://user-images.githubusercontent.com/73535458/126026968-df481ef8-c5f2-467e-86e9-bad52a1eaa56.png)

![image](https://user-images.githubusercontent.com/73535458/126027207-561a6440-72e9-4b6d-a358-f1b5095e5458.png)

Due to its limited input and unit sample response, FIR filter is a kind of stable system (for any bounded input signal, its output signal is also bounded).

## FIR Filter

Assuming that n represents different time indexes, the FIR filter includes a finite length unit sample corresponding (coefficient) sequence: h(n). The number of its coefficients depends on the order of the filter: N. When the order of the filter is N, it will have N+1 coefficients (because h(0) is also a coefficient). It performs linear convolution operation on the sampled past N+1 input signal units with N+1 coefficients to obtain the predicted output value y^(n) of the time index. The relationship of the FIR filter can be expressed by the following formula[2]:

![image](https://user-images.githubusercontent.com/73535458/126027545-cbea0b99-b4c9-4386-8ec0-7a2d3c402cca.png)

or:

![image](https://user-images.githubusercontent.com/73535458/126027581-ca98b0ee-c9eb-4e3f-96f7-63ed97bc15b9.png)

FIR filters have different structures, the current mainstream ones are: direct type, cascade type, frequency sampling type and fast convolution type.

### direct type

### cascade type

### frequency sampling type

### fast conolution type


## References
1. https://www.student-circuit.com/learning/year2/signals-and-systems-intermediate/discrete-lti-system/
2. https://www.sciencedirect.com/topics/engineering/fir-filters
