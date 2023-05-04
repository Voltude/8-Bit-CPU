----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.03.2019 14:18:00
-- Design Name: 
-- Module Name: debounce_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debounce_tb is
--  Port ( );
end debounce_tb;

architecture Behavioral of debounce_tb is
    signal clk, input, output : std_logic;

begin
    UUT : entity work.debounce
        generic map (
            count_max => 2)
        port map (
            clk => clk,
            input => input,
            output => output);
    
    process
    begin
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
    end process;

    process
    begin
        input <= '0';
        wait for 20 ns;
                
        input <= '1';
        wait for 100 ns;
        
        input <= '0';
        wait for 10 ns;
        wait until clk = '1';
        assert output = '1';
        wait until clk = '1';
        assert output = '1';
        wait until clk = '1';
        assert output = '1';
        wait until clk = '1';
        assert output = '1';
        wait until clk = '1';
        assert output = '0';
        
        wait for 100 ns;
                        
        input <= '1';
        wait until clk = '1';
        assert output = '0';
        input <= '0';
        wait until clk = '1';
        assert output = '0';
        input <= '1';
        wait until clk = '1';
        assert output = '0';
        input <= '0';
        wait until clk = '1';
        assert output = '0';
        input <= '1';
        wait until clk = '1';
        assert output = '0';
        input <= '0';
        wait until clk = '1';
        assert output = '0';
        input <= '1';
        wait until clk = '1';
        assert output = '0';
        
        wait for 100 ns;
        
        input <= '0';
        wait for 100 ns;
        
        std.env.stop(0);
    end process;
end Behavioral;
