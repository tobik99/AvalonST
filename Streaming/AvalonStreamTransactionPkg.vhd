library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package AvalonStreamTransactionPkg is
  -- Define the transaction interface as a record for Avalon Streaming
  type AvalonStreamTransactionType is record
    data   : std_logic_vector(31 downto 0); -- 32-bit data stream
    valid  : std_logic;                     -- Valid signal from master
    ready  : std_logic;                     -- Ready signal from slave
  end record AvalonStreamTransactionType;
end package AvalonStreamTransactionPkg;
