library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-------------------------------------------------------------------------------
-- entity declaration
-------------------------------------------------------------------------------
entity data_gen_tb is

end entity data_gen_tb;


architecture rtl of data_gen_tb is

    constant CLK_PERIOD_NS : time := 20 ns;

    signal clk          : std_logic := '1';
    signal rst          : std_logic;
    signal en : std_logic;
    signal data_o : std_logic_vector(7 downto 0);
    
begin

    -- clock generation
    Clk <= not Clk after CLK_PERIOD_NS/2;

    dg: entity work.data_gen
    generic map(
        AT => 20,
        DT => 10,
        CLK_FREQ => 50000,
        W => 8
    )
    port map(
        clk => clk,
        rst => rst,
        en => en,
        data_o => data_o
    );

    wave_gen: process
    begin
        rst <= '0';
        en <= '1';

        wait for (4 * CLK_PERIOD_NS);

        rst <= '1';
        en <= '0';

        wait for (4 * CLK_PERIOD_NS);

        en <= '1';
        rst <= '1';

        wait;

    end process;


end rtl;
