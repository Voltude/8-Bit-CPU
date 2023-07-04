library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_tb is
--  Port ( );
end controller_tb;

architecture Behavioral of controller_tb is
    constant NUM_BITS : integer := 8;
    constant NUM_REGS : integer := 16;
    constant INSTRUCTION_SIZE : integer := 16;
    constant ADDRESS_SIZE : integer := 8;

    signal clk, reset, ram_wr : std_logic;
    signal databus : std_logic_vector(NUM_BITS-1 downto 0);
    signal a, b : std_logic_vector(NUM_BITS-1 downto 0);
    signal opcode : std_logic_vector(5 downto 0);
    signal result : std_logic_vector(NUM_BITS-1 downto 0);
    signal status : std_logic_vector(3 downto 0);
    signal regs_en, regs_ld : std_logic_vector(NUM_REGS-1 downto 0);
    signal ram_in, ram_out : std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
    signal address : std_logic_vector(ADDRESS_SIZE-1 downto 0);

begin
    UUT : entity work.controller port map (
        clk     => clk,
        reset   => reset,
        databus => databus,
        a       => a,
        b       => b,
        opcode  => opcode,
        result  => result,
        status  => status,
        regs_en => regs_en,
        regs_ld => regs_ld,
        ram_in  => ram_in,
        ram_out => ram_out,
        address => address,
        ram_wr  => ram_wr);
        
    reset <= '0';
    result <= x"42";

    process
    begin
        clk <= '1';
        wait for 25 ns;
        clk <= '0';
        wait for 25 ns;
    end process;

    process
    begin
        ram_in <= "1101000010000001"; -- ADD R1, R8
        wait until rising_edge(clk);
        databus <= x"01";
        wait until rising_edge(clk);
        databus <= x"02";
        wait until rising_edge(clk);
        databus <= (others => 'Z');
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        std.env.stop(0);
    end process;
end Behavioral;
