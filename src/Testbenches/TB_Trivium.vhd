library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Trivium is
end TB_Trivium;

architecture Behavioral of TB_Trivium is

    component Trivium is
        Generic (output_bits : INTEGER := 4);
        Port (  clk : in STD_LOGIC;
                rst : in STD_LOGIC;
                en : in STD_LOGIC;
                seed : in STD_LOGIC_VECTOR (287 downto 0);
                stream_out : out STD_LOGIC_VECTOR (output_bits-1 downto 0));
    end component;
    
    signal clk, rst, en : STD_LOGIC;
    signal seed : STD_LOGIC_VECTOR (287 downto 0);
    signal stream_out : STD_LOGIC_VECTOR (3 downto 0);
    signal keystream : STD_LOGIC_VECTOR (127 downto 0);
    
    constant clk_period : time := 10ns;
    
begin

    UUT: Trivium Generic map (4) Port Map (clk, rst, en, seed, stream_out);
    
    clk_proc: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc: process
    begin
    
        rst     <= '1';
        en      <= '0';
        seed    <= x"d099059daa1b3475fe218a1f1148a1934e9b40faf363b5221028b68e40aa611e2de0726b";
        
        wait for 2*clk_period;

        rst     <= '0';
        en      <= '1';
        
        wait for 256*clk_period;
        
        en      <= '0';
        
        wait for clk_period;
        
        if keystream = x"ae97ee71dd2c9a6fabb172345717161b" then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait;
    end process;

    shift_reg: process(clk)
    begin
        if (rising_edge(clk)) then
            if (en = '1') then
                keystream  <= keystream(123 downto 0) & stream_out;
            end if;
        end if;
    end process;
    
end Behavioral;