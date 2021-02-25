-- FLIPFLOP --
--            ____________
--           |            |
--      a -->|            |
--           |            |--> q
--    clk -->|            |
--           |____________|
--
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity dff8 is
  port (
    -- il clock --
    clk : in std_logic;
    rst : in std_logic; --rst sta per reset
    -- l'input
    d   : in std_logic_vector(17 downto 0);
    -- l'output --
    q   : out std_logic_vector(17 downto 0));
end entity dff8;

architecture rtl of dff8 is
begin -- architecture rtl
  flipflop : process (clk) is
  begin -- process flipflop
    if rising_edge(clk) then
      if rst = '0' then
        q <= (others => '0');
      else
        q <= std_logic_vector(resize(signed(d) ,18 ));
      end if;
    end if;
  end process flipflop;

end architecture rtl;
