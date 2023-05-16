-- Generador de Datos IQ
-- Yosel de Jesus Balibrea Lastre
-------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity data_gen is
    generic (
        CLK_FREQ : integer := 100000000
    );
    port (
        clk   : in std_logic;
        rst   : in std_logic;
        en    : in std_logic;

        data_o : out std_logic_vector(63 downto 0);
        clk_fifo : out std_logic;
        
        pulso  : in std_logic;
        samples : in std_logic_vector(31 downto 0);
        freq    : in std_logic_vector(31 downto 0)
    );
end entity;


architecture rtl of data_gen is

    -- Numero Magico
    constant MAG_NUM : std_logic_vector(63 downto 0) := X"CAFEFFFFFFFFFFFF";
    

    -- Periodos de reloj en pulso largo y corto
    constant PULSO_COTRO : integer := 41;   -- 1.2MHz (100/(2* 1.2))
    constant PULSO_LARGO : integer := 82;  -- 600KHz
    signal clk_reg : integer := 0;

    -- Profundidad del Header
    constant HDEPTH : integer := 2;
    
    -- Numero del rayo
    signal ray_cnt : std_logic_vector(63 downto 0) := (others => '0') ;    
    
    -- Azimut y elevacion
    signal azelev_c : std_logic_vector(31 downto 0) := (others => '0');

    -- Contador IQ
    signal iq_cnt  : std_logic_vector(15 downto 0) := (others => '0');  

    -- Numero de muestra
    signal index  : integer := 0; 

    signal clk_count : integer := 0;    -- CLK FIFO

    signal clk_fifo_r: std_logic := '0';

    -- Reg de datos
    signal data_reg : std_logic_vector(63 downto 0) := (others => '0') ;
    
    
    -- FSM
    type fsm_type is (IDLE_S, HEADER_S, IQ_S);
    signal fsm : fsm_type;

begin


    -- CLK FIFO GEN ------------------------------------------------
    process (clk)
    begin
        if rst = '0' then
            clk_fifo_r <= '0';
            clk_reg <= 0; 

        elsif rising_edge(clk) then
            if pulso = '1' then
                clk_reg <= PULSO_COTRO;
            else
                clk_reg <= PULSO_LARGO;
            end if;

            clk_count <= clk_count + 1;
            if clk_count >= clk_reg then
                clk_fifo_r <= not clk_fifo_r;
                clk_count <= 0;
            end if; 

        end if;            
        
    end process;

    clk_fifo <= clk_fifo_r;
    --------------------------------------------------------------------


    -- FSM -------------------------------------------------------------
    process (clk)
    begin

        if rst = '0' then
            azelev_c <= (others => '0');
            iq_cnt <= (others => '0');
            index <= 0;
            ray_cnt <= (others => '0');

        elsif rising_edge(clk) then
            
            case fsm is
                when IDLE_S =>

                    --azelev_c <= (others => '0');
                    iq_cnt <= (others => '0');
                    index <= 0;

                    if en = '1' then
                        fsm <= HEADER_S;
                    end if;

                when HEADER_S =>
                    index <= index + 1;
                    
                    case index is
                        when 0 =>
                            data_reg <= MAG_NUM;

                        when 1 =>
                            data_reg <= ray_cnt;
                            ray_cnt <= std_logic_vector(unsigned(ray_cnt) + 1);

                        when 2 =>
                            data_reg <= azelev_c & azelev_c;
                            azelev_c <= std_logic_vector(unsigned(azelev_c) + 1);

                        when others =>

                    end case;

                    if index >= HDEPTH then
                        index <= 0;
                        fsm <= IQ_S;
                    end if;
                        
                when IQ_S =>
                    index <= index + 1;
                    iq_cnt <= std_logic_vector(unsigned(iq_cnt) + 1);

                    data_reg <= iq_cnt & iq_cnt & iq_cnt & iq_cnt;

                    if index >= to_integer(unsigned(samples)) then
                        fsm <= IDLE_S;
                    end if;                    
                    
            end case;
        end if;
    end process;

    data_o <= data_reg;    

end architecture;