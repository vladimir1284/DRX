library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-------------------------------------------------------------------------------
-- entity declaration
-------------------------------------------------------------------------------
entity data_gen is
generic(
    AT : integer := 2000;
    DT : integer := 1000;
    CLK_FREQ : integer := 100000;
    W : integer := 32
);

port(
    clk : in std_logic;
    rst : in std_logic;
    en  : in std_logic;
    data_o : out std_logic_vector(W-1 downto 0)
);
end entity data_gen;


architecture rtl of data_gen is
    type fsm_type is (SEND_S, WAIT_S, IDLE_S);

    signal state : fsm_type;

    signal counter : integer;
    signal wcnt : integer;
begin

process(clk)
begin

    if rising_edge(clk) then
        if rst = '0' then
            state <= IDLE_S;
        else
            case state is
                when IDLE_S =>
                    
                    counter <= AT * CLK_FREQ/1000;
                    wcnt <= DT * CLK_FREQ/1000;

                    if en = '1' then
                        state <= SEND_S;
                    end if;

                when SEND_S =>                    

                    if counter = 0 then
                        state <= WAIT_S;
                    end if;
                    -- Send data
                    counter <= counter - 1;

                when WAIT_S =>
                    
                    if wcnt = 0 then
                        state <= IDLE_S;
                    end if;

                    wcnt <= wcnt - 1;

            end case;

        end if;

    end if;

end process;

    --data_o <= std_logic_vector(to_unsigned(counter, W));

end rtl;
