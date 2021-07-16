-- ================================================================================
-- Legal Notice: Copyright (C) 1991-2008 Altera Corporation
-- Any megafunction design, and related net list (encrypted or decrypted),
-- support information, device programming or simulation file, and any other
-- associated documentation or information provided by Altera or a partner
-- under Altera's Megafunction Partnership Program may be used only to
-- program PLD devices (but not masked PLD devices) from Altera.  Any other
-- use of such megafunction design, net list, support information, device
-- programming or simulation file, or any other related documentation or
-- information is prohibited for any other purpose, including, but not
-- limited to modification, reverse engineering, de-compiling, or use with
-- any other silicon devices, unless such use is explicitly licensed under
-- a separate agreement with Altera or a megafunction partner.  Title to
-- the intellectual property, including patents, copyrights, trademarks,
-- trade secrets, or maskworks, embodied in any such megafunction design,
-- net list, support information, device programming or simulation file, or
-- any other related documentation or information provided by Altera or a
-- megafunction partner, remains with Altera, the megafunction partner, or
-- their respective licensors.  No other licenses, including any licenses
-- needed under any third party's intellectual property, are provided herein.
-- ================================================================================
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
entity fft_tb is
end fft_tb;

architecture tb of fft_tb is
  
  constant clk_time_step : time := 1 ns;

  signal clk     : std_logic;
  signal reset_n : std_logic;
  signal fftpts_in     : std_logic_vector (7 downto 0);
  signal fftpts_out     : std_logic_vector (7 downto 0);
  signal inverse      : std_logic;
  signal sink_valid   : std_logic;
  signal sink_sop     : std_logic;
  signal sink_eop     : std_logic;
  signal sink_error   : std_logic_vector(1 downto 0);
  signal sink_real    : std_logic_vector (16 - 1 downto 0);
  signal sink_imag    : std_logic_vector (16 - 1 downto 0);
  signal source_ready : std_logic;
  signal sink_ready   : std_logic;
  signal source_sop   : std_logic;
  signal source_eop   : std_logic;
  signal source_valid : std_logic;
  signal source_error : std_logic_vector(1 downto 0);
  signal source_real : std_logic_vector (16 - 1 downto 0);
  signal source_imag : std_logic_vector (16 - 1 downto 0);
  signal source_exp  : std_logic_vector(5 downto 0);
  
  constant NUM_FRAMES_c : natural := 4;
  -- for testing purposes, the input file contains 2 frames of data of sizes
  type     fftpts_list_t is array (NUM_FRAMES_c - 1 downto 0) of natural;
  signal fftpts_array : fftpts_list_t := (128, 128, 128, 128);
  signal start            : std_logic;
  -- number of input frames
  signal frames_in_index   : natural range 0 to NUM_FRAMES_c := 0;
  -- number of output frames
  signal frames_out_index : natural range 0 to NUM_FRAMES_c := 0;

  signal cnt        : natural range 0 to 128;
  signal end_test   : std_logic;
  -- signal the end of the input data stream and output data stream.
  signal end_input  : std_logic;
  signal end_output : std_logic;


--------------------------------------------------------------------------------------------                                      
-- FFT Component Declaration
--------------------------------------------------------------------------------------------                                      
  component fft is
    port (
      clk          : in  std_logic;
      reset_n      : in  std_logic;
      inverse      : in  std_logic;
      sink_valid   : in  std_logic;
      sink_sop     : in  std_logic;
      sink_eop     : in  std_logic;
      sink_real    : in  std_logic_vector (16 - 1 downto 0);
      sink_imag    : in  std_logic_vector (16 - 1 downto 0);
      source_ready : in  std_logic;
      sink_ready   : out std_logic;
      sink_error   : in  std_logic_vector(1 downto 0);
      source_error : out std_logic_vector(1 downto 0);
      source_sop   : out std_logic;
      source_eop   : out std_logic;
      source_valid : out std_logic;
      source_exp   : out std_logic_vector (5 downto 0);
      source_real  : out std_logic_vector (16 - 1 downto 0);
      source_imag  : out std_logic_vector (16 - 1 downto 0)
      ); 
  end component fft;
  
begin
  -----------------------------------------------------------------------------------------------
  -- Reset Generation                                                                          
  -----------------------------------------------------------------------------------------------
  reset_n <= '0',
             '1' after 92*clk_time_step;
  -----------------------------------------------------------------------------------------------
  -- Clock Generation                                                                         
  -----------------------------------------------------------------------------------------------
  clkgen : process
  begin
    if end_test = '1' and  end_output = '1' then
      clk <= '0';
      wait;
    else
      clk <= '0';
      wait for 5*clk_time_step;
      clk <= '1';
      wait for 5*clk_time_step;
    end if;
  end process clkgen;

  -----------------------------------------------------------------------------------------------
  -- Set FFT Direction                                                                           
  -- '0' => FFT                                                                                  
  -- '1' => IFFT                                                                                 
  -----------------------------------------------------------------------------------------------
  inverse <= '0';


  -- for example purposes, the ready signal is always asserted.
  source_ready <= '1';

  -- no input error
  sink_error <= (others => '0');

  -- start valid for first cycle to indicate that the file reading should start.
  start_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      start <= '1';
    elsif rising_edge(clk) then
      if sink_valid = '1' and sink_ready = '1' then
        start <= '0';
      end if;
    end if;
  end process start_p;


  -- sop and eop asserted in first and last sample of data
  cnt_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      cnt <= 0;
    elsif rising_edge(clk) then
      if sink_valid = '1' and sink_ready = '1' then
        if cnt = fftpts_array(frames_in_index) - 1 then
          cnt <= 0;
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process cnt_p;

  fftpts_in <= std_logic_vector(to_unsigned(fftpts_array(frames_in_index), fftpts_in'length));

  -- count the input frames and increment the index
  increment_index_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      frames_in_index <= 0;
    elsif rising_edge(clk) then
      if sink_eop = '1' and sink_valid = '1' and sink_ready = '1' then
        if frames_in_index < NUM_FRAMES_c - 1 then
          frames_in_index <= frames_in_index + 1;
        end if;
      end if;
    end if;
  end process increment_index_p;

  -- count the output frames and increment the index
  increment_out_index_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      frames_out_index <= 0;
    elsif rising_edge(clk) then
      if source_eop = '1' and source_valid = '1' and source_ready = '1' then
        if frames_out_index < NUM_FRAMES_c - 1 then
          frames_out_index <= frames_out_index + 1;
        end if;
      end if;
    end if;
  end process increment_out_index_p;

  -- signal when all of the input data has been sent to the DUT
  end_input <= '1' when (sink_eop = '1' and sink_valid = '1' and sink_ready = '1' and (frames_in_index = NUM_FRAMES_c - 1)) else
               '0';

  -- signal when all of the output data has be received from the DUT
  end_output <= '1' when source_eop = '1' and source_valid = '1' and source_ready = '1' and (frames_out_index = NUM_FRAMES_c - 1) else
                '0';

  -- generate start and end of packet signals
  sink_sop <= '1' when cnt = 0 else
              '0';

  sink_eop <= '1' when cnt = fftpts_array(frames_in_index) - 1 else
              '0';

  -- halt the input when done
  end_test_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      end_test <= '0';
    elsif rising_edge(clk) then
      if end_input = '1' then
        end_test <= '1';
      end if;
    end if;
  end process end_test_p;

  -----------------------------------------------------------------------------------------------
  -- Read input data from files                                                                  
  -----------------------------------------------------------------------------------------------
  testbench_i : process(clk) is
    file r_file     : text open read_mode is "fft_real_input.txt";
    variable data_r : integer;
    variable rdata  : line;
    file i_file     : text open read_mode is "fft_imag_input.txt";
    variable idata  : line;
    variable data_i : integer;
  begin
    if(reset_n = '0') then
      sink_real  <= std_logic_vector(to_signed(0, 16));
      sink_imag  <= std_logic_vector(to_signed(0, 16));
      sink_valid <= '0';
    elsif rising_edge(clk) then

      -- send in NUM_FRAMES_c of data or until the end of the file
      if not endfile(r_file) and (end_input = '0' and end_test = '0') then
        if((sink_valid = '1' and sink_ready = '1') or
           (start = '1' and not (sink_valid = '1' and sink_ready = '0'))) then
          readline(r_file, rdata);
          read(rdata, data_r);
          readline(i_file, idata);
          read(idata, data_i);
          sink_real  <= std_logic_vector(to_signed(data_r, 16));
          sink_imag  <= std_logic_vector(to_signed(data_i, 16));

        else
          sink_real  <= sink_real;
          sink_imag  <= sink_imag;
        end if;

        sink_valid <= '1';

      else
        sink_valid <= '0';
        sink_real <= std_logic_vector(to_signed(0, 16));
        sink_imag <= std_logic_vector(to_signed(0, 16));
      end if;
    end if;
    
  end process testbench_i;

  ---------------------------------------------------------------------------------------------
  -- Write Real and Imginary Components and Block Exponent to Files                                               
  ---------------------------------------------------------------------------------------------

  testbench_o : process(clk, reset_n) is
    file ro_file   : text open write_mode is "fft_real_output_vhd.txt";
    variable rdata : line;
    variable data_r : integer;
    file io_file   : text open write_mode is "fft_imag_output_vhd.txt";
    variable idata : line;
    variable data_i : integer;
    file eo_file    : text open write_mode is "fft_exponent_output_vhd.txt";
    variable edata  : line;
    variable data_e : integer;
  begin
    if rising_edge(clk) and reset_n = '1' then
      if(source_valid = '1' and source_ready = '1') then
        data_r := to_integer(signed(source_real));
        data_i := to_integer(signed(source_imag));
        write(rdata, data_r);
        writeline(ro_file, rdata);
        write(idata, data_i);
        writeline(io_file, idata);
        data_e := to_integer(signed(source_exp));
        write(edata, data_e);
        writeline(eo_file, edata);
      end if;
    end if;
  end process testbench_o;


  ---------------------------------------------------------------------------------------------
  -- FFT Component Instantiation                                                               
  ---------------------------------------------------------------------------------------------
  fft_inst : fft
    port map (
      clk          => clk,
      reset_n      => reset_n,
      inverse      => inverse,
      sink_valid   => sink_valid,
      sink_sop     => sink_sop,
      sink_eop     => sink_eop,
      sink_real    => sink_real,
      sink_imag    => sink_imag,
      sink_error   => sink_error,
      source_error => source_error,
      source_ready => source_ready,
      sink_ready   => sink_ready,
      source_sop   => source_sop,
      source_eop   => source_eop,
      source_valid => source_valid,
      source_exp   => source_exp,
      source_real  => source_real,
      source_imag  => source_imag);


end tb;
