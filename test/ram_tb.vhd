----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.05.2019 14:36:55
-- Design Name: 
-- Module Name: ram_tb - Behavioral
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

entity ram_tb is
--  Port ( );
end ram_tb;

architecture Behavioral of ram_tb is
    constant ADDR : std_logic_vector(1 downto 0) := "00";
    signal clk, write : std_logic;
    signal address : std_logic_vector (7 downto 0);
    signal data_in, data_out : std_logic_vector (15 downto 0);
begin
    UUT : entity work.ram port map (
        clk         => clk,
        write       => write,
        address     => address,
        data_in     => data_in,
        data_out    => data_out,
        vram_addr   => ADDR,
        vram_data   => open);
    
    process
    begin
        clk <= '1';
        wait for 25 ns;
        clk <= '0';
        wait for 25 ns;
    end process;
    
    -- Test basic read and write functionality
    process
    begin
        write <= '0';
        address <= x"AA";
        data_in <= x"F0F0";
        wait for 200 ns;
        write <= '1';
        wait for 100 ns;
        assert data_out = x"F0F0";
        address <= x"0F";
        data_in <= x"1111";
        wait for 100 ns;
        write <= '0';
        address <= x"AA";
        wait for 100 ns;
        assert data_out <= x"F0F0";
        address <= x"0F";
        wait for 100 ns;
        assert data_out <= x"1111";
        std.env.stop(0);
    end process;
end Behavioral;
