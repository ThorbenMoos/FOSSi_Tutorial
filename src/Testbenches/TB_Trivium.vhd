library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Trivium is
end TB_Trivium;

architecture Behavioral of TB_Trivium is

    component Trivium is
        Generic (output_bits : INTEGER := 64);
        Port (  clk : in STD_LOGIC;
                rst : in STD_LOGIC;
                en : in STD_LOGIC;
                seed : in STD_LOGIC_VECTOR (287 downto 0);
                stream_out : out STD_LOGIC_VECTOR (output_bits-1 downto 0));
    end component;
    
    signal clk, rst, en : STD_LOGIC;
    signal seed : STD_LOGIC_VECTOR (287 downto 0);
    signal stream_out : STD_LOGIC_VECTOR (63 downto 0);
    
    constant clk_period : time := 10ns;
    
begin

    UUT: Trivium Generic map (64) Port Map (clk, rst, en, seed, stream_out);
    
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
        
        wait for 200*clk_period;
        
        en      <= '0';
        
        wait for clk_period;
        
        if stream_out = x"f0b8a660df1538f7" then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait;
    end process;

end Behavioral;