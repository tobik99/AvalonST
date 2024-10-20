library ieee;
use ieee.std_logic_1164.all;

library osvvm;
context osvvm.OsvvmContext;
use osvvm.TextUtilPkg.all;           -- For logging and reporting

entity AvalonStreamTestbench is
end entity AvalonStreamTestbench;

architecture tb of AvalonStreamTestbench is
  -- Signals for the testbench
  signal clk          : std_logic := '0';
  signal reset_n      : std_logic := '0';

  signal data_in      : std_logic_vector(31 downto 0);
  signal valid_in     : std_logic;
  signal ready_out    : std_logic;
  signal startofpacket: std_logic;
  signal endofpacket  : std_logic;

  signal data_out     : std_logic_vector(31 downto 0);
  signal valid_out    : std_logic;
  signal ready_in     : std_logic;

  signal error        : std_logic;
  
  -- Clock period
  constant clk_period : time := 10 ns;
  
begin
  -- Instantiate the test harness
  uut: entity work.AvalonStreamSlaveVC;

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

  -- Main test process
  test_process : process
  begin
    -- Wait for reset to de-assert
    wait until reset_n = '1';
    
    -- Initial test values
    ready_in <= '1';  -- The downstream device is ready to accept data

    -- Step 1: Send a valid packet
    data_in <= x"00000001";
    valid_in <= '1';
    startofpacket <= '1';
    endofpacket <= '0';
    wait for clk_period;

    -- Step 2: Send middle of packet
    data_in <= x"00000002";
    valid_in <= '1';
    startofpacket <= '0';
    endofpacket <= '0';
    wait for clk_period;

    -- Step 3: Send end of packet
    data_in <= x"00000003";
    valid_in <= '1';
    startofpacket <= '0';
    endofpacket <= '1';
    wait for clk_period;

    -- De-assert valid signal after sending the packet
    valid_in <= '0';
    wait for clk_period;

    -- Check if the component processed the data correctly
    assert (data_out = x"00000003") report "Test Passed" severity note;
    assert (valid_out = '1') report "Valid signal assertion failed" severity failure;

    -- End simulation
    wait;
  end process test_process;

end architecture tb;
