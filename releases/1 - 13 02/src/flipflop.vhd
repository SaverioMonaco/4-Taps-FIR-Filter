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

entity dff is
  port (
    -- il clock --
    clk : in std_logic;
    rst : in std_logic; --rst sta per reset
    -- l'input
    d   : in std_logic_vector(7 downto 0);
    -- l'output --
    q   : out std_logic_vector(7 downto 0));
end entity dff;

architecture rtl of dff is
begin -- architecture rtl
  flipflop : process (clk) is
  begin -- process flipflop
    if rising_edge(clk) then
      if rst = '0' then
        q <= (others => '0');
      else
        q <= d;
      end if;
    end if;
  end process flipflop;

end architecture rtl;
