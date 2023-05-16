library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_gen_tb is
end;

architecture bench of data_gen_tb is

  component data_gen
    generic (
      CLK_FREQ : integer
    );
      port (
      clk : in std_logic;
      rst : in std_logic;
      en : in std_logic;
      data_o : out std_logic_vector(63 downto 0);
      clk_fifo : out std_logic;
      pulso : in std_logic;
      samples : in std_logic_vector(31 downto 0);
      freq : in std_logic_vector(31 downto 0)
    );
  end component;

  -- Clock period
  constant clk_period : time := 10 ns;
  -- Generics
  constant CLK_FREQ : integer := 100000000;

  -- Ports
  signal clk : std_logic;
  signal rst : std_logic;
  signal en : std_logic;
  signal data_o : std_logic_vector(63 downto 0);
  signal clk_fifo : std_logic;
  signal pulso : std_logic;
  signal samples : std_logic_vector(31 downto 0);
  signal freq : std_logic_vector(31 downto 0);

begin

  pulso <= '0';
  rst <= '1';
  en <= '1';

  samples <= X"00000064";

  data_gen_inst : data_gen
    generic map (
      CLK_FREQ => CLK_FREQ
    )
    port map (
      clk => clk,
      rst => rst,
      en => en,
      data_o => data_o,
      clk_fifo => clk_fifo,
      pulso => pulso,
      samples => samples,
      freq => freq
    );

   clk_process : process
   begin
   clk <= '1';
   wait for clk_period/2;
   clk <= '0';
   wait for clk_period/2;
   end process clk_process;

end;
