library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AvalonStreamTransactionPkg.all;

package AvalonStreamTransactionProcedures is
  -- Procedure to send data via Avalon streaming
  procedure SendAvalonStream(
    signal transaction : out AvalonStreamTransactionType;
    data_in            : in std_logic_vector(31 downto 0)
  );

  -- Procedure to receive data via Avalon streaming
  procedure ReceiveAvalonStream(
    signal transaction : in AvalonStreamTransactionType;
    signal data_out    : out std_logic_vector(31 downto 0)
  );
end package AvalonStreamTransactionProcedures;

package body AvalonStreamTransactionProcedures is
  -- Implementation of SendAvalonStream procedure
  procedure SendAvalonStream(
    signal transaction : out AvalonStreamTransactionType;
    data_in            : in std_logic_vector(31 downto 0)
  ) is
  begin
    transaction.data  <= data_in;
    transaction.valid <= '1';
  end procedure SendAvalonStream;

  -- Implementation of ReceiveAvalonStream procedure
  procedure ReceiveAvalonStream(
    signal transaction : in AvalonStreamTransactionType;
    signal data_out    : out std_logic_vector(31 downto 0)
  ) is
  begin
    if transaction.valid = '1' and transaction.ready = '1' then
      data_out <= transaction.data;
    else
      data_out <= (others => '0');
    end if;
  end procedure ReceiveAvalonStream;
end package body AvalonStreamTransactionProcedures;
