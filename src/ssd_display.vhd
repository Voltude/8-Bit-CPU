library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ssd_display is
    Generic (
        NUM_SEGS : integer := 7;                                -- Number of segments per digit
        NUM_BITS : integer := 27;                               -- Number of bits in binary input
        NUM_DIGITS : integer := 8);                             -- Number of digits in display
    Port ( clk, rst : in std_logic;
           binary : in std_logic_vector (NUM_BITS-1 downto 0);  -- Binary of value to display
           ssd : out std_logic_vector (NUM_SEGS-1 downto 0);    -- Seven Segment Display 
           an : out std_logic_vector (NUM_DIGITS-1 downto 0));  -- Anodes (active low)
end ssd_display;

architecture Behavioral of ssd_display is
    signal bin_in : std_logic_vector  (NUM_BITS-1 downto 0);
    signal bcd : std_logic_vector (31 downto 0);
    signal bcd_disp : std_logic_vector (3 downto 0);
begin
    -- bin to bcd module
    -- Convert binary value to binary coded decimal
    bin2bcd : entity work.bin_to_bcd port map (
        bin => bin_in,
        bcd => bcd);
    
    -- bcd to ssd
    -- Convert binary coded decimal value to seven segment display signal
    bcd2ssd : entity work.bcd_to_ssd port map (
        bcd => bcd_disp,
        ssd => ssd);
    
    process (clk, rst)
        variable disp_on : std_logic := '0';
        variable digit : integer range 0 to NUM_DIGITS-1 := NUM_DIGITS-1;
        variable bcd_buf : std_logic_vector (3 downto 0);
        variable an_buf : std_logic_vector (NUM_DIGITS-1 downto 0);
    begin
        if rst = '1' then
            -- Initialise signals and variables
            bin_in <= (others => '0');
            bcd_disp <= (others => '0');
            an <= (others => '1');                                  -- Disable all displays (active low)
            an_buf := (others => '1');                              -- Disable all displays (active low)
            bcd_buf := (others => '1');                             -- Reset buffer (active low)
            digit := NUM_DIGITS-1;                                  -- Start at leftmost digit
            disp_on := '0';
        elsif rising_edge(clk) then
            bin_in <= binary;                                       -- Update decoder binary input
            bcd_buf := bcd (digit*4+3 downto digit*4);              -- Extract digit
            
            -- Main state machine
            -- Ensures zeros to the right of the most significant digit are not displayed
            case digit is
                -- Rightmost digit
                when 0 =>
                    an_buf := '1' & an_buf (NUM_DIGITS-1 downto 1); -- Enable next display
                    disp_on := '0';                                 -- Reset display on flag
                    digit := NUM_DIGITS-1;                          -- Reset digit counter
                    bcd_disp <= bcd_buf;
                
                -- Middle digits
                when 1 to 6 =>
                    an_buf := '1' & an_buf (NUM_DIGITS-1 downto 1); -- Enable next display
                    if bcd_buf = "0000" and disp_on = '0' then
                        bcd_disp <= (others => '1');                -- Disable display
                    else
                        bcd_disp <= bcd_buf;
                        disp_on := '1';                             -- Enable display
                    end if;
                    digit := digit - 1;                             -- Decrement digit
                
                -- Leftmost digit
                when 7 =>
                an_buf := "01111111";                           -- Enable the leftmost digit
                if bcd_buf = "0000" and disp_on = '0' then
                    bcd_disp <= (others => '1');                -- Disable display
                    disp_on := '0';                             -- Keep display off
                else
                    bcd_disp <= bcd_buf;
                    disp_on := '1';                             -- Enable display
                end if;
                digit := digit - 1;                             -- Decrement digit
            end case;

            an <= an_buf;                                           -- Update anodes
        end if;
    end process;
end Behavioral;