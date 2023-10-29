library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counterSimulator_v1_0 is
  generic
  (
    -- Users to add parameters here
    C_M00_counter_bits : integer := 16;
    -- User parameters ends
    -- Do not modify the parameters beyond this line
    -- Parameters of Axi Master Bus Interface M00_AXIS
    C_M00_AXIS_TDATA_WIDTH : integer := 32;
    C_M00_AXIS_START_COUNT : integer := 32
  );
  port
  (
    -- Users to add ports here
    m00_max_count : in std_logic_vector (C_M00_counter_bits - 1 downto 0); -- Count to restart the counter
    m00_enable    : in std_logic; -- enable the counter
    -- User ports ends
    -- Do not modify the ports beyond this line
    -- Ports of Axi Master Bus Interface M00_AXIS
    m00_axis_aclk    : in std_logic;
    m00_axis_aresetn : in std_logic;
    m00_axis_tvalid  : out std_logic;
    m00_axis_tdata   : out std_logic_vector(C_M00_AXIS_TDATA_WIDTH - 1 downto 0);
    m00_axis_tstrb   : out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8) - 1 downto 0);
    m00_axis_tlast   : out std_logic;
    m00_axis_tready  : in std_logic
  );
end counterSimulator_v1_0;

architecture arch_imp of counterSimulator_v1_0 is

  -- component declaration
  component counterSimulator_v1_0_M00_AXIS is
    generic
    (
      counter_bits         : integer := 16;
      C_M_AXIS_TDATA_WIDTH : integer := 32;
      C_M_START_COUNT      : integer := 32
    );
    port
    (
      max_count      : in std_logic_vector (counter_bits - 1 downto 0); -- Count to restart the counter
      enable         : in std_logic; -- enable the counter
      M_AXIS_ACLK    : in std_logic;
      M_AXIS_ARESETN : in std_logic;
      M_AXIS_TVALID  : out std_logic;
      M_AXIS_TDATA   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
      M_AXIS_TSTRB   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8) - 1 downto 0);
      M_AXIS_TLAST   : out std_logic;
      M_AXIS_TREADY  : in std_logic
    );
  end component counterSimulator_v1_0_M00_AXIS;

begin

  -- Instantiation of Axi Bus Interface M00_AXIS
  counterSimulator_v1_0_M00_AXIS_inst : counterSimulator_v1_0_M00_AXIS
  generic
  map (
  counter_bits         => C_M00_counter_bits,
  C_M_AXIS_TDATA_WIDTH => C_M00_AXIS_TDATA_WIDTH,
  C_M_START_COUNT      => C_M00_AXIS_START_COUNT
  )
  port map
  (
    max_count      => m00_max_count,
    enable         => m00_enable,
    M_AXIS_ACLK    => m00_axis_aclk,
    M_AXIS_ARESETN => m00_axis_aresetn,
    M_AXIS_TVALID  => m00_axis_tvalid,
    M_AXIS_TDATA   => m00_axis_tdata,
    M_AXIS_TSTRB   => m00_axis_tstrb,
    M_AXIS_TLAST   => m00_axis_tlast,
    M_AXIS_TREADY  => m00_axis_tready
  );

  -- Add user logic here

  -- User logic ends

end arch_imp;