----------------------------------------------------------------------------------
-- Author:       Lab A01 Group 18
-- 
-- Assignment:   ENEL373 ALU+FSM+Regs project
-- Create Date:  21.04.2019 12:46:14
-- Module Name:  uart_controller - Behavioural
-- Project Name: CPU-design
-- Description:  Controls uart 
-- 
-- Dependencies: None 
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_controller is
    Port ( clk : in std_logic;                              -- Main clock
           reset : in std_logic;                            -- Asynchronous reset
           programming : out std_logic;                     -- Pulled high while programming
           rx_busy : in std_logic;                          -- UART currently receiving (active low)
           tx_busy : in std_logic;                          -- UART currently transmitting (active low)
           tx_ena : inout std_logic;                        -- UART start transmission
           uart_in : in std_logic_vector (7 downto 0);      -- UART input byte
           uart_out : out std_logic_vector (7 downto 0);    -- UART output byte
           ram_address : out std_logic_vector(7 downto 0);  -- RAM address bus
           ram_write : out std_logic;                       -- RAM write enable
           ram_out : in std_logic_vector (15 downto 0);     -- RAM output bus
           ram_in : out std_logic_vector (15 downto 0));    -- RAM input bus
end uart_controller;

architecture Behavioral of uart_controller is
    -- Constants
    constant NUM_ADDRESSES : integer := 256;
    constant START_BYTE : std_logic_vector(7 downto 0) := x"42";
    
    -- Programming states
    type state_t is (IDLE, PROGRAM, VERIFY);
    signal state : state_t := IDLE;
    
    -- RAM states
    type ram_states_t is (IDLE, LOWER, UPPER, WRITE);
    signal ram_state : ram_states_t := IDLE;
begin
    process (clk, reset)
        variable address : integer range 0 to NUM_ADDRESSES-1 := 0;
        variable byte : std_logic_vector(7 downto 0);
        variable rx_prev : std_logic := '0';
    begin
        if reset = '1' then -- Asynchronous reset
            -- Initialise signals and variables
            programming <= '0';
            ram_address <= (others => '0');
            ram_in <= (others => '0');
            ram_write <= '0';
            uart_out <= (others => '0');
            state <= IDLE;
            ram_state <= IDLE;
            tx_ena <= '0';
            address := 0;
            byte := (others => '0');
            rx_prev := '0';
        elsif rising_edge(clk) then
            -- Programming state machine
            case state is
                -- Wait for start byte
                when IDLE =>
                    programming <= '0';
                    ram_address <= (others => '0');
                    ram_in <= (others => '0');
                    ram_write <= '0';
                    uart_out <= (others => '0');
                    tx_ena <= '0';
                    address := 0;

                    -- Read byte from UART
                    if rx_prev = '1' and rx_busy = '0' then
                        if uart_in = START_BYTE then -- Start programming if start byte is received
                            state <= PROGRAM;
                            programming <= '1';
                            ram_state <= UPPER;
                            -- Update RAM address
                            ram_address <= std_logic_vector(to_unsigned(address, ram_address'length));
                        end if;
                    end if;
                    rx_prev := rx_busy;
                
                -- Read bytes from UART and store into RAM
                when PROGRAM =>
                    case ram_state is
                        when UPPER => -- Read upper byte
                            if rx_prev = '1' and rx_busy = '0' then
                                byte := uart_in;
                                ram_state <= LOWER;
                            end if;
                        when LOWER => -- Read lower byte
                            if rx_prev = '1' and rx_busy = '0' then
                                ram_in <= byte & uart_in;
                                ram_state <= WRITE;
                            end if;
                        when WRITE => -- Concatenate bytes and store word into RAM
                            ram_write <= '1';
                            ram_state <= IDLE;
                        when IDLE =>
                            ram_write <= '0';
                            ram_in <= (others => '0');
                            if address < NUM_ADDRESSES-1 then
                                address := address + 1; -- Increment RAM address
                                ram_state <= UPPER; -- Receive next word
                            else -- Finished loading program -> Begin verification
                                address := 0;
                                state <= VERIFY;
                                ram_state <= WRITE;
                            end if;
                            -- Update RAM address
                            ram_address <= std_logic_vector(to_unsigned(address, ram_address'length));
                    end case;
                    rx_prev := rx_busy;
                
                -- Transmit the previously stored data over UART
                -- Used to verify that the program was correctly loaded
                when VERIFY =>
                    case ram_state is
                        when WRITE => -- Load data from RAM
                            uart_out <= ram_out(15 downto 8); -- Buffer upper byte
                            ram_state <= UPPER;
                        when UPPER => -- Transmit upper byte
                            if tx_busy = '0' and tx_ena = '0' then
                                tx_ena <= '1';
                            end if;
                            if tx_busy = '1' and tx_ena = '1' then
                                tx_ena <= '0'; -- Begin transmission
                                uart_out <= ram_out(7 downto 0); -- Buffer lower byte
                                ram_state <= LOWER;
                            end if;
                        when LOWER => -- Transmit lower byte
                            if tx_busy = '0' and tx_ena = '0' then
                                tx_ena <= '1';
                            end if;
                            if tx_busy = '1' and tx_ena = '1' then
                                tx_ena <= '0'; -- Begin transmission
                                ram_state <= IDLE;
                            end if;
                        when IDLE =>
                            if address < NUM_ADDRESSES-1 then
                                address := address + 1; -- Increment RAM address
                                ram_state <= WRITE; -- Transmit next word
                            else -- Verification complete -> Change to idle state
                                address := 0;
                                state <= IDLE;
                            end if;
                            -- Update RAM address
                            ram_address <= std_logic_vector(to_unsigned(address, ram_address'length));
                    end case;
            end case;
        end if;
    end process;
end Behavioral;