
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

There will be mainly 3 steps to implement frequency sampling method. The data obtained by the user will be a continous frequency response Hd(e^jw), then, according to the order of the filter, different samples of the frequency response can be obtained.(the first step) Then, by doing inversed fourier transform on these discrete frequency sample, the coefficients in time domain can be obtained.

Suppose there is a wanted frequency response:[8] The frequency target response at this time is Hd(e^jw). This is a continuous function of w. Hd(k) and it can be obtained by sampling N points on the unit circle whose absolute value of e^jw is 1, which is the actual discrete target response in frequency domain. For example, if the order of the filter is 7, there will be 8coefficients sampled from the desired frequency responce. thus the total circle will be divided into 7 segments and the length of each segments will be 2*pi/7. the k th coefficient will be the value of the frequency responce sampled at 2*pi/N*k (k>=0, k<N, int k). Finally, the response is inversely Fourier transformed to the time domain, and the required impulse response is thus obtained. [9]

![image](https://user-images.githubusercontent.com/73535458/126033098-88cffb53-78e2-4615-81e7-f7a61aa60da6.png)

According to the IDFT formula, the coefficients in time domain can be obtained as:

![image](https://user-images.githubusercontent.com/73535458/126034242-eb29d3a0-c80c-4d07-b260-a77c81545518.png)

Thus this kind of structure can be performed as:

![image](https://user-images.githubusercontent.com/73535458/126034511-348cc824-7549-4b17-94b0-ed903e2f3ad8.png)

The fir filter structure designed by this method is more complicated than the previous two methods. However, in some narrowband filters, most of the frequency response coefficient will be zero. If the order of the filter is high at this time, compared to other structures, the frequency response structure will save more fpga resources.（many H(z) in the diagram will be eliminated because they are 0) Moreover, in some cases, many FIR filters are required to work in parallel, and a lot of FPGA resources will be used if the direct type is used. However, the use of frequency sampling structure allows some H(z) to be multiplexed, which means that different fir filters can be operated in parallel by weighted combination of these H(z) output values, thereby saving FPGA resources.

### fast convolution form

This type of filter is mainly implemented based on the Fourier transform algorithm. After the value of the coefficient in the time domain is given, the discrete Fourier transform can be performed to obtain the corresponding frequency domain response. At the same time, discrete Fourier transform is also performed on the input signal to obtain its frequency spectrum. Multiply the two frequency domain signals to get the frequency domain signal after the response. finally, by doing an IDFT algorithm on the output signal, the output signal in the time domain can be obtained. The structure can be discriped as diagram shown below:

![image](https://user-images.githubusercontent.com/73535458/126055314-03fd6a76-91d9-4983-ba1a-8c2c0a581ad9.png)

## Determine coefficients

The structure of the filter can be designed to optimize the resource occupation of the FPGA, and the effect of the filter is determined by its coefficient. Different coefficients can achieve different responses to the input signal in the frequency domain. Therefore, design coefficients are a very important part of designing filters. There are currently three mainstream design methods: 1. Window function method 2. Frequency sampling method 3. Chebyshev Equal Ripple Approximation Method(Remez algorithm). The window function method is not easy to design a filter with a given cutoff frequency, and the frequency sampling method is not a much better design either because it completely relies on some sampled values in the frequency response. Relatively speaking, Chebyshev method is the best one among the three methods. Since there is no function corresponding to the latter two methods in matlab, there will be too much work to verify whether fpga works as desired. Therefore, this project plans only to adopt the simplest window function design method.

Window method: Assuming that a low-pass filter needs to be designed now, its ideal frequency domain response has been given, which is a rectangular function. Among them, Wc and -Wc are cutoff frequencies. When a signal passes through this filter, the low frequency part of the input signal (frequency less than Wc and greater than -Wc) will be multiplied by 1, and the other parts will be multiplied by 0. The frequency domain diagram of this frequency response is as follows:

![image](https://user-images.githubusercontent.com/73535458/126057669-d5876fc3-118d-4684-a6e3-79023631d2b7.png)

However, the coefficients required by the direct FIR filter will be in the time domain. Multiplication in the frequency domain is equivalent to convolution in the time domain. Therefore, the rectangular function can be Fourier transformed to get its image in the time domain. The converted image will be a Sinc function. The image at this time is still continuous：

![image](https://user-images.githubusercontent.com/73535458/126057736-850577a1-07ce-425f-8b33-5f3ce4edc586.png)

However, the time domain of this sinc function is infinite (the value of n ranges from negative infinity to positive infinity), and the fir filter cannot have infinite coefficients. The easiest way to solve this problem is to directly truncate the sinc function to obtain a coefficient that approximates the ideal frequency domain. Moreover, even after being truncated, because the image is continuous, the frequency response at this time also requires an infinite number of coefficients to be expressed. Therefore, the frequency response is sampled. The number of samples is directly determined by the number of filter coefficients. It can be found that the more coefficients of the filter, the closer the sampled frequency response will be to the ideal frequency response. The truncated frequency response is shown in the figure below:

![image](https://user-images.githubusercontent.com/73535458/126057870-27cb4ab1-76a6-4a8d-89a7-56c2ff9896ab.png)

However, in the sampled frequency response, there is a negative part in the time domain. This means that the input signal to be sampled in the future needs to be multiplied by these coefficients. However, because the input signal may be a random signal, the future signal is not known, and the Fir filter must be a causal system. Therefore, the overall image is translated by (N-1)/2 sampling points. At this point the system becomes a causal system. The negative effect is that this will cause a certain delay in output.

The frequency domain characteristics of h(n) obtained by this method will be:

![image](https://user-images.githubusercontent.com/73535458/126058011-5a271aae-6d7b-4421-832a-8344af7da7e7.png)



## References
1. https://www.student-circuit.com/learning/year2/signals-and-systems-intermediate/discrete-lti-system/
2. https://www.sciencedirect.com/topics/engineering/fir-filters
3. https://dsp.stackexchange.com/questions/15412/fir-filters-direct-form-transposed-fir
4. https://www.allaboutcircuits.com/technical-articles/structures-for-implementing-finite-impulse-response-filters/
5. https://ieeexplore.ieee.org/document/9010
6. https://www.youtube.com/watch?v=oYYHJrwGPrc
7. https://ieeexplore.ieee.org/document/196974
8. https://blog.csdn.net/u010592995/article/details/89294823
9. https://www.youtube.com/watch?v=EZbOVJwtJ8s
