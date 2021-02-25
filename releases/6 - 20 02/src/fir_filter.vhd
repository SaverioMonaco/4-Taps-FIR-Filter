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
    clk     : in  std_logic;
    rst     : in  std_logic;
    --nxt     : in std_logic;

    -- Initialize the four coefficients, those depends on what filter we
    -- intend to build, and what frequencies do we want to filter out
    -- The coefficients were generated using the function firwin in scipy.signal
    -- for a low-pass filter from 0 to 0.2
    c_0 : in  std_logic_vector(7 downto 0); -- 0.04156529
    c_1 : in  std_logic_vector(7 downto 0); -- 0.45843471
    c_2 : in  std_logic_vector(7 downto 0); -- 0.45843471
    c_3 : in  std_logic_vector(7 downto 0); -- 0.04156529
    -- data input
    data_in    : in  std_logic_vector(7 downto 0);
    -- filtered data
    --valid_out  : out std_logic;
    data_out   : out std_logic_vector(17 downto 0)

    );
end fir_filter_4;

architecture test of fir_filter_4 is
  signal ff_1  : std_logic_vector(7 downto 0);
  signal ff_2  : std_logic_vector(7 downto 0);
  signal ff_3  : std_logic_vector(7 downto 0);
  signal sum_data : std_logic_vector(17 downto 0);

  -- d flip flop component
  component dff is
    port
        (
          d   : in  std_logic_vector(7 downto 0);
          clk : in  std_logic;
          q   : out std_logic_vector(7 downto 0);
          rst : in  std_logic
        );
  end component dff;

  component dff8 is
    port
        (
          d   : in  std_logic_vector(17 downto 0);
          clk : in  std_logic;
          q   : out std_logic_vector(17 downto 0);
          rst : in  std_logic
        );
  end component dff8;

  --component dffvalid is
      --port
      --(
        --  i_clk  : in  std_logic;
        --  i_rstb : in  std_logic;
        --  i_data : in  std_logic;
      --    o_data : out std_logic
  --  );
--  end component dffvalid;

  begin
    dff1: dff
      port map (d => data_in,     clk => clk, q => ff_1,     rst => rst);
    dff2: dff
      port map (d => ff_1,        clk => clk, q => ff_2,     rst => rst);
    dff3: dff
      port map (d => ff_2,        clk => clk, q => ff_3,     rst => rst);
    dff_out: dff8
      port map (d => sum_data,    clk => clk, q => data_out, rst => rst);
    --dff_valid: dffvalid
      --port map (i_clk => clk, i_rstb  => rst, i_data  => nxt, o_data  => valid_out);

    mult : process(clk)

    begin
      sum_data <= std_logic_vector(
      resize(shift_right((signed(c_0)*signed(data_in)) +
                         (signed(c_1)*signed(ff_1))    +
                         (signed(c_2)*signed(ff_2))    +
                         (signed(c_3)*signed(ff_3))     ,8 ),18 ));
    end process mult;

end architecture test;
