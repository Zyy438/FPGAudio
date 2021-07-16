/*
1/7/2021
Created by ALIENTEK .Company in 2018
modified by Zyy Zhou (22670661)
*/
/*
this module is to connect the FPGA with the WM8978 chip and send configuration signal
to the chip. including the I2c driver , implementing communication between the FPGA
and the audio chip.
*/

`timescale 1ns/1ns

module wm8978_config(
    input        clk     ,                 
    input        rst_n   ,  
    
	output       i2c_ack ,       
    output       aud_scl ,   
    inout        aud_sda            
);

//parameter define
parameter   SLAVE_ADDR = 7'h1a         ; 
parameter   WL         = 6'd32         ; 
parameter   BIT_CTRL   = 1'b0          ; 
parameter   CLK_FREQ   = 26'd50_000_000;  
parameter   I2C_FREQ   = 18'd250_000   ; 

//wire define
wire        clk_i2c   ;  
wire        i2c_exec  ; 
wire        i2c_done  ;  
wire        cfg_done  ; 
wire [15:0] reg_data  ;   

//*****************************************************
//**                    main code
//*****************************************************

//配置WM8978的寄存器
i2c_reg_cfg #(
    .WL             (WL       ) 
) u_i2c_reg_cfg(  
    .clk            (clk_i2c  ),  
    .sys_rst        (rst_n    ),  
  
    .i2c_exec       (i2c_exec ),
    .i2c_data       (reg_data ),     
    
    .i2c_done       (i2c_done ),           
    .cfg_done       (cfg_done )        
);

//调用IIC协议
i2c_dri #(
    .SLAVE_ADDR     (SLAVE_ADDR),   
    .CLK_FREQ       (CLK_FREQ  ),  
    .I2C_FREQ       (I2C_FREQ  )     
) u_i2c_dri(  
    .clk            (clk       ),   
    .rst_n          (rst_n     ),  
  
    .i2c_exec       (i2c_exec  ), 
    .bit_ctrl       (BIT_CTRL  ),
    .i2c_rh_wl      (1'b0      ),        
    .i2c_addr       (reg_data[15:8]), 
    .i2c_data_w     (reg_data[ 7:0]),   
      
    .i2c_data_r     (),              
    .i2c_done       (i2c_done  ),    
	 .i2c_ack        (i2c_ack   ),  
      
    .scl            (aud_scl   ),     
    .sda            (aud_sda   ),    
    .dri_clk        (clk_i2c   )    
);

endmodule 