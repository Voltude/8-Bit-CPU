library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_controller is
    Port ( clk_in : in STD_LOGIC;       -- Input 100MHz clock signal
           c_butt_in : in STD_LOGIC;    -- Centre button input
           u_butt_in : in STD_LOGIC;    -- Up button input
           d_butt_in : in STD_LOGIC;    -- Down button input
           l_butt_in : in STD_LOGIC;    -- Left button input
           reset : in STD_LOGIC;        -- Asynchronous reset
           clk_out : out STD_LOGIC);    -- Output new clock signal
end clk_controller;

architecture Behavioral of clk_controller is
    -- Initialise modes
    type state_t is (NORMAL, MANUAL);
    signal state : state_t := NORMAL;

    -- Initialise frequency states
    type freq_states_t is (FREQ_1HZ, FREQ_10HZ, FREQ_20HZ, FREQ_50HZ, FREQ_100HZ, FREQ_1KHZ);
    signal freq_state : freq_states_t := FREQ_20HZ;

    -- Initialise max count levels
    constant MAX_1HZ : integer := 50000000-1;
    constant MAX_10HZ : integer := 5000000-1;
    constant MAX_20HZ : integer := 2500000-1;
    constant MAX_50HZ : integer := 1000000-1;
    constant MAX_100HZ : integer := 500000-1;
    constant MAX_1KHZ : integer := 50000-1;
    
    -- Initialise signals for debounced buttons and previous button states
    signal c_butt_db, u_butt_db, d_butt_db, l_butt_db : STD_LOGIC;          -- Debounced buttons
    signal l_butt_prev, u_butt_prev, d_butt_prev, c_butt_prev : STD_LOGIC;  -- Buttons previous states
begin

-- Debounce Buttons
-- Each button needs to be debounced individually
C_DEBOUNCER : entity work.debounce port map (
    clk     => clk_in,              -- 100 MHz
    input   => c_butt_in,           -- Raw centre button input
    output  => c_butt_db);          -- Debounced centre button signal
    
U_DEBOUNCER : entity work.debounce port map (
    clk     => clk_in,              -- 100 MHz
    input   => u_butt_in,           -- Raw up button input 
    output  => u_butt_db);          -- Debounced up button signal
    
D_DEBOUNCER : entity work.debounce port map (
    clk     => clk_in,              -- 100 MHz
    input   => d_butt_in,           -- Raw down button input
    output  => d_butt_db);          -- Debounced down button input
    
L_DEBOUNCER : entity work.debounce port map (
    clk     => clk_in,              -- 100 MHz
    input   => l_butt_in,           -- Raw left button input   
    output  => l_butt_db);          -- Debounced left button signal
    
-- Process
    process(clk_in) is
        variable count : integer range 0 to MAX_1HZ := 0;
        variable tmp_clk : std_logic;
        variable max_count : integer range 0 to MAX_1HZ := MAX_20HZ;
    begin
    if reset = '1' then     -- Asynchronous reset
        count := 0;             -- Reset count
        tmp_clk := '0';         -- Set the output to zero
        clk_out <= '0';         -- Set the output to zero
        -- purposely not setting the the states back to the defaults as it 
        -- caused issues with manual clocking
    elsif rising_edge(clk_in) then
        case state is
            when NORMAL =>
                -- Check if l button is pushed to switch to manual
                if (c_butt_db = '1' AND c_butt_prev = '0') then
                    state <= MANUAL;
                end if;
                
                case freq_state is
                    when FREQ_1HZ =>
                    max_count := MAX_1HZ;       -- Set max for counter
                    -- Update state if buttons are pushed
                    if (u_butt_db = '1' AND u_butt_prev = '0') then
                        freq_state <= FREQ_10HZ;
                    end if;
                    
                    
                    when FREQ_10HZ =>
                    max_count := MAX_10HZ;      -- Set max for counter
                    -- Update state if buttons are pushed
                    if (d_butt_db = '1' AND d_butt_prev = '0') then
                        freq_state <= FREQ_1HZ;
                    elsif (u_butt_db = '1' AND u_butt_prev = '0') then
                        freq_state <= FREQ_20HZ;
                    end if;
                    
                    when FREQ_20HZ =>
                    max_count := MAX_20HZ;      -- Set max for counter
                    -- Update state if buttons are pushed
                    if (d_butt_db = '1' AND d_butt_prev = '0') then
                        freq_state <= FREQ_10HZ;
                    elsif (u_butt_db = '1' AND u_butt_prev = '0') then
                        freq_state <= FREQ_50HZ;
                    end if;
                   
                    when FREQ_50HZ =>
                    max_count := MAX_50HZ;      -- Set max for counter
                    -- Update state if buttons are pushed
                    if (d_butt_db = '1' AND d_butt_prev = '0') then
                        freq_state <= FREQ_20HZ;
                    elsif (u_butt_db = '1' AND u_butt_prev = '0') then
                        freq_state <= FREQ_100HZ;
                    end if;
                    
                    when FREQ_100HZ =>
                    max_count := MAX_100HZ;     -- Set max for counter
                    -- Update state if buttons are pushed
                    if (d_butt_db = '1' AND d_butt_prev = '0') then
                        freq_state <= FREQ_50HZ;
                    elsif (u_butt_db = '1' AND u_butt_prev = '0') then
                        freq_state <= FREQ_1KHZ;
                    end if;
                    
                    when FREQ_1KHZ =>
                    max_count := MAX_1KHZ;      -- Set max for counter
                    -- Update state if buttons are pushed
                    if (d_butt_db = '1' AND d_butt_prev = '0') then
                            freq_state <= FREQ_100HZ;
                    end if;
                end case;

            when MANUAL =>
            max_count := MAX_1KHZ;      -- Set max for counter
            -- Update state if buttons are pushed
            if (c_butt_db = '1' AND c_butt_prev = '0') then
                state <= NORMAL;
            elsif (l_butt_db = '1' AND l_butt_prev = '0') then
                tmp_clk := '1'; -- Trigger clock
            elsif tmp_clk = '0' then
                count := 0; -- Hold count at '0'
            end if;
        end case;

        -- Iterate count
        if count >= max_count then
            count := 0;
            tmp_clk := not tmp_clk;
        else
            count := count + 1;
        end if;
        
        -- Update the output clock signal
        clk_out <= tmp_clk;
        -- Update buttons previous state for next cycle
        l_butt_prev <= l_butt_db;
        u_butt_prev <= u_butt_db;
        d_butt_prev <= d_butt_db;
        c_butt_prev <= c_butt_db;
    end if;
    end process;
end Behavioral;
