-----------------------------------------------------------------------------------------
-- Author:       Lab A01 Group 18
-- 
-- Assignment:   ENEL373 ALU+FSM+Regs project
-- Create Date:  -
-- Module Name:  alu - Behavioural
-- Project Name: CPU-design
-- Resources:    https://www.nand2tetris.org/  for opcode
-- Description:  Arithmetic logic unit. Performs operations on the values in
--               regs, A and B. Outputs the result. Takes in a 6-bit opcode instruction
-- 
-- Dependencies: None
-- 
-----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity alu is
    generic (
        N : integer := 8);
    port (
        opcode  : in  std_logic_vector(5 downto 0);     -- Opcode
        x, y    : in  std_logic_vector(N-1 downto 0);   -- Operands
        output  : out std_logic_vector(N-1 downto 0);   -- Result
        status  : out std_logic_vector(3 downto 0));    -- Flags
end alu;

architecture behaviour of alu is
begin
    process (x, y, opcode)
        variable xbuf, ybuf : std_logic_vector(N-1 downto 0);
        variable outbuf     : std_logic_vector(N-1 downto 0);
        variable addbuf     : std_logic_vector(N downto 0);
        
        -- Opcode (inspired by NAND to Tetris)
        variable zx : std_logic; -- Zero the x input
        variable nx : std_logic; -- Invert the x input
        variable zy : std_logic; -- Zero the y input
        variable ny : std_logic; -- Invert the y input
        variable f  : std_logic; -- If f = 1: x + y, if f = 0: x & y
        variable no : std_logic; -- Invert the out output

        -- Status flags
        variable zero : std_logic := '0'; -- Zero out
        variable neg  : std_logic := '0'; -- Negative
        variable cout : std_logic := '0'; -- Carry out
        variable over : std_logic := '0'; -- Overflow
    begin
        xbuf := x;
        ybuf := y;
        
        -- Opcode
        zx := opcode(0);
        nx := opcode(1);
        zy := opcode(2);
        ny := opcode(3);
        f  := opcode(4);
        no := opcode(5);

        -- Zero x
        if zx = '1' then
            xbuf := (others => '0');
        end if;

        -- Invert x
        if nx = '1' then
            xbuf := not xbuf;
        end if;

        -- Zero y
        if zy = '1' then
            ybuf := (others => '0');
        end if;

        -- Invert y
        if ny = '1' then
            ybuf := not ybuf;
        end if;
        
        -- Add / And
        if f = '1' then
            addbuf := std_logic_vector(unsigned('0' & xbuf) + unsigned('0' & ybuf));
            outbuf := addbuf(7 downto 0);
            cout   := addbuf(N); -- Set carry out flag
        else
            outbuf := xbuf and ybuf;
        end if;

        -- Invert output
        if no = '1' then
            outbuf := not outbuf;
        end if;

        -- Status flags (carry out flag already computed)
        neg := outbuf(N-1) and f;

        -- Compute overflow flag
        if f = '1' then
            if (nx or ny or no) = '0' then -- x + y
                over := (x(N-1) and y(N-1) and (not outbuf(N-1))) or
                        ((not x(N-1)) and (not y(N-1)) and outbuf(N-1));
            elsif (nx or (not ny) or no) = '1' then -- x - y
                over := (x(N-1) and (not y(N-1)) and (not outbuf(N-1))) or
                        ((not x(N-1)) and y(N-1) and outbuf(N-1));
            elsif ((not nx) or ny or no) = '1' then -- y - x
                over := (x(N-1) and (not y(N-1)) and outbuf(N-1)) or
                        ((not x(N-1)) and y(N-1) and (not outbuf(N-1)));
            end if;
        end if;
        
        -- Compute zero flag
        if unsigned(outbuf) = 0 then
            zero := '1';
        else
            zero := '0';
        end if;

        -- Outputs
        output <= outbuf;
        status <= over & cout & neg & zero;
    end process;
end behaviour;