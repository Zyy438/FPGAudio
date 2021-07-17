
# FIRPGA

This project is a fir filter implemented on FPGA board, using Verilog language only.  
The FPGA used in this project is ALETRA EP4CE10F17C8.  
The audio decoder chip used in this project is WM8978.  
The lcd display used in this project is ALIENTEK 4.3' RGBLCD 480 * 272  
Software used is Quartus 13.1 as well as Modelsim  

## How to use

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

FIR filters have different structures, the current mainstream ones are: direct form, cascade form, frequency sampling form and fast convolution form.

### direct form

As the most common and simplest fir filter structure, the direct fir filter can be easily deduced from its formula: For the input N+1 sampled signals, compare them with the corresponding elements in the corresponding signal vector. Multiply. Finally, add all the products to get the output at the moment. For the N+1 order fir filter of this structure, the required resources will be: N+1 multiplication units, N delay units (the system needs to temporarily store the input N signals in the register to Get N+1 current and past input signals) and an adder with N+1 inputs. Its structure can be shown below[3]:

![image](https://user-images.githubusercontent.com/73535458/126029774-cecfaa76-8e14-4bcc-8526-36ff1339dcc4.png)

The coefficients of the FIR filter can be divided into four cases: 1. The order is even and the coefficients are even symmetric about the center of symmetry. 2. The order is even and the coefficients are oddly symmetric about the center of symmetry. 3. The order is odd and the coefficients are even symmetric about the center of symmetry. 4. The order is odd and the coefficient is oddly symmetric about the center of symmetry[4].

· For the first situation, When the order N is an even number, the coefficient N+1 will be an odd number. At this time, the N/2th coefficient will be the symmetric center of the vector. The other coefficients are even symmetric with respect to the center of symmetry, which means that these coefficients can be reused (a coefficient is multiplied by two input samples) to save resources in fpga. The input/output response relationship can be transformed as follows:

![image](https://user-images.githubusercontent.com/73535458/126030014-02f6de0c-0de7-4b51-a2cf-7aa2f671e957.png)

It can be seen that the fir filter designed in this form only uses N/2+1 coefficients, which also means that only N/2+1 multipliers are needed. Because the resources that the multiplier occupies in fpga are much more than the adder, the multiplier reduced will save a lot of fpga resources.

· For the second situation, Since the coefficient is oddly symmetrical about the center of symmetry, the symmetrical coefficient is multiplied by -1. Others are similar to the previous case. 

![image](https://user-images.githubusercontent.com/73535458/126030584-5f449d8b-e1ab-4656-bccd-ff6ee72876bf.png)

· When N is odd, the coefficient will be even. This means that the center of symmetry will no longer be a coefficient, and there is no need to multiply the center of symmetry coefficient with an input signal. Similarly, the relational expression when N is odd and the coefficients are even symmetric can be obtained as: 

![image](https://user-images.githubusercontent.com/73535458/126030695-919ca0c7-1f5a-4f72-b46f-007b9d6863ae.png)

the structure of the fir filter in this case can be shown as:

![image](https://user-images.githubusercontent.com/73535458/126030751-a2c7854d-3d84-4aa4-aeef-7e45fb25816c.png)

· when N is odd and the coefficients are odd symmetric:

![image](https://user-images.githubusercontent.com/73535458/126030726-0f41c9da-3eb2-43fb-a27b-7ff79e827905.png)

### cascade form

The coefficient vector of the FIR filter can be expressed as multiple parts: the product of H1 (Z) and H2 (Z) and H3(Z)....[5],[6] Each part consists of three terms: real numbers, the negative power of Z multiplied by a specific coefficient, and the negative square power of Z multiplied by a specific coefficient. It can be expressed by the following formula:

![image](https://user-images.githubusercontent.com/73535458/126031322-1e212980-9ec8-4a14-a3e4-be19228b7aef.png)

For example, when the coefficient vector consists of two parts, they can be expressed as[6]:

![image](https://user-images.githubusercontent.com/73535458/126031441-9b506f82-a1e3-425c-8566-2b0bb8ee67d0.png)

Among them, H1(Z) can be expressed as[6]:

![image](https://user-images.githubusercontent.com/73535458/126031468-230f2bf4-26c1-44c8-938b-bae600e30a8e.png)

Therefore, the cascaded fir filter can be represented as the following figure:

![image](https://user-images.githubusercontent.com/73535458/126031505-4bcf16db-9180-462a-9ec7-958da59e27bd.png)

The filter using this structure will use 3N/2 multiplying units, which is not an ideal structure. However, when the order of the filter is high, the filter of this structure can still save a certain amount of resources.[7]

### frequency sampling form

Suppose there is a target frequency response:[8]

![image](https://user-images.githubusercontent.com/73535458/126033098-88cffb53-78e2-4615-81e7-f7a61aa60da6.png)


### fast convolution form


## References
1. https://www.student-circuit.com/learning/year2/signals-and-systems-intermediate/discrete-lti-system/
2. https://www.sciencedirect.com/topics/engineering/fir-filters
3. https://dsp.stackexchange.com/questions/15412/fir-filters-direct-form-transposed-fir
4. https://www.allaboutcircuits.com/technical-articles/structures-for-implementing-finite-impulse-response-filters/
5. https://ieeexplore.ieee.org/document/9010
6. https://www.youtube.com/watch?v=oYYHJrwGPrc
7. https://ieeexplore.ieee.org/document/196974
8. https://blog.csdn.net/u010592995/article/details/89294823
