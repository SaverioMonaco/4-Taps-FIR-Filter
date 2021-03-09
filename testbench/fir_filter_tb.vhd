library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use STD.textio.all;
-------------------------------------------------------------------------------

entity fir_filter_4_tb is

end entity fir_filter_4_tb;

-------------------------------------------------------------------------------

architecture test of fir_filter_4_tb is

  -- component ports
  signal tb_clk        : std_logic                    := '0';    -- [in]
  signal tb_rstb       : std_logic;                              -- [in]
signal tb_coeff_0: std_logic_vector(7 downto 0) := X"0c";  -- [in]
signal tb_coeff_1: std_logic_vector(7 downto 0) := X"74";  -- [in]
signal tb_coeff_2: std_logic_vector(7 downto 0) := X"74";  -- [in]
signal tb_coeff_3: std_logic_vector(7 downto 0) := X"0c";  -- [in]
  signal tb_i_data     : std_logic_vector(7 downto 0); -- [in]
  signal tb_o_data     : std_logic_vector(9 downto 0);           -- [out]
  signal tb_clk_enable : boolean                      := true;

  constant c_WIDTH  : natural                      := 8;
  file file_VECTORS : text;
  file file_RESULTS : text;

  -- clock

begin  -- architecture test

  -- component instantiation
  DUT : entity work.fir_filter_4
    port map (
      fir_clk       => tb_clk,
      fir_rstb      => tb_rstb,
      fir_coeff_0   => tb_coeff_0,
      fir_coeff_1   => tb_coeff_1,
      fir_coeff_2   => tb_coeff_2,
      fir_coeff_3   => tb_coeff_3,
      fir_i_data    => tb_i_data,
      fir_o_data    => tb_o_data);

  -- clock generation
  tb_clk <= not tb_clk after 10 ns when tb_clk_enable = true
           else '0';
  -- waveform generation
  WaveGen_Proc : process
    variable CurrentLine    : line;
    variable v_ILINE        : line;
    variable v_OLINE        : line;
    variable i_data_integer : integer := 0;
    variable o_data_integer : integer := 0;
    variable i_data_slv     : std_logic_vector(7 downto 0);
  begin
    -- insert signal assignments here
    file_open(file_VECTORS, "input_vectors.txt", read_mode);
    file_open(file_RESULTS, "output_results.txt", write_mode);
    tb_rstb <= '0';
    wait until rising_edge(tb_clk);
    wait until rising_edge(tb_clk);
    tb_rstb <= '1';
    while not endfile(file_VECTORS) loop
      readline(file_VECTORS, v_ILINE);
      read(v_ILINE, i_data_integer);
      tb_i_data         <= std_logic_vector(to_signed(i_data_integer, tb_i_data'length));
      wait until rising_edge(tb_clk);
      o_data_integer := to_integer(signed(tb_o_data));
      write(v_OLINE, o_data_integer, left, c_WIDTH);
      writeline(file_RESULTS, v_OLINE);
    end loop;
    file_close(file_VECTORS);
    file_close(file_RESULTS);
    tb_clk_enable <= false;
    wait;
  end process WaveGen_Proc;



end architecture test;
