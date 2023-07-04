library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_tb is
--  Port ( );
end reg_tb;

architecture Behavioral of reg_tb is
    constant PERIOD : time := 100 ns;
    constant HALF_PERIOD : time := period / 2;
    
    signal clk : std_logic;
    signal enable : std_logic;
    signal clear : std_logic;
    signal load : std_logic;
    signal d : std_logic_vector (7 downto 0);
    signal q : std_logic_vector (7 downto 0);
begin
    UUT : entity work.reg port map (
        clk => clk,
        enable => enable,
        clear => clear,
        load => load,
        d => d,
        q => q);
    
    process
    begin
        clk <= '1';
        wait for HALF_PERIOD;
        clk <= '0';
        wait for HALF_PERIOD;
    end process;
    
    process
    begin
        enable <= '0';
        clear <= '1';
        load <= '0';
        d <= (others => '0');
        wait for PERIOD;
        assert q = "ZZZZZZZZ" report "Tri-state failed";
        
        enable <= '1';
        clear <= '0';
        wait for PERIOD;
        assert q = x"00" report "Clear failed";
        
        d <= x"42";
        load <= '1';
        wait for PERIOD;
        assert q = x"42" report "Data not loaded";
        
        d <= x"aa";
        load <= '0';
        wait for PERIOD;
        assert q = x"42" report "Data loaded with load disabled";
        
        load <= '1';
        wait for PERIOD;
        assert q = x"aa" report "Data not loaded";
        
        clear <= '1';
        load <= '0';
        wait for PERIOD;
        assert q = x"00" report "Clear failed";
        
        enable <= '0';
        clear <= '0';
        load <= '1';
        wait for PERIOD;
        assert q = "ZZZZZZZZ" report "Tri-state failed";
        
        enable <= '1';
        wait for PERIOD;
        assert q = x"aa" report "Data not loaded";
        
        std.env.stop(0);
    end process;

end Behavioral;
