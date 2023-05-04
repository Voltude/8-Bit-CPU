----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.05.2019 23:55:35
-- Design Name: 
-- Module Name: cpu_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu_tb is
--  Port ( );
end cpu_tb;

architecture Behavioral of cpu_tb is
    constant CLK_CYCLES : integer := 20;
    signal clk, reset, ram_wr : std_logic;
    signal databus : std_logic_vector(7 downto 0);
    signal regs_en, regs_ld : std_logic_vector(15 downto 0);
    signal ram_in : std_logic_vector(15 downto 0);
    signal ram_out : std_logic_vector(15 downto 0);
    signal address : std_logic_vector (7 downto 0);
begin
    UUT : entity work.cpu port map (
        clk     => clk,
        reset   => reset,
        databus => databus,
        regs_en => regs_en,
        regs_ld => regs_ld,
        ram_wr  => ram_wr,
        ram_in  => ram_in,
        ram_out => ram_out,
        address => address);
    
    reset <= '0';

    with to_integer(unsigned(address)) select ram_in <=
        "1001000001000000" when 0, -- LDI R0, 0x40
        "1001000100000010" when 1, -- LDI R1, 0x02
        "1101000000010000" when 2, -- ADD R0, R1
        "1101000000010000" when 3, -- ADD R0, R1
        "1000000100000000" when 4, -- MOV R1, R0
        "1101000000010000" when 5, -- ADD R0, R1
        "1011000111111111" when 6, -- STR R1, 0xFF
        "1011000011111111" when 7, -- STR R0, 0xFF
        "1010000011111111" when 8, -- LDR R0, 0xFF
        "0000000000000000" when others;

    process
    begin
        clk <= '1';
        wait for 25 ns;
        clk <= '0';
        wait for 25 ns;
    end process;
    
    process
    begin
        wait for 2000 ns;
        std.env.stop(0);
    end process;

end Behavioral;
