library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity programmer is
    Port ( clk : in std_logic;                              -- Clock signal (100MHz)
           reset : in std_logic;                            -- Asynchronous reset
           programming : out std_logic;                     -- Programming flag
           ram_write : out std_logic;                       -- RAM write enable
           ram_address : out std_logic_vector(7 downto 0);  -- RAM address
           ram_in : out std_logic_vector (15 downto 0);     -- Input data to RAM
           ram_out : in std_logic_vector (15 downto 0);     -- Output data from RAM
           uart_txd_in : in std_logic;                      -- UART input pin
           uart_rxd_out : out std_logic);                   -- UART output pin
end programmer;

architecture Structural of programmer is
    signal rx_busy, tx_ena, tx_busy : std_logic;
    signal uart_in, uart_out : std_logic_vector (7 downto 0);
begin
    -- UART module
    -- Transmits and receives bytes over UART
    UART : entity work.uart port map (
        clk			=> clk,
        reset		=> reset,
        tx_ena		=> tx_ena,
        tx_data		=> uart_out,
        rx			=> uart_txd_in,
        rx_busy		=> rx_busy,
        rx_error	=> open,
        rx_data		=> uart_in,
        tx_busy		=> tx_busy,
        tx			=> uart_rxd_out);
    
    -- UART Controller module
    -- Reads and writes data to RAM
    UART_CONTROLLER : entity work.uart_controller port map (
        clk         => clk,
        reset       => reset,
        programming => programming,
        rx_busy     => rx_busy,
        tx_busy     => tx_busy,
        tx_ena      => tx_ena,
        uart_in     => uart_in,
        uart_out    => uart_out,
        ram_address => ram_address,
        ram_write   => ram_write,
        ram_out     => ram_out,
        ram_in      => ram_in);
end Structural;
