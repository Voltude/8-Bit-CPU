----------------------------------------------------------------------------------
-- Author:       Lab A01 Group 18
-- 
-- Assignment:   ENEL373 ALU+FSM+Regs project
-- Create Date:  12.05.2019 12:37:58
-- Module Name:  display - Behavioural
-- Project Name: CPU-design
-- Description:  Controls displaying information on the seven segment display and 
--               leds.
--               Features in-built clock divider because display should run at a 
--               reduced frequency from the input 100MHz.
-- 
-- Dependencies: ssd_display.vhd
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
    Port (
        clk : in std_logic;                         -- Clock signal (100MHz)
        reset : in std_logic;                       -- Asynchronous reset
        data : in std_logic_vector(15 downto 0);    -- Data input
        address : out std_logic_vector(1 downto 0); -- Address output 
        leds : out std_logic_vector(15 downto 0);   -- Output to LED arrays
        cathode : out std_logic_vector(0 to 6);     -- Cathode output
        anode : out std_logic_vector(7 downto 0));  -- Anode output
end display;

architecture Behavioral of display is
    constant CLK_DIV : integer := 100000;   -- Max clock divider counter value

    -- Display states
    type disp_state_t is (LOWER_LED, UPPER_LED, LOWER_SSD, UPPER_SSD);
    signal disp_state : disp_state_t;

    signal disp_clk : std_logic;                        -- Clock signal sent to ssd_display module
    signal bin_disp : std_logic_vector(26 downto 0);    -- Binary display signal to ssd_display module

    alias value : std_logic_vector(7 downto 0) is data(7 downto 0); -- Value to display
begin
    -- Seven-segment display module
    SSD : entity work.ssd_display port map (
        clk     => disp_clk,
        rst     => reset,
        binary  => bin_disp,
        ssd     => cathode,
        an      => anode);

    -- VRAM address for each peripheral (memory mapping)
    with disp_state select address <=
        "00" when LOWER_LED,
        "01" when UPPER_LED,
        "10" when LOWER_SSD,
        "11" when UPPER_SSD;
    
    -- Main process
    process (disp_clk, reset)
    begin
        if reset = '1' then     -- Asynchronous reset
            disp_state <= LOWER_LED;
            leds <= (others => '0');
            bin_disp <= (others => '0');
        elsif rising_edge(disp_clk) then
            -- Cycle quickly through displaying each peripheral
            case disp_state is
                when LOWER_LED => -- Display on lower portion of LED's
                    disp_state <= UPPER_LED;        -- Next portion to display
                    leds(7 downto 0) <= value;      -- Display value
                when UPPER_LED => -- Display on upper portion of LED's
                    disp_state <= LOWER_SSD;        -- Next portion to display
                    leds(15 downto 8) <= value;     -- Display value 
                when LOWER_SSD => -- Display on lower portion of Seven Segment display
                    disp_state <= UPPER_SSD;        -- Next portion to display
                    bin_disp(7 downto 0) <= value;  -- Display value
                when UPPER_SSD => -- Display on upper portion of Seven Segment display
                    disp_state <= LOWER_LED;        -- Next portion to display
                    bin_disp(15 downto 8) <= value; -- Display value
            end case;
        end if;
    end process;

    -- Clock divider
    process (clk, reset)
        variable count : integer := 0;
    begin
        if reset = '1' then     -- Asynchronous reset
            count := 0;
        elsif rising_edge(clk) then
            if count < CLK_DIV-1 then
                count := count + 1; -- Iterate count
                disp_clk <= '0';
            else --(count >= CLK_DIV-1, clock has reached it's max)
                count := 0;
                disp_clk <= '1';    -- Create clock pulse
            end if;         
        end if;             
    end process;            
end Behavioral;
