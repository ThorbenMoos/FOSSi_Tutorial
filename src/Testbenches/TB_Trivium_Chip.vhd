library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Trivium_Chip is
end TB_Trivium_Chip;

architecture Behavioral of TB_Trivium_Chip is

    component Trivium_Chip is
        Generic (bits_per_cycle : INTEGER := 4);
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               seed_reg_en : in STD_LOGIC;
               triv_rst : in STD_LOGIC;
               triv_en : in STD_LOGIC;
               data_in : in STD_LOGIC_VECTOR (3 downto 0);
               data_out : out STD_LOGIC_VECTOR (bits_per_cycle-1 downto 0));
    end component;
    
    type states is (S_RESET, S_SEED, S_INIT, S_STREAM, S_CHECK, S_FINAL);
    signal state : states := S_RESET;
    
    signal clk, rst, seed_reg_en, triv_rst, triv_en : STD_LOGIC;
    signal data_in, data_out : STD_LOGIC_VECTOR (3 downto 0);
    signal keystream : STD_LOGIC_VECTOR (127 downto 0);
    
    constant seed : STD_LOGIC_VECTOR (287 downto 0) := x"d099059daa1b3475fe218a1f1148a1934e9b40faf363b5221028b68e40aa611e2de0726b";
    
    signal notclk : STD_LOGIC;
    constant clk_period : time := 10ns;
    
begin

    notclk <= NOT clk;
    UUT: Trivium_Chip Generic map (4) Port Map (notclk, rst, seed_reg_en, triv_rst, triv_en, data_in, data_out);
    
    clk_proc: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc: process(clk)
        variable counter : integer range 0 to 256;
    begin
        if rising_edge(clk) then
            case state is

                when S_RESET =>         rst                         <= '1';
                                        seed_reg_en                 <= '0';
                                        triv_rst                    <= '0';
                                        triv_en                     <= '0';
                                        data_in                     <= (others => '0');
                                        keystream                   <= (others => '0');
                                        counter                     := 0;
                                        state                       <= S_SEED;

                when S_SEED =>          rst                         <= '0';
                                        seed_reg_en                 <= '1';
                                        data_in                     <= seed(287-counter*4 downto 284-counter*4);
                                        counter                     := counter + 1;
                                        if (counter = 72) then
                                            counter                 := 0;
                                            state                   <= S_INIT;
                                        end if;

                when S_INIT =>          seed_reg_en                 <= '0';
                                        triv_rst                    <= '1';
                                        data_in                     <= (others => '0');
                                        state                       <= S_STREAM;

                when S_STREAM =>        triv_rst                    <= '0';
                                        triv_en                     <= '1';
                                        keystream                   <= keystream(123 downto 0) & data_out;
                                        counter                     := counter + 1;
                                        if (counter = 256) then
                                            counter                 := 0;
                                            state                   <= S_CHECK;
                                        end if;
                                        
                when S_CHECK =>         triv_en                     <= '0';
                                        if (keystream = x"ae97ee71dd2c9a6fabb172345717161b") then
                                            report "SUCCESS";
                                        else
                                            report "FAILURE";
                                        end if;
                                        state                       <= S_FINAL;

                when S_FINAL =>         rst                         <= '1';

            end case;
        end if;
    end process;

end Behavioral;