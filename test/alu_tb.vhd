library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_tb is
--  Port ( );
end alu_tb;

architecture Behavioral of alu_tb is
    signal opcode   : std_logic_vector(5 downto 0);
    signal x, y     : std_logic_vector(7 downto 0);
    signal output   : std_logic_vector(7 downto 0);
    signal status   : std_logic_vector(3 downto 0);
    signal zero     : std_logic;
    signal neg      : std_logic;
    signal cout     : std_logic;
    signal over     : std_logic;
begin
    UUT : entity work.alu port map (
        opcode  => opcode,
        x       => x,
        y       => y,
        output  => output,
        status  => status);
    
    zero <= status(0);
    neg  <= status(1);
    cout <= status(2);
    over <= status(3);
    
    process
    begin
        -- x & y
        opcode <= "000000";
        x <= x"1d"; -- 29
        y <= x"0d"; -- 13
        wait for 100 ns;
        assert output = x"0d" report "x & y failed" severity error;
        
        -- x | y
        opcode <= "101010";
        x <= x"1d"; -- 29
        y <= x"0d"; -- 13
        wait for 100 ns;
        assert output = x"1d" report "x | y failed" severity error;
        
        -- x + y
        opcode <= "010000";
        x <= x"1d"; -- 29
        y <= x"0d"; -- 13
        wait for 100 ns;
        assert output = x"2a" report "x + y failed" severity error;
        
        -- x - y
        opcode <= "110010";
        x <= x"1d"; -- 29
        y <= x"0d"; -- 13
        wait for 100 ns;
        assert output = x"10" report "x - y failed" severity error;
        
        -- y - x
        opcode <= "111000";
        x <= x"1d"; -- 29
        y <= x"0d"; -- 13
        wait for 100 ns;
        assert output = x"F0" report "y - x failed" severity error;
        assert cout = '1' report "cout flag not set" severity error;
        assert over = '0' report "over flag incorrectly set" severity error;
        assert zero = '0' report "zero flag incorrectly set" severity error;
        assert neg  = '1' report "neg flag not set" severity error;
        
        -- 0 + 0
        opcode <= "010101";
        x <= x"1d"; -- 29
        y <= x"0d"; -- 13
        wait for 100 ns;
        assert output = x"00" report "ZERO failed" severity error;
        assert cout = '0' report "cout flag incorrectly set" severity error;
        assert over = '0' report "over flag incorrectly set" severity error;
        assert zero = '1' report "zero flag not set" severity error;
        assert neg  = '0' report "neg flag incorrectly set" severity error;
        
        -- Test overflow
        opcode <= "010000";
        x <= x"80"; -- 128
        y <= x"80"; -- 128
        wait for 100 ns;
        assert output = x"00" report "Signed verflow test failed" severity error;
        assert cout = '1' report "cout flag not set" severity error;
        assert over = '1' report "over flag not set" severity error;
        assert zero = '1' report "zero flag not set" severity error;
        assert neg  = '0' report "neg flag incorrectly set" severity error;
        
        std.env.stop(0);
    end process;
end Behavioral;