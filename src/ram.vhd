----------------------------------------------------------------------------------
-- Author:       Lab A01 Group 18
-- 
-- Assignment:   ENEL373 ALU+FSM+Regs project
-- Create Date:  01.05.2019 14:23:41
-- Module Name:  ram - Behavioural
-- Project Name: CPU-design
-- Description:  Dual Port Random Access Memory Implementation
-- 
-- Dependencies: None
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram is
    Generic (
        DATA_WIDTH : integer := 16;
        NUM_ADDRESS_BITS : integer := 8);
    Port ( clk : in STD_LOGIC;                                          -- Clock signal
           write : in STD_LOGIC;                                        -- Write enable
           address : in STD_LOGIC_VECTOR (NUM_ADDRESS_BITS-1 downto 0); -- RAM address
           data_in : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);       -- Input data 
           data_out : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);     -- Output data
           vram_addr : in STD_LOGIC_VECTOR (1 downto 0);                -- VRAM address
           vram_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0));   -- VRAM data
end ram;

architecture Behavioral of ram is
    type ram_type is array (0 to (2**NUM_ADDRESS_BITS)-1) of std_logic_vector (DATA_WIDTH-1 downto 0);
    signal data : ram_type;
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if write = '1' then -- Write input data to RAM
                data(to_integer(unsigned(address))) <= data_in;
            end if;
        end if;
    end process;
    -- Output data at RAM address
    data_out <= data(to_integer(unsigned(address)));
    -- Output data at VRAM address
    vram_data <= data(to_integer("111111" & unsigned(vram_addr)));
end Behavioral;
