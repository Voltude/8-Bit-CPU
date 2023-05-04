----------------------------------------------------------------------------------
-- Author:       Lab A01 Group 18
-- 
-- Assignment:   ENEL373 ALU+FSM+Regs project
-- Create Date:  09.05.2019 00:08:44
-- Module Name:  controller - Behavioural
-- Project Name: CPU-design
-- Description:  Controls operations within the CPU - reads instructions from RAM
--               and decodes/executes these instructions. Generates the required
--               register and ALU control signals.
-- 
-- Dependencies: None
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller is
    generic (
        NUM_BITS : integer := 8;
        NUM_REGS : integer := 16;
        INSTRUCTION_SIZE : integer := 16;
        ADDRESS_SIZE : integer := 8);
    port (
        clk : in std_logic;                                             -- Main clock
        reset : in std_logic;                                           -- Asynchronous reset
        databus : inout std_logic_vector(NUM_BITS-1 downto 0);          -- Main data bus
        a, b : out std_logic_vector(NUM_BITS-1 downto 0);               -- ALU operands
        result : in std_logic_vector(NUM_BITS-1 downto 0);              -- ALU result
        opcode : out std_logic_vector(5 downto 0);                      -- ALU opcode
        status : in std_logic_vector(3 downto 0);                       -- ALU status flags
        regs_en, regs_ld : out std_logic_vector(NUM_REGS-1 downto 0);   -- Load/enable registers
        ram_in : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);      -- RAM input data
        ram_out : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);    -- RAM output data
        ram_wr : out std_logic;                                         -- RAM write enable
        address : out std_logic_vector(ADDRESS_SIZE-1 downto 0);        -- RAM address
        led : out std_logic_vector(15 downto 0));                       -- Display instructions
end controller;

architecture Behavioral of controller is
    -- Instruction Cycle State Machine
    type state_t is (FETCH, DECODE, EXECUTE);
    signal state : state_t := FETCH;

    -- ALU States
    type alu_states_t is (IDLE, LOAD_A, LOAD_B, STORE);
    signal alu_state : alu_states_t;

    -- Data States
    type data_states_t is (MOV, LDI, LDR, STR);

    -- Instruction Types
    type instructions_t is (CONTROL, BRANCH, DATA, ALU);

    -- RAM Read/Write States
    type ram_states_t is (IDLE, READ, WRITE);
    signal ram_state : ram_states_t;

    -- Program Counter
    signal pc : integer range 0 to (2**ADDRESS_SIZE)-1;

    -- Instruction Register
    signal ir : std_logic_vector(INSTRUCTION_SIZE-1 downto 0);

    -- ALU IR decoded vector slices
    alias alu_r0 : std_logic_vector(3 downto 0) is ir(3 downto 0);
    alias alu_r1 : std_logic_vector(3 downto 0) is ir(7 downto 4);
    alias alu_opcode : std_logic_vector(5 downto 0) is ir(13 downto 8);
    
    -- Branching IR decoded vector slices
    alias branch_code : std_logic_vector(2 downto 0) is ir(13 downto 11);
    alias branch_address : std_logic_vector(7 downto 0) is ir(7 downto 0);

    -- Data IR decoded vector slices
    alias data_r0 : std_logic_vector(3 downto 0) is ir(11 downto 8);
    alias data_r1 : std_logic_vector(3 downto 0) is ir(7 downto 4);
    alias data_val : std_logic_vector(7 downto 0) is ir(7 downto 0);
    alias data_address : std_logic_vector(7 downto 0) is ir(7 downto 0);
    alias data_in : std_logic_vector(7 downto 0) is ram_in(7 downto 0);

    -- No operation indication bit decoded
    alias nop : std_logic is ram_in(13);

    -- Decoder for enabling and loading registers
    function reg(reg : std_logic_vector(3 downto 0))
        return std_logic_vector is
        variable D : std_logic_vector(NUM_REGS-1 downto 0) := (others => '0');
    begin
        D(to_integer(unsigned(reg))) := '1';
        return D;
    end reg;

    -- Function decode instruction type
    function instruction(ir_code : std_logic_vector(INSTRUCTION_SIZE-1 downto 0))
        return instructions_t is
        alias intruction_code : std_logic_vector(1 downto 0) is ir_code(15 downto 14);
    begin
        if intruction_code = "00" then
            return CONTROL;
        elsif intruction_code = "01" then
            return BRANCH;
        elsif intruction_code = "10" then
            return DATA;
        else -- intruction_code = "11"
            return ALU;
        end if;
    end instruction;

    -- Function to decode data instructions
    function data_state(ir_code : std_logic_vector(INSTRUCTION_SIZE-1 downto 0))
        return data_states_t is
        alias data_code : std_logic_vector(1 downto 0) is ir_code(13 downto 12);
    begin
        if data_code = "00" then
            return MOV;
        elsif data_code = "01" then
            return LDI;
        elsif data_code = "10" then
            return LDR;
        else -- data_code = "11"
            return STR;
        end if;
    end data_state;

    -- Function to decode branch instructions
    function branch(code   : std_logic_vector(2 downto 0);
                    status : std_logic_vector(3 downto 0))
        return std_logic is
        -- Status register flags
        alias zero : std_logic is status(0);
        alias neg  : std_logic is status(1);
        alias cout : std_logic is status(2);
        alias over : std_logic is status(3);
        variable jump : std_logic := '0';
    begin
        if code = "001" then
            jump := '1'; -- JMP
        elsif code = "010" and zero = '1' then
            jump := '1'; -- JEZ
        elsif code = "011" and zero = '0' then
            jump := '1'; -- JNZ
        elsif code = "100" and neg = '0' and zero = '0' then
            jump := '1'; -- JGZ
        elsif code = "101" and neg = '1' and zero = '0' then
            jump := '1'; -- JLZ
        elsif code = "110" and cout = '1' then
            jump := '1'; -- JCA
        elsif code = "111" and over = '1' then
            jump := '1'; -- JOV
        else
            jump := '0'; -- Do not branch
        end if;
        return jump;
    end branch;

begin
    address <= std_logic_vector(to_unsigned(pc, address'length)) when ram_state = IDLE else data_address;
    ram_out <= ram_in(15 downto 8) & databus;
    
    process (clk, reset)
    begin
        if reset = '1' then -- Asynchronous reset
            -- Initialise signals
            state <= FETCH;
            alu_state <= IDLE;
            ram_state <= IDLE;
            ir <= (others => '0');
            pc <= 0;
            databus <= (others => 'Z');
            opcode <= (others => '0');
            regs_en <= (others => '0');
            regs_ld <= (others => '0');
            ram_wr <= '0';
            led <= x"0000";
        
        elsif rising_edge(clk) then
            -- Main state machine
            case state is
                -- Fetch instruction
                when FETCH =>
                    -- Initialise signals
                    led <= ram_in;
                    ir <= ram_in;
                    databus <= (others => 'Z');
                    regs_en <= (others => '0');
                    regs_ld <= (others => '0');
                    ram_wr <= '0';

                    -- Control instructions must be executed immediately
                    if instruction(ram_in) = CONTROL then
                        state <= FETCH;
                        -- Load next instruction when performing a NOP
                        if nop = '1' then
                            pc <= pc + 1;
                        end if;
                        -- Otherwise HLT CPU (PC not incremented)
                    else -- Move to decode state
                        state <= DECODE;
                        pc <= pc + 1; -- Increment PC
                    end if;
                
                -- Decode instruction
                when DECODE =>
                    state <= EXECUTE; -- Move to next state
                    -- Find instruction type
                    case instruction(ir) is
                        -- Branch instruction
                        when BRANCH =>
                            state <= FETCH; -- Move to fetch instruction state
                            if branch(branch_code, status) = '1' then
                                -- Update PC if branching
                                pc <= to_integer(unsigned(branch_address));
                            end if;
                        -- Data transfer instruction
                        when DATA =>
                            -- Decode data instruction
                            case data_state(ir) is
                                when MOV =>                     -- Move instruction
                                    regs_en <= reg(data_r1);    -- Output register on databus
                                when LDI =>                     -- Load immediate value into register
                                    databus <= data_val;        -- Place immediate value on databus
                                when LDR =>                     -- Load data from RAM into register
                                    ram_state <= READ;
                                when STR =>                     -- Store register into RAM
                                    ram_state <= WRITE;
                                    regs_en <= reg(data_r0);    -- Output register on databus
                                    ram_wr <= '1';              -- Store databus in RAM
                                when others =>                  -- Do nothing
                            end case;
                        -- ALU instruction
                        when ALU =>
                            alu_state <= LOAD_A;
                            opcode <= alu_opcode;               -- Update ALU opcode
                            regs_en <= reg(alu_r0);             -- Output R0 on databus
                        -- This state should never be reached
                        when others =>
                            state <= FETCH; -- Ensure state machine cannot get stuck in this state
                    end case;
                
                -- Execute instruction
                when EXECUTE =>
                    -- Find instruction type
                    case instruction(ir) is
                        -- Data transfer instruction
                        when DATA =>
                            -- Decode data instruction
                            case data_state(ir) is
                                when MOV =>                         -- Move data between registers
                                    state <= FETCH;
                                    regs_ld <= reg(data_r0);        -- Load register
                                when LDI =>                         -- Load databus value into register
                                    state <= FETCH;
                                    regs_ld <= reg(data_r0);        -- Load register
                                when LDR =>                         -- Load data from RAM into register
                                    if ram_state = READ then        -- Read from RAM
                                        databus <= data_in;         -- Place value on databus
                                        ram_state <= IDLE;
                                    else                            -- Load databus into register
                                        state <= FETCH;
                                        regs_ld <= reg(data_r0);    -- Load register
                                    end if;
                                when STR =>                         -- Store register into RAM
                                    ram_state <= IDLE;
                                    state <= FETCH;
                                    ram_wr <= '0';
                                when others =>
                            end case;
                        -- ALU instruction
                        when ALU =>
                            case alu_state is
                                -- Load R0 into register A
                                when LOAD_A =>
                                    alu_state <= LOAD_B;
                                    a <= databus;
                                    regs_en <= reg(alu_r1);
                                -- Load R1 into register B
                                when LOAD_B =>
                                    alu_state <= STORE;
                                    b <= databus;
                                    regs_en <= (others => '0');
                                -- Place ALU result on databus
                                when STORE =>
                                    databus <= result;
                                    alu_state <= IDLE;
                                -- Store databus into register
                                when IDLE =>
                                    state <= FETCH;
                                    -- Load register
                                    regs_ld <= reg(alu_r0);
                            end case;
                        -- This state should never be reached
                        when others =>
                            state <= FETCH; -- Ensure state machine cannot get stuck in this state
                    end case;
                end case;
        end if;
    end process;
end Behavioral;
