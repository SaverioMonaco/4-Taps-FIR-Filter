library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--                     4 TAPS FIR FILTER
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
    fir_clk        : in  std_logic;
    fir_rstb       : in  std_logic;

    -- valid signals for UART implementation
    fir_i_valid : in  std_logic;
    fir_o_valid : out std_logic;

    -- coefficients
    fir_coeff_0    : in  std_logic_vector(7 downto 0);
    fir_coeff_1    : in  std_logic_vector(7 downto 0);
    fir_coeff_2    : in  std_logic_vector(7 downto 0);
    fir_coeff_3    : in  std_logic_vector(7 downto 0);

    -- data input
    fir_i_data       : in  std_logic_vector(7 downto 0);
    -- filtered data
    fir_o_data       : out std_logic_vector(9 downto 0));
end fir_filter_4;

architecture rtl of fir_filter_4 is
  -- Array of the datas X[N], X[N-1], X[N-2] and X[N-3]
  type t_data_pipe      is array (0 to 3) of signed(7  downto 0);
  -- Array of coefficients
  type t_coeff          is array (0 to 3) of signed(7  downto 0);
  -- Array to store the data times the coefficients, it must be an array of
  -- 4 elements of size 16 bits (see image below)
  type t_mult           is array (0 to 3) of signed(15    downto 0);
  -- Array to store the two elements from the first addition:
  -- | X[N]*C0 + X[N-1]*C1 | X[N-2]*C2 + X[N-3]*C3 |
  type t_add_st0        is array (0 to 1) of signed(15+1  downto 0);

  signal r_coeff              : t_coeff ;
  signal p_data               : t_data_pipe;
  signal r_mult               : t_mult;
  signal r_add_st0            : t_add_st0;

  -- to store the final value before resizing, it must be a value of 18 bits
  signal r_add_st1            : signed(15+2  downto 0);

  begin
--
--                                       ALGORITH
--   8 bits    *PI*               *PI*               *PI*               *PI*
--  ----->  |__X[N]__|        |_X[N-1]_|         |_X[N-2]_|         |_X[N-3]_|
--  INPUT       |                  |                  |                  |
--        *PM*  X C0          *PM* X C1          *PM* X C2          *PM* X C3
--              |                  |                  |                  |
--              |  16bits          |  16bits          |  16bits          |  16bits
--              |      *PA0*       |                  |       *PA0*      |
--              |________+_________|                  |_________+________|
--                       |                                      |
--                       |  17bits         *PA1*                |  17bits
--                       |___________________+__________________|
--                                           |
--                                           |  18bits
--                                           |
--                                     *PO* << 8
--                                           |  10bits
--                                           V
 --                                       OUTPUT
  --
   --
    -- This process sets everything up for a new data to be filtered, it either
    -- resets everything:
    --                     p_data       <= (others=>(others=>'0'));
    --                     r_coeff      <= (others=>(others=>'0'));
    -- Or just shift every past data:
    --                     X[N]   -> X[N-1]
    --                     X[N-1] -> X[N-2]
    --                     X[N-2] -> X[N-3]
    --                     X[N-3] -> void
    -- so that the new data can be placed in X[N]
    p_input : process (fir_rstb,fir_clk) -- *PI*
      begin
        if(fir_rstb='0') then
          -- this just set every element of the array to vectors of 0s
          p_data       <= (others=>(others=>'0'));
          r_coeff      <= (others=>(others=>'0'));
        elsif(rising_edge(fir_clk)) then
          if(fir_i_valid='1') then
          -- This is actually a really clever trick to shift and put the new
          -- value at the first place in the array:
          -- Notice that "&" is concatenation: we define the new p_data array
          -- as the concatenation of the new data (at the first place) and the
          -- first 3 data of the array p_data:
          --               |----------------- p_data (old) -----------------|
          --  | fir_i_data | p_data[0] | p_data_[1] | p_data[2] | p_data[3] |
          --  |-------------------- p_data (new) ---------------|
            p_data      <= signed(fir_i_data) & p_data(0 to p_data'length-2);
            r_coeff(0)  <= signed(fir_coeff_0);
            r_coeff(1)  <= signed(fir_coeff_1);
            r_coeff(2)  <= signed(fir_coeff_2);
            r_coeff(3)  <= signed(fir_coeff_3);
          end if;
        end if;
      end process p_input;

    -- This process just give you the r_mult array that is an array of every
    -- data X[i]  N-3<=i<=N times its coefficient
    -- It is an array of 4 vectors of size 16
    p_mult : process (fir_rstb,fir_clk) -- *PM*
      begin
        if(fir_rstb='0') then
          r_mult       <= (others=>(others=>'0'));
        elsif(rising_edge(fir_clk)) then
          if(fir_i_valid='1') then
            for k in 0 to 3 loop
              -- Apply the multiplication for every data in the array of datas
              r_mult(k)       <= p_data(k) * r_coeff(k);
            end loop;
          end if;
        end if;
    end process p_mult;

    -- The first 2 additions, that is:
    --      X[N]  + X[N-1]
    --     X[N-2] + X[N-3]
    -- The output is an array of two vectors of 17 bits
    p_add_st0 : process (fir_rstb,fir_clk) -- *PA0*
      begin
        if(fir_rstb='0') then
          r_add_st0     <= (others=>(others=>'0'));
        elsif(rising_edge(fir_clk)) then
          if(fir_i_valid='1') then
            for k in 0 to 1 loop -- 0 for the addition between X[N]   and X[N-1]
                                 --  1 for the addition between X[N-2] and X[N-3]
              -- I guess resizing it before the multiplication makes you have no
              -- risk of overflow, since it will make a 0 appear to the left, and
              -- in the worst case scenario, it will become 1 after the addition
              r_add_st0(k)     <= resize(r_mult(2*k),17)  + resize(r_mult(2*k+1),17);
              -- r_add_st0(0) <= resize(r_mult(0),17)  + resize(r_mult(1),17);
              -- r_add_st0(1) <= resize(r_mult(2),17)  + resize(r_mult(3),17);
            end loop;
          end if;
        end if;
    end process p_add_st0;

    -- Simply adds the two final terms together, as to the first addition, the
    -- two terms were firstly resized to avoid overflows
    p_add_st1 : process (fir_rstb,fir_clk) -- *PA1*
      begin
        if(fir_rstb='0') then
          r_add_st1     <= (others=>'0');
        elsif(rising_edge(fir_clk)) then
          if(fir_i_valid='1') then
            r_add_st1     <= resize(r_add_st0(0),18)  + resize(r_add_st0(1),18);
          end if;
        end if;
    end process p_add_st1;

    -- We resize the output by taking in consideration only the first 10 terms
    p_output : process (fir_rstb,fir_clk) -- *PO*
      begin
        if(fir_rstb='0') then
          fir_o_data     <= (others=>'0');
        elsif(rising_edge(fir_clk)) then
          if(fir_i_valid = '1') then
            fir_o_data     <= std_logic_vector(r_add_st1(17 downto 8)); -- here
            fir_o_valid <= '1'
          end if;
        end if;
    end process p_output;

end rtl;
