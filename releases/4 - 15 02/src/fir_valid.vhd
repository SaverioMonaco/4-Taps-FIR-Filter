library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dffvalid is
    port
    (
        i_clk  : in  std_logic;
        i_rstb : in  std_logic;
        i_data : in  std_logic;
        o_data : out std_logic
    );
end entity dffvalid;


architecture std of dffvalid is

    signal counter : unsigned(1 downto 0) := to_unsigned(0,2);
    constant delay : unsigned(1 downto 0) := to_unsigned(1,2);

    type state_t is (Delaying,Idle);
    signal state : state_t := Idle;

begin -- architecture rtl

    delay_2_process : process (i_clk,i_rstb) is
    begin -- process main

        if rising_edge(i_clk) then --i_clk

            if i_rstb = '1' then

                case state is

                    when Idle =>

                        o_data <= '0';

                        if i_data = '1' then
                            state <= Delaying;
                            counter <= to_unsigned(0,2);
                        end if;

                    when Delaying =>

                        counter <= counter + 1;

                        if counter=delay then
                            o_data <= '1';
                            state <= Idle;
                        end if;

                    when others =>
                        null;

                end case;

            else

                o_data<='0';

            end if;

        end if; --clk

    end process delay_2_process;


end architecture std;
