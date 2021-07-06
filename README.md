# FFTPGA

This page is to implement a fast fourier transform algorithm in an fpga board. It also includes an audio processor as well as an LCD screen driver, so that the LCD(if plug in) will show the spectrum of the input audio signal through the fft module.

This project will be introduced by 3 parts: 

1. the LCD driver
2. the audio interface (WM8978 chip)
3. the fft module

## 1. LCD driver

The film transistor-liquid crystal display is one of the most popular display devices nowadays. It is widely used in TV, mobile phone, dashboard and other devices. Although the display quality is worse than that of OLED screens, LCDs are still favored by the market because of their low prices.

A 4.3-inch LCD screen with 480*272 resolution is used in this project. Therefore, the relevant codes are also designed in accordance with this specification. If other resolution screens are used, please adjust the relevant parameters to obtain a normal display effect.

### Resolution of a LCD display

The resolution of the LCD screen (480 * 272) usually means that the screen has 272 lines of pixels, and each line has 480 pixels. The LCD screen transmits the color information of each pixel one by one in the order from left to right and top to bottom. When the display driver is connected with fpga, fpga will send the position information and color information of the current pixel.

### Color information

Red, green and blue are the three primary colors. By controlling their mixing ratio, a variety of different colors can be produced. Therefore, the color information about each pixel transmitted to the LCD screen usually has two mainstream formats: RGB888 and RGB565. They usually refer to the number of bits of red, green and blue information in a frame of color information data. For example, RGB565 means that in a frame of color information data, red data occupies 5 bits, green occupies 6 bits, and blue occupies 5 bits. Therefore, the LCD display data using the RGB565 format will occupy 5+6+5=16 bits.  
<img width="257" alt="WechatIMG163" src="https://user-images.githubusercontent.com/73535458/124561249-43cace00-de70-11eb-8d0b-85b14356727e.png">

### Time issue of of LCD display

VBP,HBP,HFP and VFP are four factors that cannot be ignored in LCD timing analysis[1]. When transferring pixel position parameters, LCD driver does not simply transfer the received color information to the next pixel based on the rising edge of the clock signal. HSYNC is a horizontal synchronization signal. When this signal is generated, it means that the LCD display needs to start displaying a new raw. The VSYNC signal is a vertical synchronization signal, also called a frame synchronization signal. When this signal is generated, it means that a new frame of image should be displayed.[2] Usually, after the FPGA sends a line or frame of signal, it takes a while to load the color information of a new line or frame. Therefore, by setting a reasonable delay for the LCD to wait for the FPGA to output the signal of the next line or frame, it will be ensured that the output color information is transmitted to the correct pixel.  

below shows definition of some time parameters of LCD display:[3]  
Typical timing parameters include:  
Horizontal Back Porch (HBP): Number of PIXCLK pulses between HSYNC signal and the first valid pixel data.  
Horizontal Front porch (HFP): Number of PIXCLK pulses between the last valid pixel data in the line and the next HSYNC pulse.  
Vertical Back Porch (VBP): Number of lines (HSYNC pulses) from a VSYNC signal to the first valid line.  
Vertical Front Porch (VFP): Number of lines (HSYNC pulses) between the last valid line of the frame and the next VSYNC pulse.  

<img width="1109" alt="WechatIMG164" src="https://user-images.githubusercontent.com/73535458/124565445-a02fec80-de74-11eb-9aa1-72d2f4dd00a0.png">
Therefore, when transmitting a new frame or a new raw of pixel data, the driver needs to wait for a specific period of time. So as after finishing transmitting a raw or a frame of pixel data. This will be reflected in the verilog codes and more explaination can be found in the '.v' files.

### Working process of the LCD driver

![1651625562934_ pic_hd](https://user-images.githubusercontent.com/73535458/124575251-d02fbd80-de7d-11eb-9035-b70a20f720f4.jpg)  
Above shows the structure of the LCD driver module. There are 3 parts in the module: clk division, lcd deiver and lcd show.

The clock division part aims to generate a 12.5 Hz clock signal (called lcd_pclk) for the lcd driver. This is because that, to generate a frame in such a 480 * 272 screen, it needs:   N(CLK) = (VSPW + VBP + LINE + VFP) * (HSPW + HBP + HOZVAL + HFP) = 150150 clock periods (different brands of screens have different parameters), and to make its refreshing rate to be 60Hz, it needs 150150 * 60 clock periods in a second. By this way, its required clock frequency will be around 9 MHz. To make things easier, the clk_div part will just divide the 50Mhz input clk signal into 12.5 Hz, thus a pll moudle is no longer needed and the frame rate will be a bit higher.  

The lcd_driver part is connected to the lcd_show part and the lcd interface. There is a internal reg parameter called 'data_req' and it will be 1 when it comes to the data part (not in the HSYNC or VSYNC time period). When 'data_req' becomes 1, the module will send the location of the current pixel to the lcd_show part (signal pixel_x and pixel_y), indicating the lcd_show part which pixel is being shown. This is implemented by the internal counters 'h_cnt' and 'v_cnt'. The lcd_bl signal is connected to the lcd interface and the lcd will always be on when it is 1. Also, it will transmit the data time for a raw and for a frame to the lcd_show part as well.  

Relatively speaking, the structure of lcd_show is very simple. After receiving the pixel location information from the LCD drive part, it will output the color signal (RGB565 format) of the pixel at the corresponding location through its only output port 'pixel_data'.

## 2. Audio interface (WM8978 chip)

This project uses the WM8978 chip to convert the analog signal of the input audio into a digital signal, then processes it through various signal processing modules inside the FPGA (the frequency domain data is obtained through fast Fourier transform module and displayed on the LCD screen). Finally, the signal will be output to another audio port through the WM8978 chip. The user will get the unprocessed input signal at the output audio port because this signal is bypassed to the output interface.

### IIC protocol

I2C(Inter-integrated circuit) is a very popular bus applied in many field. invented by Philips company in 1980s, it just needs two wires- SCL and SDA, to implement communication with different modules. the SCL wire mainly transmit clock signal to synchronize the data transmission, the SDA wire uausally transmit data signal between different modules. Various controlled devices(slave) are connected in parallel on the bus and identified by the device address (SLAVE ADDR, refer to the device manual for details). In this project, the FPGA is used as a master module and the WM8978 is used as a slave module(slave addr= 7'h1A).  below shows the structure of a typical I2C bus[4]:

<img width="807" alt="image" src="https://user-images.githubusercontent.com/73535458/124633053-7e0b8e00-deb7-11eb-8afb-435c63f05162.png">

Therefore, before the I2C device starts to communicate (transmit data), the serial clock line SCL and the serial data line SDA line are in a high level state, and the I2C bus is in an idle state at this time. If the master (here refers to FPGA) wants to start transmitting data, it just needs to pull the SDA line low when SCL is high to generate a start signal. After the slave detects the start signal, it is ready to receive data. When the data transmission is completed The master only needs to generate a stop signal to tell the slave that the data transmission is over. The stop signal is generated when SCL is high, and SDA jumps from low to high. After the slave detects the stop signal, it stops receiving data. The overall timing of I2C is shown in the figure below. Before the start signal, it is in the idle state, and the period after the start signal to before the stop signal is the data transmission state. The master can write data to the slave or read the data output by the slave. The data transmission is through the bidirectional data line ( SDA) complete. After the stop signal is generated, the bus will be in an idle state again.[5]

<img width="714" alt="image" src="https://user-images.githubusercontent.com/73535458/124633571-fa05d600-deb7-11eb-8933-180eb28f4f92.png">

### WM8978

WM8978 is a powerful audio interface(decoder and encoder) designed for digital devices. It is able to communicate will FPGA board through I2S(Inter-IC sound) protocol, which is very similar to I2C protocol. Below shows the time feature of I2S protocol:[6]

<img width="743" alt="image" src="https://user-images.githubusercontent.com/73535458/124634835-5caba180-deb9-11eb-9156-19b31a369e2e.png">



## Reference

1. https://zh.wikipedia.org/wiki/HBP
2. https://titanwolf.org/Network/Articles/Article?AID=e1dd946f-22b5-4520-be37-debb91e2d93d#gsc.tab=0
3. https://www.digi.com/resources/documentation/digidocs/90001945-13/reference/yocto/r_an_adding_custom_display.htm
4. https://www.ti.com/lit/an/slva704/slva704.pdf?ts=1625586943073&ref_url=https%253A%252F%252Fwww.google.com%252F
5. https://www.researchgate.net/publication/221908590_Non-Volatile_Memory_Interface_Protocols_for_Smart_Sensor_Networks_and_Mobile_Devices
6. https://forums.xilinx.com/t5/Processor-System-Design-and-AXI/ZYBO-I2S-BCLK/td-p/433246
