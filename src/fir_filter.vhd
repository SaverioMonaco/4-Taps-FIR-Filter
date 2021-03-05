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
    fir_o_data       : out std_logic_vector(7 downto 0));
end fir_filter_4;

architecture rtl of fir_filter_4 is
	-- type: data pipeline and coefficients
    type pip_data	is array (0 to 3) of signed(7 downto 0);
    type coeffs		is array (0 to 3) of signed(7 downto 0);
	-- type: sum and multiplication arrays
    type mult 	is array (0 to 3) of signed(2*8-1 downto 0);
    type sum	is array (0 to 1) of signed(2*8 downto 0);
    	-- signal declaration
    signal coeff	: coeffs;
    signal data		: pip_data; -- pipeline of historic data values
    signal conv		: mult;	    -- array of (coefficient*data) products
    signal sum0		: sum;
    signal sum1		: signed(2*8+1 downto 0);

begin

    data_input : process (fir_rstb, fir_clk)
    begin

        if(fir_rstb = '0') then -- reset all signals
            data  <= (others => (others => '0')); -- clear data pipeline values
            coeff <= (others => (others => '0')); -- clear coefficient registers
        elsif(rising_edge(fir_clk)) then -- insert new sample at the beginning, shift the others
      	    if fir_i_valid = '1' then
    		data     <= signed(fir_i_data)&data(0 to data'length-2); -- shift new data into data pipeline
		coeff(0) <= signed(fir_coeff_0); --input coefficients
		coeff(1) <= signed(fir_coeff_1);
		coeff(2) <= signed(fir_coeff_2);
		coeff(3) <= signed(fir_coeff_3);
            end if;
  	end if;
    end process data_input;

    convolution : process (fir_rstb, fir_clk)
    begin

        if(fir_rstb = '0') then
            conv <= (others => (others => '0'));
        elsif(rising_edge(fir_clk)) then
	    if fir_i_valid = '1' then
                for k in 0 to 3 loop
                    conv(k) <= data(k) * coeff(k); -- perform convolution
            	end loop;
	    end if;
        end if;
    end process convolution;

    add0 : process (fir_rstb, fir_clk)
    begin

        if(fir_rstb = '0') then
            sum0 <= (others => (others => '0'));
        elsif(rising_edge(fir_clk)) then
	    if fir_i_valid = '1' then
                for k in 0 to 1 loop
                    sum0(k) <= resize(conv(2*k), 2*8+1) + resize(conv(2*k+1), 2*8+1);
            	end loop;
	    end if;
        end if;
    end process add0;

    add1 : process (fir_rstb, fir_clk)
    begin

        if(fir_rstb = '0') then
            sum1 <= (others => '0');
        elsif(rising_edge(fir_clk)) then
	    if fir_i_valid = '1' then
	        sum1 <= resize(sum0(0), 2*8+2) + resize(sum0(1), 2*8+2);
	    end if;
        end if;
    end process add1;

    data_output : process (fir_rstb, fir_clk)
    begin

        if(fir_rstb = '0') then
            fir_o_data <= (others => '0');
        elsif(rising_edge(fir_clk)) then
	    if fir_i_valid = '1' then
                fir_o_valid <= '1';
		fir_o_data <= std_logic_vector(sum1(17 downto 10));
  else fir_o_valid <= '0';
            end if;
	end if;
    end process data_output;

end rtl;
