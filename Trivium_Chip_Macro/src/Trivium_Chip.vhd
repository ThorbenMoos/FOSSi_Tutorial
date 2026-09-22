library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Trivium_Chip is
    Generic (bits_per_cycle : INTEGER := 4);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           seed_reg_en : in STD_LOGIC;
           triv_rst : in STD_LOGIC;
           triv_en : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (3 downto 0);
           data_out : out STD_LOGIC_VECTOR (bits_per_cycle-1 downto 0));
end Trivium_Chip;

architecture Behavioral of Trivium_Chip is
    
    component FF_serpar_srst is
        Generic ( ser_bits : INTEGER := 4;
                  par_bits : INTEGER := 124);
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               en : in STD_LOGIC;
               sel : in STD_LOGIC;
               ser_inpt : in STD_LOGIC_VECTOR ((ser_bits-1) downto 0);
               par_inpt : in STD_LOGIC_VECTOR ((par_bits-1) downto 0);
               ser_outpt : out STD_LOGIC_VECTOR ((ser_bits-1) downto 0);
               par_outpt : out STD_LOGIC_VECTOR ((par_bits-1) downto 0));
    end component;

    component Trivium is
        Generic (output_bits : INTEGER := 64);
        Port (  clk : in STD_LOGIC;
                rst : in STD_LOGIC;
                en : in STD_LOGIC;
                seed : in STD_LOGIC_VECTOR (287 downto 0);
                stream_out : out STD_LOGIC_VECTOR (output_bits-1 downto 0));
    end component;

    signal seed : STD_LOGIC_VECTOR (287 downto 0);
    
begin

    -- Seed register
    seed_reg: FF_serpar_srst Generic Map (4, 288) Port Map (clk, rst, seed_reg_en, '0', data_in, (others => '0'), open, seed);

    -- Trivium Instance
    TRIV: Trivium Generic Map (bits_per_cycle) Port Map (clk, triv_rst, triv_en, seed, data_out);
    
end Behavioral;