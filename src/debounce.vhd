library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
    Generic (
        count_max : integer := 100000);
    Port (
        clk : in std_logic;             -- Clock signal (100MHz)
        input : in std_logic;           -- Input button signal
        output : out std_logic);        -- Output debounced signal
end debounce;

architecture Behavioral of debounce is
    signal buff_0, buff_1 : std_logic;  -- Input buffers
begin
    process(clk)
        variable counter_lad : integer := 0;
    begin
        if rising_edge(clk) then
            buff_1 <= buff_0;           -- Buffer 1 takes previous value of buffer 0
            buff_0 <= input;            -- Buffer 0 takes new input button value

            if (buff_0 xor buff_1) = '1' then   -- Detects button input state change
                counter_lad := 0;               -- Reset the count every time a bounce or press occurs
            elsif counter_lad = count_max then  -- Enough time has passed without bouncing
                output <= buff_1;               -- Set output to the current state of the input
            else
                counter_lad := counter_lad + 1; -- Iterate count
            end if;
        end if;
    end process;
end Behavioral;
