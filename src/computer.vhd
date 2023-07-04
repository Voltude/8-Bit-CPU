library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity computer is
    port (
        CLK100MHZ : in std_logic;                    -- Main clock
        CPU_RESETN : in std_logic;                   -- Reset (active low)
        UART_TXD_IN : in std_logic;                  -- UART input
        UART_RXD_OUT : out std_logic;                -- UART output
        BTNC, BTNU, BTNL, BTNR, BTND : in std_logic; -- Button inputs
        SW : in std_logic_vector(15 downto 0);       -- Switch inputs
        LED : out std_logic_vector(15 downto 0);     -- LED outputs
        C : out std_logic_vector(0 to 6);            -- 7-segment cathodes
        AN : out std_logic_vector(7 downto 0);       -- 7-segment anodes
        DP : out std_logic);                         -- 7-segment decimal point
end computer;

architecture structural of computer is
    -- Constants
    constant ADDRESS_SIZE : integer := 8;
    constant REG_SIZE : integer := 8;
    constant RAM_SIZE : integer := 16;
    constant DP_OFF : std_logic := '1'; -- Active low

    -- Internal clock
    signal cpu_clk : std_logic;

    -- Resets
    signal reset, cpu_reset : std_logic;

    -- Active when programming - used to reset CPU
    signal programming : std_logic;

    -- RAM write signals
    signal ram_write, cpu_write, prog_write : std_logic;

    -- Addresses
    signal ram_address : std_logic_vector(ADDRESS_SIZE-1 downto 0);
    signal cpu_address : std_logic_vector(ADDRESS_SIZE-1 downto 0);
    signal prog_address : std_logic_vector(ADDRESS_SIZE-1 downto 0);
    signal disp_address : std_logic_vector(1 downto 0);

    -- RAM and data inputs and outputs
    signal ram_in, ram_out: std_logic_vector (RAM_SIZE-1 downto 0);
    signal cpu_ram_in, cpu_ram_out: std_logic_vector (RAM_SIZE-1 downto 0);
    signal disp_data, prog_ram_out : std_logic_vector (RAM_SIZE-1 downto 0);

    -- Memory mapped switch addresses
    constant SW_LOW_ADDRESS : std_logic_vector(ADDRESS_SIZE-1 downto 0) := x"FA";
    constant SW_HIGH_ADDRESS : std_logic_vector(ADDRESS_SIZE-1 downto 0) := x"FB";

    -- Low and high switch inputs
    alias sw_low : std_logic_vector(REG_SIZE-1 downto 0) is SW(7 downto 0);
    alias sw_high : std_logic_vector(REG_SIZE-1 downto 0) is SW(15 downto 8);

    -- LED outputs
    signal cpu_leds, disp_leds : std_logic_vector(15 downto 0);

begin
    -- CPU clock speed controller
    CLK_CTRL : entity work.clk_controller port map (
        clk_in          => CLK100MHZ,
        reset           => reset,
        clk_out         => cpu_clk,
        c_butt_in       => BTNC,
        u_butt_in       => BTNU,
        d_butt_in       => BTND,
        l_butt_in       => BTNL);
    
    -- Main processor
    CPU : entity work.cpu port map (
        led             => cpu_leds,
        clk             => cpu_clk,
        reset           => cpu_reset,
        databus         => open,
        regs_en         => open,
        regs_ld         => open,
        ram_wr          => cpu_write,
        ram_in          => cpu_ram_in,
        ram_out         => cpu_ram_out,
        address         => cpu_address);
    
    -- Display data on the 7-segment display and LEDs
    DISP : entity work.display port map (
        clk             => CLK100MHZ,
        reset           => cpu_reset,
        data            => disp_data,
        address         => disp_address,
        leds            => disp_leds,
        cathode         => C,
        anode           => AN);
    
    -- Program/initialise RAM over UART
    PROGRAMMER : entity work.programmer port map (
        clk             => CLK100MHZ,
        reset           => reset,
        programming     => programming,
        ram_write       => prog_write,
        ram_address     => prog_address,
        ram_in          => prog_ram_out,
        ram_out         => ram_out,
        uart_txd_in     => UART_TXD_IN,
        uart_rxd_out    => UART_RXD_OUT);
    
    -- Main memory
    RAM : entity work.ram port map (
        clk             => CLK100MHZ,
        write           => ram_write,
        address         => ram_address,
        data_in         => ram_in,
        data_out        => ram_out,
        vram_addr       => disp_address,
        vram_data       => disp_data);
    
    -- Resets
    reset <= not CPU_RESETN; -- Invert active low signal
    cpu_reset <= reset or programming; -- Allows programmer to reset CPU

    -- Turn off decimal points on the 7-segment display
    DP <= DP_OFF;

    -- Display the current instruction on the LEDs when the right button is held
    LED <= cpu_leds when BTNR = '1' else disp_leds;

    -- Memory map the switch inputs
    cpu_ram_in <= x"00" & sw_low when cpu_address = SW_LOW_ADDRESS else
                  x"00" & sw_high when cpu_address = SW_HIGH_ADDRESS else 
                  ram_out;
    
    -- MUX programmer and CPU RAM inputs when programming
    ram_write   <= prog_write   when programming = '1' else cpu_write;
    ram_address <= prog_address when programming = '1' else cpu_address;
    ram_in      <= prog_ram_out when programming = '1' else cpu_ram_out;
end structural;