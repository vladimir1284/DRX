library ieee;
use ieee.std_logic_1164.all;

entity counterSimulator_v1_0_M00_AXIS_tb is
end counterSimulator_v1_0_M00_AXIS_tb;

architecture tb_arch of counterSimulator_v1_0_M00_AXIS_tb is
  -- Component declaration
  component counterSimulator_v1_0_M00_AXIS is
    generic
    (
      counter_bits         : integer := 16;
      C_M_AXIS_TDATA_WIDTH : integer := 32;
      C_M_START_COUNT      : integer := 32
    );
    port
    (
      max_count      : in std_logic_vector (counter_bits - 1 downto 0);
      enable         : in std_logic;
      M_AXIS_ACLK    : in std_logic;
      M_AXIS_ARESETN : in std_logic;
      M_AXIS_TVALID  : out std_logic;
      M_AXIS_TDATA   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
      M_AXIS_TSTRB   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8) - 1 downto 0);
      M_AXIS_TLAST   : out std_logic;
      M_AXIS_TREADY  : in std_logic
    );
  end component;

  -- Component signals
  signal max_count_tb      : std_logic_vector(15 downto 0);
  signal enable_tb         : std_logic := '0';
  signal M_AXIS_ACLK_tb    : std_logic := '0';
  signal M_AXIS_ARESETN_tb : std_logic := '1';
  signal M_AXIS_TVALID_tb  : std_logic;
  signal M_AXIS_TDATA_tb   : std_logic_vector(31 downto 0);
  signal M_AXIS_TSTRB_tb   : std_logic_vector(3 downto 0);
  signal M_AXIS_TLAST_tb   : std_logic;
  signal M_AXIS_TREADY_tb  : std_logic := '1';

begin

  dut : counterSimulator_v1_0_M00_AXIS
  generic
  map (
  counter_bits         => 16,
  C_M_AXIS_TDATA_WIDTH => 32,
  C_M_START_COUNT      => 8 -- Wait only 5 instead of 32 
  )
  port map
  (
    max_count      => max_count_tb,
    enable         => enable_tb,
    M_AXIS_ACLK    => M_AXIS_ACLK_tb,
    M_AXIS_ARESETN => M_AXIS_ARESETN_tb,
    M_AXIS_TVALID  => M_AXIS_TVALID_tb,
    M_AXIS_TDATA   => M_AXIS_TDATA_tb,
    M_AXIS_TSTRB   => M_AXIS_TSTRB_tb,
    M_AXIS_TLAST   => M_AXIS_TLAST_tb,
    M_AXIS_TREADY  => M_AXIS_TREADY_tb
  );
  -- Clock process
  process
  begin
    while now < 1000 ns loop
      M_AXIS_ACLK_tb <= '0';
      wait for 5 ns;
      M_AXIS_ACLK_tb <= '1';
      wait for 5 ns;
    end loop;
    wait;
  end process;

  -- Stimulus process
  process
  begin
    -- Initialize inputs
    max_count_tb <= x"0010";
    enable_tb    <= '0';

    -- Apply stimulus
    wait for 10 ns;
    enable_tb <= '1';
    wait for 200 ns;
    enable_tb <= '0';
    wait for 50 ns;
    enable_tb <= '1';
    wait until falling_edge(M_AXIS_TLAST_tb);
    -- Change cell length
    enable_tb    <= '0';
    max_count_tb <= x"0020";
    wait for 20 ns;
    enable_tb <= '1';
    wait;

  end process;

end tb_arch;