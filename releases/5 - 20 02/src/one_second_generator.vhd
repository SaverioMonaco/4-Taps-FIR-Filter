library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity one_second_generator is

  port (
    clock        : in  std_logic;
    one_second_out : out std_logic);

end entity one_second_generator;


architecture rtl of one_second_generator is
  signal counter   : unsigned(31 downto 0) := (others => '0');
  constant divisor : unsigned(31 downto 0) := to_unsigned(100000000, 32);
begin  -- architecture rtl
  main : process (clock) is
  begin  -- process main
    if rising_edge(clock) then          -- rising clock edge
      counter <= counter + 1;
      if counter = divisor then
        one_second_out <= '1';
        counter      <= (others => '0');
      else
        one_second_out <= '0';
      end if;
    end if;
  end process main;

end architecture rtl;
