library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpu is
    generic (
        NUM_BITS : integer := 8;
        NUM_REGS : integer := 16;
        RAM_SIZE : integer := 16;
        ADDRESS_SIZE : integer := 8);
    port (
        clk : in std_logic;                                             -- Main clock
        reset : in std_logic;                                           -- Asychronous reset
        databus : inout std_logic_vector(NUM_BITS-1 downto 0);          -- Main databus
        regs_en, regs_ld : inout std_logic_vector(NUM_REGS-1 downto 0); -- Registers
        ram_wr : out std_logic;                                         -- RAM write
        ram_in : in std_logic_vector(RAM_SIZE-1 downto 0);              -- RAM input bus
        ram_out : out std_logic_vector(RAM_SIZE-1 downto 0);            -- RAM output bus
        address : out std_logic_vector (ADDRESS_SIZE-1 downto 0);       -- RAM address bus
        led : out std_logic_vector(15 downto 0));                       -- Display current instruction 
end cpu;

architecture Structural of cpu is
    -- Constants
    constant DISABLE : std_logic := '0';

    -- Status Register
    signal status : std_logic_vector(3 downto 0);

    -- ALU Signals
    signal opcode   : std_logic_vector(5 downto 0);
    signal a, b     : std_logic_vector(NUM_BITS-1 downto 0);
    signal alu_out  : std_logic_vector(NUM_BITS-1 downto 0);
begin
    -- Arithmetic & Logic Unit
    ALU : entity work.alu port map (
        x       => a,
        y       => b,
        opcode  => opcode,
        output  => alu_out,
        status  => status);
    
    -- Register File
    REGS : entity work.reg_file port map (
        clk     => clk,
        reset   => reset,
        load    => regs_ld,
        enable  => regs_en,
        data    => databus);
    
    -- CPU Control Unit
    CONTROL : entity work.controller port map (
        led     => led,
        clk     => clk,
        reset   => reset,
        databus => databus,
        a       => a,
        b       => b,
        opcode  => opcode,
        result  => alu_out,
        status  => status,
        regs_en => regs_en,
        regs_ld => regs_ld,
        ram_in  => ram_in,
        ram_out => ram_out,
        address => address,
        ram_wr  => ram_wr);
end Structural;