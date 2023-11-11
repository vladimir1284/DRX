library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity loopcounter_v1_0_m00_axis_tb is
end loopcounter_v1_0_m00_axis_tb;

architecture arch_imp of loopcounter_v1_0_m00_axis_tb is

  -- component declaration
  component LoopCounter_v1_0_M00_AXIS is
    generic
    (
      CELLS_DATA_WIDTH     : integer := 16; --! The maximum number of cells in a transaction is 2^CELLS_DATA_WIDTH
      C_M_AXIS_TDATA_WIDTH : integer := 32;
      C_M_START_COUNT      : integer := 4
    );
    port
    (
      ENABLE         : in std_logic; --! Ascynchronous reset signal from the counter configurator
      CELLS_IN_PRT   : in std_logic_vector(CELLS_DATA_WIDTH - 1 downto 0);--! Number of cells in a Pulse Repetition Time (PRT)
      CELLS_TO_SEND  : in std_logic_vector(CELLS_DATA_WIDTH - 1 downto 0);--! Number of cells to be adquired
      VALID_CONFIG   : out std_logic; --! Validates that CELLS_IN_PRT >= CELLS_TO_SEND
      M_AXIS_ACLK    : in std_logic;
      M_AXIS_ARESETN : in std_logic;
      M_AXIS_TVALID  : out std_logic;
      M_AXIS_TDATA   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
      M_AXIS_TSTRB   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8) - 1 downto 0);
      M_AXIS_TLAST   : out std_logic;
      M_AXIS_TREADY  : in std_logic
    );
  end component LoopCounter_v1_0_M00_AXIS;

  -- Component signals
  signal ENABLE_tb         : std_logic := '0'; --! Ascynchronous reset signal from the counter configurator
  signal CELLS_IN_PRT_tb   : std_logic_vector(15 downto 0);--! Number of cells a Pulse Repetition Time (PRT)
  signal CELLS_TO_SEND_tb  : std_logic_vector(15 downto 0);--! Number of cells to be adquired
  signal VALID_CONFIG_tb   : std_logic;
  signal M_AXIS_ACLK_tb    : std_logic := '0';
  signal M_AXIS_ARESETN_tb : std_logic := '0';
  signal M_AXIS_TVALID_tb  : std_logic;
  signal M_AXIS_TDATA_tb   : std_logic_vector(31 downto 0);
  signal M_AXIS_TSTRB_tb   : std_logic_vector(3 downto 0);
  signal M_AXIS_TLAST_tb   : std_logic;
  signal M_AXIS_TREADY_tb  : std_logic := '1';
begin

  -- Instantiation of Axi Bus Interface M00_AXIS
  dut : LoopCounter_v1_0_M00_AXIS
  generic
  map (
  CELLS_DATA_WIDTH     => 16,
  C_M_AXIS_TDATA_WIDTH => 32,
  C_M_START_COUNT      => 4
  )
  port map
  (
    ENABLE         => ENABLE_tb,
    CELLS_IN_PRT   => CELLS_IN_PRT_tb,
    CELLS_TO_SEND  => CELLS_TO_SEND_tb,
    VALID_CONFIG   => VALID_CONFIG_tb,
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
    CELLS_IN_PRT_tb  <= x"0010";
    CELLS_TO_SEND_tb <= x"000A";

    -- Apply stimulus
    wait for 10 ns;
    M_AXIS_ARESETN_tb <= '1';
    enable_tb         <= '1';
    wait for 200 ns;
    M_AXIS_TREADY_tb <= '0';
    wait;

  end process;

end arch_imp;