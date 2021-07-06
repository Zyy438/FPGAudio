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

The resolution of the LCD screen (480 * 200) usually means that the screen has 200 lines of pixels, and each line has 480 pixels. The LCD screen transmits the color information of each pixel one by one in the order from left to right and top to bottom. When the display driver is connected with fpga, fpga will send the position information and color information of the current pixel.

### Color information

Red, green and blue are the three primary colors. By controlling their mixing ratio, a variety of different colors can be produced. Therefore, the color information about each pixel transmitted to the LCD screen usually has two mainstream formats: RGB888 and RGB565. They usually refer to the number of bits of red, green and blue information in a frame of color information data. For example, RGB565 means that in a frame of color information data, red data occupies 5 bits, green occupies 6 bits, and blue occupies 5 bits. Therefore, the LCD display data using the RGB565 format will occupy 5+6+5=16 bits.  
<img width="257" alt="WechatIMG163" src="https://user-images.githubusercontent.com/73535458/124561249-43cace00-de70-11eb-8d0b-85b14356727e.png">



## Reference

1. https://zh.wikipedia.org/wiki/HBP

