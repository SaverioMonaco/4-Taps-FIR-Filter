library ieee;
use ieee.std_logic_1164.all;



entity top is

  port (

    CLK100MHZ    : in  std_logic;
    uart_txd_in  : in  std_logic;
    uart_rxd_out : out std_logic);

end entity top;

architecture str of top is
  signal clock           : std_logic;
  signal data_valid      : std_logic;
  signal data_valid_fil  : std_logic;
  signal busy            : std_logic;
  signal uart_tx         : std_logic;
  signal unfiltered_data : std_logic_vector(7 downto 0);
  signal filtered_data   : std_logic_vector(9 downto 0);

  signal i_rstb    : std_logic := '1';


  component uart_transmitter is
    port (
      clock          : in  std_logic;
      data_to_python : in  std_logic_vector(9 downto 0);
      data_valid     : in  std_logic;
      busy           : out std_logic;
      uart_tx        : out std_logic);
  end component uart_transmitter;

  component uart_receiver is
    port (
      clock            : in  std_logic;
      uart_rx          : in  std_logic;
      valid            : out std_logic;
      data_from_python : out std_logic_vector(7 downto 0));
  end component uart_receiver;

  component fir_filter_4 is
    port (
      clk : in  std_logic;
      nxt : in  std_logic;
      rst : in  std_logic;

      data_in    : in  std_logic_vector(7 downto 0);

      valid_out  : out std_logic;
      data_out   : out std_logic_vector(9 downto 0)

      );
  end component fir_filter_4;

-- TOP manages the interactions between the uart (transmitter and reciver)
-- and the process of filtering data:
--                                                               ___________
--   ____________        ______________  Data and data valid    |          |
--  |           |       |   Receiver  | --------------------->  |          |
--  |           |----> |_____________|                          |   FIR    |
--  |  Python   |       ______________   Data and data valid    |  Filter  |
--  |           |<---- | Transmitter | <---------------------   |          |
--  |___________|     |_____________|                           |__________|
--
--  |____PC____|     |_____________________FPGA____________________________|


begin  -- architecture str
-- This is the core process that manages the interaction between UART and FIR:
-- First we want to use the receiver to receive data:
  uart_receiver_1 : uart_receiver
    port map (
      clock            => CLK100MHZ,
      uart_rx          => uart_txd_in,
      valid            => data_valid,
      data_from_python => unfiltered_data);

-- Then we want to use the Filter:
  fir_filter_1 : fir_filter_4
    port map (
      clk       => CLK100MHZ,
      nxt       => data_valid,
      rst       => i_rstb,
      valid_out => data_valid_fil,

      data_in   => unfiltered_data,
      -- filtering here
      data_out  => filtered_data);

-- Finally we want to transmit back out filtered data:
  uart_transmitter_1 : uart_transmitter
    port map (
      clock          => CLK100MHZ,
      data_to_python => filtered_data,
      data_valid     => data_valid_fil,
      busy           => busy,
      uart_tx        => uart_rxd_out);

end architecture str;
