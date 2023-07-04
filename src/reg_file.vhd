library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_file is
    generic (
        NUM_REGS : integer := 16);
    port (
        clk : in std_logic;                                 -- Clock signal
        reset : in std_logic;                               -- Asynchronous reset  
        load : in std_logic_vector (NUM_REGS-1 downto 0);   -- Register load
        enable : in std_logic_vector (NUM_REGS-1 downto 0); -- Register enable
        data : inout std_logic_vector (7 downto 0));        -- Register data bus
end reg_file;

architecture Behavioral of reg_file is
begin
    -- Generate 16 registers and connect to control signals
    gen: for i in 0 to NUM_REGS-1 generate
        regx : entity work.reg port map (
            clk     => clk,
            enable  => enable(i),
            clear   => reset,
            load    => load(i),
            d       => data,
            q       => data);
    end generate gen;
end Behavioral;