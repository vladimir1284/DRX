library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counterConfig_v1_0_S00_AXI_tb is
end counterConfig_v1_0_S00_AXI_tb;

architecture tb_arch of counterConfig_v1_0_S00_AXI_tb is
  -- Component Declaration
  component counterConfig_v1_0_S00_AXI is
    generic
    (
      counter_bits       : integer := 16;
      C_S_AXI_DATA_WIDTH : integer := 32;
      C_S_AXI_ADDR_WIDTH : integer := 4
    );
    port
    (
      freq_div      : out std_logic;
      max_count     : out std_logic_vector (counter_bits - 1 downto 0);
      enable        : out std_logic;
      S_AXI_ACLK    : in std_logic;
      S_AXI_ARESETN : in std_logic;
      S_AXI_AWADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
      S_AXI_WSTRB   : in std_logic_vector((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
      S_AXI_WVALID  : in std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in std_logic;
      S_AXI_ARADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in std_logic
    );
  end component;

  -- Component signals
  signal S_AXI_ACLK    : std_logic                    := '0';
  signal S_AXI_ARESETN : std_logic                    := '0';
  signal S_AXI_AWADDR  : std_logic_vector(3 downto 0) := (others => '0');
  signal S_AXI_AWPROT  : std_logic_vector(2 downto 0) := (others => '0');
  signal S_AXI_AWVALID : std_logic                    := '0';
  signal S_AXI_AWREADY : std_logic;
  signal S_AXI_WDATA   : std_logic_vector(31 downto 0) := (others => '0');
  signal S_AXI_WSTRB   : std_logic_vector(3 downto 0)  := (others => '0');
  signal S_AXI_WVALID  : std_logic                     := '0';
  signal S_AXI_WREADY  : std_logic;
  signal S_AXI_BRESP   : std_logic_vector(1 downto 0);
  signal S_AXI_BVALID  : std_logic;
  signal S_AXI_BREADY  : std_logic;
  signal S_AXI_ARADDR  : std_logic_vector(3 downto 0) := (others => '0');
  signal S_AXI_ARPROT  : std_logic_vector(2 downto 0) := (others => '0');
  signal S_AXI_ARVALID : std_logic                    := '0';
  signal S_AXI_ARREADY : std_logic;
  signal S_AXI_RDATA   : std_logic_vector(31 downto 0);
  signal S_AXI_RRESP   : std_logic_vector(1 downto 0);
  signal S_AXI_RVALID  : std_logic;
  signal S_AXI_RREADY  : std_logic;

  constant ClockPeriod  : time      := 5 ns;
  constant ClockPeriod2 : time      := 10 ns;
  signal sendIt         : std_logic := '0';
  signal readIt         : std_logic := '0';
  -- Signals
  signal freq_div  : std_logic;
  signal max_count : std_logic_vector (15 downto 0);
  signal enable    : std_logic;
begin

  -- Instantiate the component
  uut : counterConfig_v1_0_S00_AXI
  generic
  map (
  counter_bits       => 16,
  C_S_AXI_DATA_WIDTH => 32,
  C_S_AXI_ADDR_WIDTH => 4
  )
  port map
  (
    freq_div      => freq_div,
    max_count     => max_count,
    enable        => enable,
    S_AXI_ACLK    => S_AXI_ACLK,
    S_AXI_ARESETN => S_AXI_ARESETN,
    S_AXI_AWADDR  => S_AXI_AWADDR,
    S_AXI_AWPROT  => S_AXI_AWPROT,
    S_AXI_AWVALID => S_AXI_AWVALID,
    S_AXI_AWREADY => S_AXI_AWREADY,
    S_AXI_WDATA   => S_AXI_WDATA,
    S_AXI_WSTRB   => S_AXI_WSTRB,
    S_AXI_WVALID  => S_AXI_WVALID,
    S_AXI_WREADY  => S_AXI_WREADY,
    S_AXI_BRESP   => S_AXI_BRESP,
    S_AXI_BVALID  => S_AXI_BVALID,
    S_AXI_BREADY  => S_AXI_BREADY,
    S_AXI_ARADDR  => S_AXI_ARADDR,
    S_AXI_ARPROT  => S_AXI_ARPROT,
    S_AXI_ARVALID => S_AXI_ARVALID,
    S_AXI_ARREADY => S_AXI_ARREADY,
    S_AXI_RDATA   => S_AXI_RDATA,
    S_AXI_RRESP   => S_AXI_RRESP,
    S_AXI_RVALID  => S_AXI_RVALID,
    S_AXI_RREADY  => S_AXI_RREADY
  );

  -- Generate S_AXI_ACLK signal
  GENERATE_REFCLOCK : process
  begin
    wait for (ClockPeriod / 2);
    S_AXI_ACLK <= '1';
    wait for (ClockPeriod / 2);
    S_AXI_ACLK <= '0';
  end process;

  -- Initiate process which simulates a master wanting to write.
  -- This process is blocked on a "Send Flag" (sendIt).
  -- When the flag goes to 1, the process exits the wait state and
  -- execute a write transaction.
  send : process
  begin
    S_AXI_AWVALID <= '0';
    S_AXI_WVALID  <= '0';
    S_AXI_BREADY  <= '0';
    loop
      wait until sendIt = '1';
      wait until S_AXI_ACLK = '0';
      S_AXI_AWVALID <= '1';
      S_AXI_WVALID  <= '1';
      wait until (S_AXI_AWREADY and S_AXI_WREADY) = '1'; --Client ready to read address/data        
      S_AXI_BREADY <= '1';
      wait until S_AXI_BVALID = '1'; -- Write result valid
      assert S_AXI_BRESP = "00" report "AXI data not written" severity failure;
      S_AXI_AWVALID <= '0';
      S_AXI_WVALID  <= '0';
      S_AXI_BREADY  <= '1';
      wait until S_AXI_BVALID = '0'; -- All finished
      S_AXI_BREADY <= '0';
    end loop;
  end process send;

  -- Initiate process which simulates a master wanting to read.
  -- This process is blocked on a "Read Flag" (readIt).
  -- When the flag goes to 1, the process exits the wait state and
  -- execute a read transaction.
  read : process
  begin
    S_AXI_ARVALID <= '0';
    S_AXI_RREADY  <= '0';
    loop
      wait until readIt = '1';
      wait until S_AXI_ACLK = '0';
      S_AXI_ARVALID <= '1';
      S_AXI_RREADY  <= '1';
      wait until (S_AXI_RVALID and S_AXI_ARREADY) = '1'; --Client provided data
      assert S_AXI_RRESP = "00" report "AXI data not written" severity failure;
      S_AXI_ARVALID <= '0';
      S_AXI_RREADY  <= '0';
    end loop;
  end process read;
  -- 
  tb : process
  begin
    S_AXI_ARESETN <= '0';
    sendIt        <= '0';
    wait for 15 ns;
    S_AXI_ARESETN <= '1';

    S_AXI_AWADDR <= x"0";
    S_AXI_WDATA  <= x"00000001"; -- Freq div = 1
    S_AXI_WSTRB  <= b"1111";
    sendIt       <= '1'; --Start AXI Write to Slave
    wait for 1 ns;
    sendIt <= '0'; --Clear Start Send Flag
    wait until S_AXI_BVALID = '1';
    wait until S_AXI_BVALID = '0'; --AXI Write finished
    S_AXI_WSTRB <= b"0000";

    S_AXI_AWADDR <= x"4";
    S_AXI_WDATA  <= x"00000001"; -- Enable = 1
    S_AXI_WSTRB  <= b"1111";
    sendIt       <= '1'; --Start AXI Write to Slave
    wait for 1 ns;
    sendIt <= '0'; --Clear Start Send Flag
    wait until S_AXI_BVALID = '1';
    wait until S_AXI_BVALID = '0'; --AXI Write finished
    S_AXI_WSTRB <= b"0000";

    S_AXI_AWADDR <= x"8";
    S_AXI_WDATA  <= x"00000300"; -- Max count = 1024
    S_AXI_WSTRB  <= b"1111";
    sendIt       <= '1'; --Start AXI Write to Slave
    wait for 1 ns;
    sendIt <= '0'; --Clear Start Send Flag
    wait until S_AXI_BVALID = '1';
    wait until S_AXI_BVALID = '0'; --AXI Write finished
    S_AXI_WSTRB <= b"0000";

    S_AXI_AWADDR <= x"0";
    S_AXI_WDATA  <= x"00000000";
    S_AXI_WSTRB  <= b"1111";
    sendIt       <= '1'; --Start AXI Write to Slave
    wait for 1 ns;
    sendIt <= '0'; --Clear Start Send Flag
    wait until S_AXI_BVALID = '1';
    wait until S_AXI_BVALID = '0'; --AXI Write finished
    S_AXI_WSTRB <= b"0000";

    S_AXI_ARADDR <= x"0";
    readIt       <= '1'; --Start AXI Read from Slave
    wait for 1 ns;
    readIt <= '0'; --Clear "Start Read" Flag
    wait until S_AXI_RVALID = '1';
    wait until S_AXI_RVALID = '0';
    S_AXI_ARADDR <= x"4";
    readIt       <= '1'; --Start AXI Read from Slave
    wait for 1 ns;
    readIt <= '0'; --Clear "Start Read" Flag
    wait until S_AXI_RVALID = '1';
    wait until S_AXI_RVALID = '0';

    -- Add more test cases as needed
    wait; -- will wait forever
  end process tb;

end tb_arch;