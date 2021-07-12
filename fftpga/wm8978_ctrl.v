/*
1/7/2021
Created by ALIENTEK
modified by Zyy Zhou (22670661)
*/
/*
this module is to connect the wm8978 configuration module, the audio receive module
the audio send module with the WM8978 chip's interface.
used for ELEC5552 design2 project
*/
module wm8978_ctrl(
    input                clk        ,   
    input                rst_n      ,  
    
    //audio interface(mast  
    input                aud_bclk   ,   // clk for WM8978 chip
    input                aud_lrc    ,   // synchronization signal
    input                aud_adcdat ,   // audio input
    output               aud_dacdat ,   // audio output
    
    //control interfac  
    output               aud_scl    ,   // SCL signal for the IIC protocol
    inout                aud_sda    ,   // SDA signal for the IIC protocol
    
    //user i    
    output     [31:0]    adc_data   ,   // audio input signal, give it to the 
    input      [31:0]    dac_data   ,   // audio output signal, give it to this interface and send out
    output               rx_done    ,   
    output               tx_done        // indicatig signal, send to nothing at this stage of development
);

//parameter define
parameter    WL = 6'd16;                // word length of datas in a frame

//*****************************************************
//**                    main code
//*****************************************************
wm8978_config #(
    .WL             (WL)
) u_wm8978_config(
    .clk            (clk),               
    .rst_n          (rst_n),                    
    .aud_scl        (aud_scl),          // SDL for IIC protocol
    .aud_sda        (aud_sda)           // SDA for IIC protocol
);

//module to receive audio data
audio_receive #(
    .WL             (WL)
) u_audio_receive(    
    .sys_rst        (rst_n),            
    
    .aud_bclk       (aud_bclk),         // clk signal for WM8978 chip
    .aud_lrc        (aud_lrc),          // synchronization signal
    .aud_adcdat     (aud_adcdat),       // audio input
        
    .adc_data       (adc_data),         // duaio data being sent to the sender
    .rx_done        (rx_done)           // signal indicating that a frame is completed
);

//module to send audio data
audio_send #(
    .WL             (WL)
) u_audio_send(
    .sys_rst        (rst_n),     
        
    .aud_bclk       (aud_bclk),         // clk signal for WM8978 chip
    .aud_lrc        (aud_lrc),          // synchronization signal
    .aud_dacdat     (aud_dacdat),       // Audio data output
        
    .dac_data       (dac_data),         // registers comming from the receiver
    .tx_done        (tx_done)           //signal indicating that a frame of signal has been sent
);

endmodule 