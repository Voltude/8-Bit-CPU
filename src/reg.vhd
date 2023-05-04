----------------------------------------------------------------------------------
-- Author:       Lab A01 Group 18
-- 
-- Assignment:   ENEL373 ALU+FSM+Regs project
-- Create Date:  23.03.2019 01:13:19
-- Module Name:  reg - Behavioural
-- Project Name: CPU-design
-- Description:  Writes data to a register
-- 
-- Dependencies: None
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
    Generic (
        N : integer := 8);
    Port (
        clk : in std_logic;                         -- Clock signal  
        enable : in std_logic;                      -- Register enable
        clear : in std_logic;                       -- Register clear
        load : in std_logic;                        -- Register load
        d : in std_logic_vector (N-1 downto 0);     -- Data in
        q : out std_logic_vector (N-1 downto 0));   -- Data out
end reg;

architecture Behavioral of reg is
begin
    process (clk, enable, clear, load)
        variable buf : std_logic_vector (N-1 downto 0);
    begin
        if clear = '1' then
            buf := (others => '0'); -- Clear buffer
        elsif rising_edge(clk) and load = '1' then
            buf := d; -- Load data into buffer (on clock-edge)
        end if;
        
        if enable = '1' then -- Enable buffer output
            q <= buf;
        else -- Otherwise high impedance
            q <= (others => 'Z');
        end if;
    end process;
end Behavioral;
