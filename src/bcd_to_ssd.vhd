----------------------------------------------------------------------------------
-- Author:       Lab A01 Group 18
-- 
-- Assignment:   ENEL373 ALU+FSM+Regs project
-- Create Date:  25.02.2019 21:32:18
-- Module Name:  bcd_to_ssd - Behavioural
-- Project Name: CPU-design
-- Description:  Output binary coded decimal on a seven segment display
-- 
-- Dependencies: None
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_to_ssd is
    Port ( bcd : in  STD_LOGIC_VECTOR (3 downto 0);   -- Number to display
           ssd : out STD_LOGIC_VECTOR (6 downto 0));  -- Seven segment display outputs
end bcd_to_ssd;

architecture Behavioral of bcd_to_ssd is
begin
	-- Turn on the desired segments (negative logic)
    with bcd select ssd <=
        "0000001" when "0000",  -- 0
		"1001111" when "0001",  -- 1
		"0010010" when "0010",  -- 2
		"0000110" when "0011",  -- 3
		"1001100" when "0100",  -- 4
		"0100100" when "0101",  -- 5
		"0100000" when "0110",  -- 6
		"0001111" when "0111",  -- 7
		"0000000" when "1000",  -- 8
		"0000100" when "1001",  -- 9
		"1111111" when others;   -- Otherwise blank
end Behavioral;
