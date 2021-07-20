module hello_world_top(
	input             sys_clk,
	input             sys_rst
);

//parameter define


//reg define


//wire define
wire      clk_100m;

//*******************************************************************
//               main code
//*******************************************************************

//pll module
pll u_pll (
	.inclk0      (sys_clk),
	//output 100MHz clock
	.c0          (clk_100m)
);


//the qsys system

    hello_world u0 (
        .clk_clk       (clk_100m),       //   clk.clk
        .reset_reset_n (sys_rst)  // reset.reset_n
    );

endmodule
	 