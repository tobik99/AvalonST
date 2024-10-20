library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AvalonStreamTransactionPkg.all;

library osvvm;
context osvvm.OsvvmContext;
use osvvm.ScoreboardPkg_slv.all;

library OSVVM_Common;
context OSVVM_Common.OsvvmCommonContext;
---
---
---
entity AvalonStreamTransmitter is
  generic (
    g_model_id_name : string           := "";
    g_init_channel  : std_logic_vector := "";
    tperiod_Clk     : time             := 10 ns;
    DEFAULT_DELAY   : time             := 1 ns;
    tpd_Clk_Valid   : time             := DEFAULT_DELAY;
    tpd_Clk_Data    : time             := DEFAULT_DELAY;
    tpd_Clk_SOP     : time             := DEFAULT_DELAY;
    tpd_Clk_EOP     : time             := DEFAULT_DELAY;
    tpd_Clk_Channel : time             := DEFAULT_DELAY
  );
  port (
    -- Globals
    i_clk    : in std_logic;
    in_reset : in std_logic;

    -- Avalon Streaming Interface
    o_valid           : out std_logic;
    i_ready           : in std_logic;
    o_data            : out std_logic_vector;
    o_start_of_packet : out std_logic;
    o_end_of_packet   : out std_logic;
    o_channel         : out std_logic_vector;

    -- Testbench Transaction Interface
    io_trans_rec : inout StreamRecType
  );

  -- Derive Avalon interface properties from interface signals
  constant c_avalon_stream_data_width : integer := o_data'length;
  constant c_avalon_channel_width     : integer := o_channel'length;

  -- Use MODEL_ID_NAME Generic if set, otherwise,
  -- use model instance label (preferred if set as entityname_1)
  constant c_model_instance_name : string :=
  ifelse(g_model_id_name'length > 0, g_model_id_name,
  to_lower(PathTail(AvalonStreamTransmitter'PATH_NAME)));
end entity AvalonStreamTransmitter;
---
---
---
architecture Behavioral of AvalonStreamTransmitter is
  signal ModelID, BusFailedID : AlertLogIDType;
  signal BurstCov             : DelayCoverageIDType;
  signal UseCoverageDelays    : boolean := FALSE;

  signal TransmitFifo : osvvm.ScoreboardPkg_slv.ScoreboardIDType;

  signal TransmitRequestCount, TransmitDoneCount : integer := 0;
  signal ValidDelayCycles      : integer := 0 ;
  signal ValidBurstDelayCycles : integer := 0 ;

  -- Verification Component Configuration
  signal TransmitReadyTimeOut : integer := 0; -- No timeout
begin

  ------------------------------------------------------------
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
    variable ID : AlertLogIDType;
  begin
    -- Alerts
    ID := NewID(c_model_instance_name);
    ModelID <= ID;
    --    ProtocolID       <= NewID("Protocol Error", ID ) ;
    --    DataCheckID      <= NewID("Data Check", ID ) ;
    BusFailedID  <= NewID("No response", ID);
    TransmitFifo <= NewID("TransmitFifo", ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    wait;
  end process Initialize;
  ---
  ---
  ---
  TransactionHandler : process
    alias Operation : StreamOperationType is io_trans_rec.Operation;

  begin
    -- Initialize Outputs
    --Address <= (Address'range => 'X');
    --Write   <= 'X';
    --oData   <= (oData'range => 'X');

    wait for 0 ns; -- Allow ModelID to become valid
    loop
      WaitForTransaction(
      Clk => i_clk,
      Rdy => io_trans_rec.Rdy,
      Ack => io_trans_rec.Ack
      );

      case Operation is
          -- Execute Standard Directive Transactions
        when WAIT_FOR_TRANSACTION =>
          wait for 0 ns;

        when WAIT_FOR_CLOCK =>
          WaitForClock(i_clk, io_trans_rec.IntToModel);

        when GET_ALERTLOG_ID =>
          -- TransRec.IntFromModel <= integer(ModelID);

          -- Model Transaction Dispatch
        when SEND   =>
        when others =>
          --Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE);

      end case;
    end loop;
  end process;

  ------------------------------------------------------------
--  TransmitHandler
--    Execute Write Address Transactions for Avalon Streaming
------------------------------------------------------------
TransmitHandler : process
--variable ID    : std_logic_vector(TID'range)   ;
variable Data  : std_logic_vector(o_data'length-1 downto 0) ;
variable Last   : std_logic ;
variable NewTransfer : std_logic := '1' ;
variable DelayCycles : integer ; 

begin
-- Initialize
o_valid <= '0' ;
o_data  <= (others => 'X') ;
o_start_of_packet <= '0' ;
o_end_of_packet   <= '0' ;
o_channel         <= (others => 'X') ;
wait for 0 ns ; -- Allow Cov models to initialize 

-- Begin main transmit loop
TransmitLoop : loop
    -- Find Transaction
    if Empty(TransmitFifo) then
        WaitForToggle(TransmitRequestCount) ;
    end if ;

    -- Get Transaction
    (Data, Last) := Pop(TransmitFifo) ;

    -- Delay between consecutive signaling of Valid
    if UseCoverageDelays then 
        DelayCycles := GetRandDelay(BurstCov) ; 
        WaitForClock(i_clk, DelayCycles) ;
    else
        if NewTransfer or not Last then
            WaitForClock(i_clk, ValidDelayCycles) ; -- delay cycles
        else
            WaitForClock(i_clk, ValidBurstDelayCycles) ;  -- beat delays
        end if ;
        NewTransfer := Last ;
    end if ; 

    -- Do Transaction
    o_data <= Data after tpd_Clk_Data ;
    o_start_of_packet <= '1' after tpd_Clk_SOP ;
    o_end_of_packet <= Last after tpd_Clk_EOP ;
    o_valid <= '1' after tpd_Clk_Valid ;

    Log(ModelID,
        "Avalon Stream Send." &
        "  o_data: " & to_hxstring(Data) &
        "  o_start_of_packet: " & to_string(o_start_of_packet) &
        "  o_end_of_packet: " & to_string(o_end_of_packet) &
        "  Operation# " & to_string(TransmitDoneCount + 1),
        INFO
    ) ;

    ---------------------
    -- Handshake Logic
    ---------------------
    if o_valid = '1' and i_ready = '1' then
        -- Signal completion
        Increment(TransmitDoneCount) ;
        o_valid <= '0'; -- Reset valid signal
        wait for 0 ns ;
    end if ;

    -- State after transaction
    -- Hier können zusätzliche logische Zustände verwaltet werden

end loop TransmitLoop ;
end process TransmitHandler ;
end architecture Behavioral;