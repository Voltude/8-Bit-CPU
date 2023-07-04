library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_file_tb is
--  Port ( );
end reg_file_tb;

architecture Behavioral of reg_file_tb is
    signal clk, reset : std_logic;
    signal load, enable : std_logic_vector (15 downto 0);
    signal data : std_logic_vector (7 downto 0);
begin
    UUT : entity work.reg_file port map (
        clk     => clk,
        reset   => reset,
        load    => load,
        enable  => enable,
        data    => data);
    
    process
    begin
        clk <= '1';
        wait for 25 ns;
        clk <= '0';
        wait for 25 ns;
    end process;

    process
    begin
        reset <= '0';
        load <= (others => '0');
        enable <= (others => '0');
        data <= (others => '0');
        
        wait until rising_edge(clk);
        load <= x"0001";
        enable <= x"0000";
        data <= x"42";

        wait until rising_edge(clk);
        load <= x"0002";
        data <= x"AA";

        wait until rising_edge(clk);
        load <= x"0000";
        enable <= x"0001";
        data <= (others => 'Z');

        wait until rising_edge(clk);
        assert data = x"42";
        enable <= x"0002";
        
        wait until rising_edge(clk);
        assert data = x"AA";
        reset <= '1';
        enable <= (others => '0');
                
        wait until rising_edge(clk);
        assert data = "ZZZZZZZZ";
        enable <= x"0001";
                
        wait until rising_edge(clk);
        assert data = x"00";
        
        std.env.stop(0);
    end process;
end Behavioral;
