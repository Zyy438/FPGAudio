/*
Written by Zyy Zhou (22670661)
used for ELEC5552 design unit project4 fir filter design 
top level entity for an sdram driver
this top level entity also has a fsm to arbit different states of the sdram including IDLE, ARBIT, REFRESHING, READ, and WRITE
when there is no power connection to the system, the driver will be in the IDLE state
when the initiallization procedure hasnt done, the driver will be in the IDLE state. It will go into the ARBiT state once it is 
intiallized. 
*/

module  sdram (
	//system input signals
	input                              sys_clk,
	input                              sys_rst,
	//output to sdram port
	output    wire                     sdram_clk,
	output    wire                     sdram_clk_en,
	output    wire                     sdram_cs_n,
	output    wire                     sdram_cas_n,
	output    wire                     sdram_ras_n,
	output    wire                     sdram_we_n,
	output    wire         [1:0]       sdram_bank, 
	output    reg          [11:0]      sdram_addr,            
	output    wire         [1:0]       sdram_dqm,           
	inout     wire         [15:0]      sdram_dq,    
	//write trigger from outside
	input                              wr_trigger

);

//=============================================================================
//                       define parameters
//=============================================================================
//parameter define
//the state of the sdram 
localparam      IDLE = 3'b001;
localparam      ARBIT = 3'b010;
localparam      REFRESH_TOP = 3'b011;
localparam      WRITE = 3'b100;
localparam      READ = 3'b101;

//reg define
reg          [2:0]           state_sdram;
reg          [3:0]           sd_cmd;

//wire define
//for initiallization module
wire                         init_end_flag;
wire         [3:0]           init_cmd;
wire         [11:0]          init_addr;

//for refresh module
wire                         ref_req;  //request for refreshing
reg                          ref_en; 
wire                         ref_end_flag; //indicating that refreshing procedure is end
wire         [3:0]           ref_cmd;
wire         [11:0]          ref_addr;

//for write module
reg                          write_en;
wire                         write_end_flag;
wire                         write_req;
wire        [3:0]            wr_cmd;       
wire        [11:0]           wr_addr;    
wire        [1:0]            wr_bank_addr;
wire        [15:0]           test_data;

//for read module             
reg                          read_en;     
wire                         read_end_fla;
wire                         read_req;                       

wire        [3:0]            rd_cmd;      
wire        [11:0]           rd_addr;     
wire        [1:0]            rd_bank_addr;



//=============================================================================
//                          main code
//=============================================================================
//a FSM for arbiting the working state of the sdram
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		state_sdram <= IDLE;
	end
	else begin
		case (state_sdram) 
			IDLE:
				if(init_end_flag) begin
					state_sdram <= ARBIT;
				end
				else begin
					state_sdram <= IDLE;
				end
			ARBIT:
				if(ref_en) begin
					state_sdram <= REFRESH_TOP;
				end
				else if(write_en)begin
					state_sdram <= WRITE;
				end
				else if(read_en)begin
					state_sdram <= READ;
				end
				else begin
					state_sdram <= ARBIT;
				end
			REFRESH_TOP:
				if(ref_end_flag) begin
					state_sdram <= ARBIT;
				end
				else begin
					state_sdram <= REFRESH_TOP;
				end
			WRITE:
				if(write_end_flag)begin
					state_sdram <= ARBIT;
				end
				else begin
					state_sdram <= WRITE;
				end
			READ:
				if(read_end_flag)begin
					state_sdram <= ARBIT;
				end
				else begin
					state_sdram <= READ;
				end
		default: state_sdram <= IDLE;
		endcase
	end
end

//make refresh_en signal pulled high for every time 
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		ref_en <= 1'b0;
	end
	else if (state_sdram == ARBIT && ref_req == 1'b1)begin
		ref_en <= 1'b1;
	end
	else begin
		ref_en <= 1'b0;
	end
end

//write_en signal
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		write_en <= 1'b0;
	end
	else if (state_sdram == ARBIT && ref_req == 1'b0 && write_req == 1'b1)begin
		write_en <= 1'b1;
	end
	else begin
		write_en <= 1'b0;
	end
end

//read signal
always @(posedge sys_clk or negedge sys_rst) begin
	if(!sys_rst) begin
		read_en <= 1'b0;
	end
	else if (state_sdram == ARBIT && ref_req == 1'b0 && read_req == 1'b1)begin
		read_en <= 1'b1;
	end
	else begin
		read_en <= 1'b0;
	end
end

//=============================================================================
//                   instantiate sub modules
//=============================================================================
//assign       sdram_addr = (state_sdram == IDLE)? init_addr: ref_addr;
assign       {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = sd_cmd;
assign       sdram_dqm = 2'b00;    //do not disable any instruction
assign       sdram_clk_en = 1'b1;  //l=always enable the clk
assign       sdram_clk = ~sys_clk;
assign       sdram_dq = (state_sdram == WRITE) ? test_data : {16{1'bz}};
assign       sdram_bank = (state_sdram == WRITE) ? wr_bank_addr : rd_bank_addr;

//dedfine the output command
always @(*)begin
	case (state_sdram)
		REFRESH_TOP: begin
			sd_cmd <= ref_cmd;
		   sdram_addr <= ref_addr;
		end
		WRITE: begin
			sd_cmd <= wr_cmd;
			sdram_addr <= wr_addr;
		end
		READ: begin
			sd_cmd <= rd_cmd;
			sdram_addr <= rd_addr;
		end
	default: begin
		sd_cmd <= 4'b0111;
		sdram_addr <= 'd0;
	end
	endcase
end

//initiallization module
init u_init(
	//system signals
	.sys_clk               (sys_clk),                 //50MHz, duration 20ns
	.sys_rst               (sys_rst),
	//output signals
	.cmd_reg               (init_cmd      ),
	.sdram_addr            (init_addr   ),
	.init_end_flag         (init_end_flag)
);

//autorefresh module
autorefresh u_autorefresh (
	//system input signals
	.sys_clk                             (sys_clk),
	.sys_rst                             (sys_rst),
	//communication with top level entity (arbit)
	.ref_en                              (ref_en      ),
	.ref_req                             (ref_req     ),
	.ref_end_flag                        (ref_end_flag), 
	//output to the port and communicate with sdram chip
	.ref_cmd                             (ref_cmd ),
	.ref_addr                            (ref_addr),
	//communication bewteen this module and the initiallization module(it shall send autofresh request after initiallization completed
	.init_end_flag                       (init_end_flag)
);

//write module
write u_write (
	//system input signals 
	.sys_clk                                                         (sys_clk),     
	.sys_rst                                                         (sys_rst),
	//communication between the module and the top level entity
	.write_en                                                        (write_en), 
	.write_end_flag                                                  (write_end_flag),
	.write_req                                                       (write_req),
	//the refresh request will interrupt the writing process
	.ref_req                                                         (ref_req),
	//interface to the sdram port
	.wr_cmd                                                          (wr_cmd       ),
	.wr_addr                                                         (wr_addr      ),
	.wr_bank_addr                                                    (wr_bank_addr ),
	//interface to the data input port
	.wr_trigger                                                      (wr_trigger),
	.test_data                                                       (test_data)
);

//read_module
read u_read(
	//system input signals 
	.sys_clk                                                 (sys_clk),
	.sys_rst                                                 (sys_rst),
	//communication between the module and the top level entity
	.read_en                                                 (read_en      ),//coming from the arbit(top level entity) module and the module will be enabled by this signal
	.read_end_flag                                           (read_end_flag),
	.read_req                                                (read_req     ),
	//the refresh request will interrupt the rditing process
	.ref_req                                                 (ref_req),
	//interface to the sdram port                            
	.rd_cmd                                                  (rd_cmd      ),
	.rd_addr                                                 (rd_addr     ),
	.rd_bank_addr                                            (rd_bank_addr),
	//interface to the data input port                       
	.rd_trigger                                              (rd_trigger)//trigger signal indicating that a data is coming in and need to be rditten
);


endmodule
