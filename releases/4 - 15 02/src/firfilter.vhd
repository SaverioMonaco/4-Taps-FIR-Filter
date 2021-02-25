library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; -- to support multipication for coefficients C_i

--               clk          clk          clk
--       data_in  |   ff_1     |   ff_2     |   ff_3
-- X[n] ------->DFF_1------>DFF_2-------->DFF_3----
--         |            |            |            |
--         X C_0        X C_1        X C_2        X C_3
--         |           |             |            |
--         ----------> + ----------> + ---------> + --> DFF_OUT --> Y[n]
--
-- FF is a D Flip-Flop

entity fir_filter_4 is
  port (
    fir_clk : in std_logic;
    fir_rst : in std_logic;

    fir_ready    : in  std_logic;
    fir_data_in  : in std_logic_vector(7 downto 0);
    fir_data_out : out std_logic_vector(7 downto 0);
    fir_valid    : out std_logic);
end fir_filter_4;

architecture rtl of fir_filter_4 is
 -- Y[n] = c_0 x[n] + c_1 x[n-1]+ c_2 x[n-2] + c_3 x[n-3]
  --array of historical data values
  type t_data_pipe is array (0 to 3) of signed(7 downto 0);
  --array of all the coefficients
  type t_coeff is array (0 to 3) of signed(7 downto 0);

  --array of coefficient * data product
  type t_mult is array (0 to 3) of signed(2*8-1 downto 0);
  type t_add_st0 is array (0 to 2 -1) of signed(2*8 downto 0);

  signal r_coeff   : t_coeff;  --array of latched in coefficient values
  signal p_data    : t_data_pipe; --pipeline of historic data values
  signal r_mult    : t_mult;  --array of coefficient*data products
  signal r_add_st0 : t_add_st0;
  signal r_add_st1 : signed(2*8+1 downto 0);

  component dffvalid is
      port
      (
          i_clk  : in  std_logic;
          i_rstb : in  std_logic;
          i_data : in  std_logic;
          o_data : out std_logic
      );
  end component dffvalid;

  begin
    dff_valid: dffvalid
      port map (i_clk => fir_clk, i_rstb  => fir_rst, i_data  => fir_ready, o_data  => fir_valid);

    r_coeff(0) <= X"B2";
    r_coeff(1) <= X"01";
    r_coeff(2) <= X"ff";
    r_coeff(3) <= X"ff";

    p_setup : process(fir_rst, fir_clk)
    begin
      if(fir_rst = '1') then -- we need to reset everything
        p_data  <= (others => (others => '0')); -- we clear the data pipeline
        r_coeff <= (others => (others => '0'));
      elsif(rising_edge(fir_clk)) then
        --shift new data into data pipeline
        p_data <= signed(fir_data_in) & p_data(0 to p_data'length-2);
      end if;
    end process p_setup;

    p_mult : process (fir_rst, fir_clk) --Multiply the samples with the coefficients
    begin
        if(fir_rst = '1') then -- we reset everything
            r_mult <= (others => (others => '0'));
        elsif(rising_edge(fir_clk)) then
            for k in 0 to 3 loop
                r_mult(k) <= p_data(k) * r_coeff(k); --perfomr convolution
            end loop;
        end if;
    end process p_mult;

    p_add_st0 : process (fir_rst, fir_clk) --resize
    begin
        if(fir_rst = '1') then -- we reset everything
            r_add_st0 <= (others => (others => '0'));
        elsif(rising_edge(fir_clk)) then
            for k in 0 to 4/2-1 loop
                r_add_st0(k) <= resize(r_mult(2*k), 2*8+1) + resize(r_mult(2*k+1), 2*8+1);
            end loop;
        end if;
    end process p_add_st0;

    p_add_st1 : process (fir_rst, fir_clk) --resize
    variable tmp: signed(2*8+1 downto 0):= (others => '0');
      begin
      tmp := (others => '0');
        if(fir_rst = '1') then
          r_add_st1 <= (others => '0');
        elsif(rising_edge(fir_clk)) then
          for k in 0 to 4/2-1 loop
                tmp := tmp + resize(r_add_st0(k), 2*8+2);
            end loop;
            r_add_st1 <= tmp;
         end if;
    end process p_add_st1;

    p_output : process (fir_rst, fir_clk) --Compute output
    begin
        if(fir_rst = '1') then
            fir_data_out <= (others => '0');
        elsif(rising_edge(fir_clk)) then
            fir_data_out <= std_logic_vector(r_add_st1(8-1 downto 0));
        end if;
    end process p_output;

end rtl;
