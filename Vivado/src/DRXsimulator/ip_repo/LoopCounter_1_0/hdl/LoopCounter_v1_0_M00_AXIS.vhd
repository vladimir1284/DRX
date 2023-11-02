library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LoopCounter_v1_0_M00_AXIS is
  generic
  (
    -- Users to add parameters here
    CELLS_DATA_WIDTH : integer := 16; --! The maximum number of cells in a transaction is 2^CELLS_DATA_WIDTH
    -- User parameters ends
    -- Do not modify the parameters beyond this line

    --! Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
    C_M_AXIS_TDATA_WIDTH : integer := 32;
    --! Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
    C_M_START_COUNT : integer := 32
  );
  port
  (
    -- Users to add ports here
    ENABLE        : in std_logic; --! Ascynchronous reset signal from the counter configurator
    CELLS_IN_PRT  : in std_logic_vector(CELLS_DATA_WIDTH - 1 downto 0);--! Number of cells in a Pulse Repetition Time (PRT)
    CELLS_TO_SEND : in std_logic_vector(CELLS_DATA_WIDTH - 1 downto 0);--! Number of cells to be adquired
    VALID_CONFIG  : out std_logic; --! Validates that CELLS_IN_PRT >= CELLS_TO_SEND
    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Global ports
    M_AXIS_ACLK : in std_logic;
    -- 
    M_AXIS_ARESETN : in std_logic;
    --! Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
    M_AXIS_TVALID : out std_logic;
    --! TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
    M_AXIS_TDATA : out std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
    --! TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
    M_AXIS_TSTRB : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8) - 1 downto 0);
    --! TLAST indicates the boundary of a packet.
    M_AXIS_TLAST : out std_logic;
    --! TREADY indicates that the slave can accept a transfer in the current cycle.
    M_AXIS_TREADY : in std_logic
  );
end LoopCounter_v1_0_M00_AXIS;

architecture implementation of LoopCounter_v1_0_M00_AXIS is

  --! function called clogb2 that returns an integer which has the   
  --! value of the ceiling of the log base 2.                              
  function clogb2 (bit_depth : integer) return integer is
    variable depth             : integer := bit_depth;
    variable count             : integer := 1;
  begin
    for clogb22 in 1 to bit_depth loop -- Works for up to 32 bit integers
      if (bit_depth <= 2) then
        count := 1;
      else
        if (depth <= 1) then
          count := count;
        else
          depth := depth / 2;
          count := count + 1;
        end if;
      end if;
    end loop;
    return(count);
  end;

  --! WAIT_COUNT_BITS is the width of the wait counter.                       
  constant WAIT_COUNT_BITS : integer := clogb2(C_M_START_COUNT - 1);
  --! Define the states of state machine.       
  --! IDLE: This is the initial/idle state.                                        
  --! INIT_COUNTER: This state initializes the counter, once the counter reaches C_M_START_COUNT count, the state machine changes state to SEND_STREAM. 
  --! SEND_STREAM: In this state the stream data is output through M_AXIS_TDATA.   
  --! WAIT_PRT: Wait the number of cycles for completing the Pulse.                                 
  type state is (
    IDLE,
    INIT_COUNTER,
    SEND_STREAM,
    WAIT_PRT
  );
  --! Repetition Time                                                                
  signal mst_exec_state : state;
  --! Counter index                                               
  signal counter_index : unsigned(CELLS_DATA_WIDTH - 1 downto 0);
  --! transaction counter
  signal transaction_counter : unsigned(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
  --! Reset signal combinig enable and M_AXIS_ARESETN
  signal rst : std_logic;
  --! Internal signal indicating that CELLS_IN_PRT >= CELLS_TO_SEND
  signal config_validated : std_logic;

  --! AXI Stream internal signals
  --!wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
  signal count : std_logic_vector(WAIT_COUNT_BITS - 1 downto 0);
  --!streaming data valid
  signal axis_tvalid : std_logic;
  --!streaming data valid delayed by one clock cycle
  signal axis_tvalid_delay : std_logic;
  --!Last of the streaming data 
  signal axis_tlast : std_logic;
  --!Last of the streaming data delayed by one clock cycle
  signal axis_tlast_delay : std_logic;
  --! Data from counters to AXIS DATA
  signal stream_data_out : std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
  --!The master has issued all the streaming data stored in FIFO
  signal tx_done : std_logic;
begin
  -- I/O Connections assignments

  M_AXIS_TVALID <= axis_tvalid_delay;
  M_AXIS_TDATA  <= stream_data_out;
  M_AXIS_TLAST  <= axis_tlast_delay;
  M_AXIS_TSTRB  <= (others => '1');

  --! Control state machine implementation                                               
  FSM : process (M_AXIS_ACLK)
  begin
    if (rising_edge (M_AXIS_ACLK)) then
      if (rst = '0') then
        -- Synchronous reset (active low)                                                     
        mst_exec_state <= IDLE;
        count          <= (others => '0');
      else
        case (mst_exec_state) is
          when IDLE =>
            -- The slave starts accepting tdata when                                          
            -- there tvalid is asserted to mark the                                           
            -- presence of valid streaming data                                               
            --if (count = "0")then                                                            
            mst_exec_state <= INIT_COUNTER;
            --else                                                                              
            --  mst_exec_state <= IDLE;                                                         
            --end if;                                                                           

          when INIT_COUNTER =>
            -- This state is responsible to wait for user defined C_M_START_COUNT           
            -- number of clock cycles.                                                      
            if (count = std_logic_vector(to_unsigned((C_M_START_COUNT - 1), WAIT_COUNT_BITS))) then
              mst_exec_state <= SEND_STREAM;
            else
              count          <= std_logic_vector (unsigned(count) + 1);
              mst_exec_state <= INIT_COUNTER;
            end if;

          when SEND_STREAM =>
            -- The example design streaming master functionality starts                       
            -- when the master drives output tdata from the FIFO and the slave                
            -- has finished storing the S_AXIS_TDATA                                          
            if (tx_done = '1') then
              mst_exec_state <= WAIT_PRT;
            else
              mst_exec_state <= SEND_STREAM;
            end if;

          when WAIT_PRT =>
            -- Wait the number of cycles for completing the Pulse 
            -- Repetition Time 
            if (counter_index < unsigned(CELLS_IN_PRT)) then
              mst_exec_state <= WAIT_PRT;
            else
              mst_exec_state <= SEND_STREAM;
            end if;

          when others =>
            mst_exec_state <= IDLE;

        end case;
      end if;
    end if;
  end process;
  --tvalid generation
  --axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
  --number of output streaming data is less than the CELLS_TO_SEND + 1 (the transaction counter).
  axis_tvalid <= '1' when ((mst_exec_state = SEND_STREAM) and (counter_index <= unsigned(CELLS_TO_SEND))) else
    '0';

  -- AXI tlast generation                                                                        
  -- axis_tlast is asserted number of output streaming data is CELLS_TO_SEND       
  -- (0 to CELLS_TO_SEND, which includes the transaction counter as first data)                                                             
  axis_tlast <= '1' when (counter_index = unsigned(CELLS_TO_SEND)) else
    '0';

  --! Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
  --! to match the latency of M_AXIS_TDATA                                                        
  delay : process (M_AXIS_ACLK)
  begin
    if (rising_edge (M_AXIS_ACLK)) then
      if (rst = '0') then
        axis_tvalid_delay <= '0';
        axis_tlast_delay  <= '0';
      else
        axis_tvalid_delay <= axis_tvalid;
        axis_tlast_delay  <= axis_tlast;
      end if;
    end if;
  end process;

  --! Increment counter index
  counter : process (M_AXIS_ACLK)
  begin
    if (rising_edge (M_AXIS_ACLK)) then
      if (rst = '0') then
        counter_index       <= (others => '0');
        transaction_counter <= (others => '0');
        tx_done             <= '0';
      else
        counter_index     <= counter_index + 1;
        tx_done           <= '1';
        if (counter_index <= unsigned(CELLS_TO_SEND)) then
          tx_done           <= '0';
        elsif (counter_index = unsigned(CELLS_IN_PRT)) then
          counter_index       <= (others => '0');
          transaction_counter <= transaction_counter + 1;
        end if;
      end if;
    end if;
  end process;

  --! Streaming output from the counter                                      
  output : process (M_AXIS_ACLK)
    variable sig_one : integer := 1;
  begin
    if (rising_edge (M_AXIS_ACLK)) then
      if (rst = '0') then
        stream_data_out <= (others => '0');
      else
        if (counter_index < 1) then
          stream_data_out <= std_logic_vector(transaction_counter);
        else
          stream_data_out <= std_logic_vector(counter_index);
        end if;
      end if;
    end if;
  end process;

  -- Add user logic here
  -- Verify that CELLS_IN_PRT >= CELLS_TO_SEND
  config_validated <= '1' when (unsigned(CELLS_IN_PRT) >= unsigned(CELLS_TO_SEND)) else
    '0';
  VALID_CONFIG <= config_validated;

  --! rst generation combining enable (active in 1) and M_AXIS_ARESETN
  rst <= M_AXIS_ARESETN and enable and config_validated;

  -- User logic ends

end implementation;