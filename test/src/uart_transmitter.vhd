library ieee;
use ieee.std_logic_1164.all;



entity uart_transmitter is

  port (
    clock          : in  std_logic;
    data_to_python : in  std_logic_vector(17 downto 0);
    data_valid     : in  std_logic;
    busy           : out std_logic;
    uart_tx        : out std_logic);

end entity uart_transmitter;


architecture rtl of uart_transmitter is


  component baudrate_generator is
    port (
      clock        : in  std_logic;
      baudrate_out : out std_logic);
  end component baudrate_generator;

  signal baudrate_out : std_logic;
-- state machine signals
  type state_t is (idle_s, data_valid_s, start_s, bit0_s, bit1_s, bit2_s, bit3_s, bit4_s, bit5_s, bit6_s, bit7_s, bit8_s, bit9_s, bit10_s, bit11_s, bit12_s, bit13_s, bit14_s, bit15_s, bit16_s, bit17_s, stop_s);

  signal state : state_t := idle_s;
begin  -- architecture rtl

  baudrate_generator_1 : baudrate_generator
    port map (
      clock        => clock,
      baudrate_out => baudrate_out);


  -- State Machine


  main_state_machine : process (clock) is
  begin  -- process main_state_machine
    if rising_edge(clock) then          -- rising clock edge
      case state is
        when idle_s =>
          busy    <= '0';
          uart_tx <= '1';
          if data_valid = '1' then
            state <= data_valid_s;
          end if;
        when data_valid_s =>
          busy <= '1';
          if baudrate_out = '1' then
            state <= start_s;
          end if;
        when start_s =>
          uart_tx <= '0';
          if baudrate_out = '1' then
            state <= bit0_s;
          end if;
        when bit0_s =>
          uart_tx <= data_to_python(0);
          if baudrate_out = '1' then
            state <= bit1_s;
          end if;
        when bit1_s =>
          uart_tx <= data_to_python(1);
          if baudrate_out = '1' then
            state <= bit2_s;
          end if;
        when bit2_s =>
          uart_tx <= data_to_python(2);
          if baudrate_out = '1' then
            state <= bit3_s;
          end if;
        when bit3_s =>
          uart_tx <= data_to_python(3);
          if baudrate_out = '1' then
            state <= bit4_s;
          end if;
        when bit4_s =>
          uart_tx <= data_to_python(4);
          if baudrate_out = '1' then
            state <= bit5_s;
          end if;
        when bit5_s =>
          uart_tx <= data_to_python(5);
          if baudrate_out = '1' then
            state <= bit6_s;
          end if;
        when bit6_s =>
          uart_tx <= data_to_python(6);
          if baudrate_out = '1' then
            state <= bit7_s;
          end if;
        when bit7_s =>
          uart_tx <= data_to_python(7);
          if baudrate_out = '1' then
            state <= bit8_s;
          end if;
          when bit8_s =>
            uart_tx <= data_to_python(8);
            if baudrate_out = '1' then
              state <= bit9_s;
            end if;
            when bit9_s =>
              uart_tx <= data_to_python(9);
              if baudrate_out = '1' then
                state <= bit10_s;
              end if;
              when bit10_s =>
                uart_tx <= data_to_python(10);
                if baudrate_out = '1' then
                  state <= bit11_s;
                end if;
                when bit11_s =>
                  uart_tx <= data_to_python(11);
                  if baudrate_out = '1' then
                    state <= bit12_s;
                  end if;
                  when bit12_s =>
                    uart_tx <= data_to_python(12);
                    if baudrate_out = '1' then
                      state <= bit13_s;
                    end if;
                    when bit13_s =>
                      uart_tx <= data_to_python(13);
                      if baudrate_out = '1' then
                        state <= bit14_s;
                      end if;
                      when bit14_s =>
                        uart_tx <= data_to_python(14);
                        if baudrate_out = '1' then
                          state <= bit15_s;
                        end if;
                        when bit15_s =>
                          uart_tx <= data_to_python(15);
                          if baudrate_out = '1' then
                            state <= bit16_s;
                          end if;
                          when bit16_s =>
                            uart_tx <= data_to_python(16);
                            if baudrate_out = '1' then
                              state <= bit17_s;
                            end if;
        when bit17_s =>
          uart_tx <= data_to_python(17);
          if baudrate_out = '1' then
            state <= stop_s;
          end if;

        when stop_s =>
          uart_tx <= '1';
          if baudrate_out = '1' then
            state <= idle_s;
          end if;
        when others => null;
      end case;
    end if;
  end process main_state_machine;

end architecture rtl;
