library ieee;
use ieee.std_logic_1164.all;

entity AvalonStreamTestHarness is
end entity AvalonStreamTestHarness;

architecture testharness of AvalonStreamTestHarness is
  -- Signal Declarations
  signal clk          : std_logic := '0';
  signal reset_n      : std_logic := '0';
  
  -- Avalon Streaming Interface Signals
  signal data_in      : std_logic_vector(31 downto 0);
  signal valid_in     : std_logic;
  signal ready_out    : std_logic;
  signal startofpacket: std_logic;
  signal endofpacket  : std_logic;
  
  signal data_out     : std_logic_vector(31 downto 0);
  signal valid_out    : std_logic;
  signal ready_in     : std_logic;

  signal error        : std_logic;

  -- Clock Period
  constant clk_period : time := 10 ns;
  
begin
  -- Clock Generation
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process clk_process;

  -- Reset Generation
  reset_process : process
  begin
    reset_n <= '0';
    wait for 50 ns;  -- Wait for reset
    reset_n <= '1';
    wait;
  end process reset_process;

  -- Instantiate the Avalon Streaming Component Under Test (CUT)
  uut: entity work.AvalonStreamSlaveVC
    port map (
      clk          => clk,
      reset_n      => reset_n,
      data_in      => data_in,
      valid_in     => valid_in,
      ready_out    => ready_out,
      startofpacket=> startofpacket,
      endofpacket  => endofpacket,
      data_out     => data_out,
      valid_out    => valid_out,
      ready_in     => ready_in,
      error        => error
    );

end architecture testharness;
