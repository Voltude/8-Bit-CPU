----------------------------------------------------------------------------------
-- Author:       Lab A01 Group 18
-- 
-- Assignment:   ENEL373 ALU+FSM+Regs project
-- Create Date:  25.02.2019 22:13:48
-- Module Name:  bin_to_bcd - Behavioural
-- Project Name: CPU-design
-- Resources:    https://en.wikipedia.org/wiki/Double_dabble#VHDL_implementation
-- Description:  Converts an input binary number into a binary coded decimal using
--               the double dabble algorithm
-- 
-- Dependencies: None
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bin_to_bcd is
    Generic ( bits    : integer := 27;                          -- Number of input bits
              digits  : integer := 8);                          -- Number decimal digits
    Port ( bin : in  std_logic_vector (bits-1 downto 0);        -- Binary input
           bcd : out std_logic_vector (digits*4-1 downto 0));   -- Binary coded decimal output
end bin_to_bcd;

architecture Behavioral of bin_to_bcd is
begin
    process (bin)
        variable bin_reg : std_logic_vector (bits-1 downto 0);
        variable bcd_reg : unsigned (digits*4-1 downto 0);
    begin
        -- Initialise variables
        bin_reg := bin;
        bcd_reg := (others => '0');
        
        -- Perform double dabble algorithm
        for i in 0 to bits-1 loop
            -- Loop through all BCD digits
            for j in 0 to digits-1 loop
                -- Add 3 to a place values (digits) if they are greater than 4
                if bcd_reg(j*4+3 downto j*4) > 4 then
                    bcd_reg(j*4+3 downto j*4) := bcd_reg(j*4+3 downto j*4) + 3;
                end if;
            end loop;
            
            -- Shift registers right
            bcd_reg := bcd_reg(digits*4-2 downto 0) & bin_reg(bits-1);
            bin_reg := bin_reg(bits-2 downto 0) & '0';
        end loop;
        
        -- Assign BCD to output
        bcd <= std_logic_vector(bcd_reg);
    end process;
end Behavioral;
