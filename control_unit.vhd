library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
  
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    op            : in  std_logic_vector(5 downto 0);
    fn            : in  std_logic_vector(5 downto 0);
    alu_overflow     : in  std_logic;
    pc_write      : out std_logic;
    inst_data_sel : out std_logic;
    mem_read      : out std_logic;
    mem_write     : out std_logic;
    ir_write      : out std_logic;
    rd_sel        : out std_logic_vector(1 downto 0);
    rd_data_sel   : out std_logic;
    rd_write_en   : out std_logic;
    alu_op_a_sel  : out std_logic;
    alu_op_b_sel  : out std_logic_vector(1 downto 0);
    alu_arith_fn  : out std_logic;
    alu_logic_fn  : out std_logic_vector(1 downto 0);
    alu_fn        : out std_logic_vector(1 downto 0);
    pc_src_sel    : out std_logic_vector(1 downto 0);
    jmp_addr_sel  : out std_logic);

end entity control_unit;

architecture rtl of control_unit is
  type state_t is (FETCH, DECODE, BRANCH, MEM, MEM_ST, MEM_LD_1, MEM_LD_2, ALU_1, ALU_2, EXCEPTION);
  signal state : state_t;
begin  -- architecture rtl

  upade_state : process (clk, rst) is
  begin  -- process upade_state
    if rst = '0' then                   -- asynchronous reset (active low)
      state <= FETCH;
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- ---------------------------------------------------
      -- FETCH
      -- ---------------------------------------------------
      if state = FETCH then
        state <= DECODE;
      -- ---------------------------------------------------
      -- DECODE
      -- ---------------------------------------------------
      elsif state = DECODE then
        if op = "000000" or op = "001000" or op = "001010" or op = "001100" or op = "001101" or op = "001110" then
          state <= ALU_1;
        elsif op = "100011" or op = "101011" then
          state <= MEM;
        elsif op = "000010" or op = "000001" or op = "000100" or op = "000101" or op = "000011" then
          state <= BRANCH;
        else
          state <= EXCEPTION;
        end if;
      -- ---------------------------------------------------
      -- ALU_1
      -- ---------------------------------------------------
      elsif state = ALU_1 then
        state <= ALU_2;
      -- ---------------------------------------------------
      -- MEM
      -- ---------------------------------------------------
      elsif state = MEM then
        if op = "100011" then
          state <= MEM_LD_1;
        elsif op = "101011" then
          state <= MEM_ST;
        else
          state <= EXCEPTION;
        end if;
      -- ---------------------------------------------------
      -- MEM_LD_1
      -- ---------------------------------------------------
      elsif state = MEM_LD_1 then
        state <= MEM_LD_2;
      -- ---------------------------------------------------
      -- ALU_2 | MEM_LD_2 | MEM_ST | BRANCH
      -- ---------------------------------------------------
      elsif state = ALU_2 or state = MEM_LD_2 or state = MEM_ST or state = BRANCH then
        state <= FETCH;
      -- ---------------------------------------------------
      -- UNKNOWN
      -- ---------------------------------------------------
      else
        state <= EXCEPTION;
      end if;
    end if;
  end process upade_state;

  control_signals : process (state, op, fn) is
  begin  -- process control_signals
    inst_data_sel <= '-';
    mem_read      <= '0';
    mem_write     <= '0';
    ir_write      <= '0';
    alu_op_a_sel  <= '-';
    alu_op_b_sel  <= "--";
    alu_arith_fn  <= '-';
    alu_logic_fn  <= "--";
    alu_fn        <= "--";
    pc_src_sel    <= "--";
    pc_write      <= '0';
    rd_sel        <= "--";
    rd_data_sel   <= '-';
    rd_write_en   <= '0';
    jmp_addr_sel  <= '-';

    case state is
      when FETCH =>
        inst_data_sel <= '0';
        mem_read      <= '1';
        ir_write      <= '1';
        alu_op_a_sel  <= '0';
        alu_op_b_sel  <= "00";
        alu_arith_fn  <= '0';
        alu_fn        <= "10";
        pc_src_sel    <= "11";
        pc_write      <= '1';
      when DECODE =>
        alu_op_a_sel <= '0';
        alu_op_b_sel <= "11";
        alu_arith_fn <= '0';
        alu_fn       <= "10";
      when ALU_1 =>
        alu_op_a_sel <= '1';
        -- Two register operations
        if op = "000000" then
          -- ADD
          if fn = "100000" then
            alu_op_b_sel <= "01";
            alu_arith_fn <= '0';
            alu_fn       <= "10";
          -- SUB
          elsif fn = "100010" then
            alu_op_b_sel <= "01";
            alu_arith_fn <= '1';
            alu_fn       <= "10";
          -- SLT
          elsif fn = "101010" then
            alu_op_b_sel <= "01";
            alu_arith_fn <= '1';
            alu_fn       <= "01";
          -- AND
          elsif fn = "100100" then
            alu_op_b_sel <= "01";
            alu_logic_fn <= "00";
            alu_fn       <= "11";
          -- OR
          elsif fn = "100101" then
            alu_op_b_sel <= "01";
            alu_logic_fn <= "01";
            alu_fn       <= "11";
          -- XOR
          elsif fn = "100110" then
            alu_op_b_sel <= "01";
            alu_logic_fn <= "10";
            alu_fn       <= "11";
          -- NOR
          elsif fn = "100111" then
            alu_op_b_sel <= "01";
            alu_logic_fn <= "11";
            alu_fn       <= "11";
          end if;
        -- ADDI
        elsif op = "001000" then
          alu_op_b_sel <= "10";
          alu_arith_fn <= '0';
          alu_fn       <= "10";
        -- STLI
        elsif op = "001010" then
          alu_op_b_sel <= "10";
          alu_arith_fn <= '1';
          alu_fn       <= "01";
        -- ANDI
        elsif op = "001100" then
          alu_op_b_sel <= "10";
          alu_logic_fn <= "00";
          alu_fn       <= "11";
        -- ORI
        elsif op = "001101" then
          alu_op_b_sel <= "10";
          alu_logic_fn <= "01";
          alu_fn       <= "11";
        -- XORI
        elsif op = "001110" then
          alu_op_b_sel <= "10";
          alu_logic_fn <= "10";
          alu_fn       <= "11";
        -- LUI
        elsif op = "001111" then
          alu_op_b_sel <= "10";
          alu_fn       <= "00";
        end if;
      when ALU_2 =>
        rd_data_sel <= '1';
        rd_write_en <= '1';
        -- Rd = Rs + Rt
        if op = "000000" then
          rd_sel <= "01";
        -- Rt = Rs + Imm
        else
          rd_sel <= "00";
        end if;
      when MEM =>
        alu_op_a_sel <= '1';
        alu_op_b_sel <= "10";
        alu_arith_fn <= '0';
        alu_fn       <= "10";
      when MEM_LD_1 =>
        inst_data_sel <= '1';
        mem_read      <= '1';
      when MEM_LD_2 =>
        rd_sel      <= "00";
        rd_data_sel <= '0';
        rd_write_en <= '1';
      when MEM_ST =>
        inst_data_sel <= '1';
        mem_write     <= '1';
      when others => null;
    end case;
  end process control_signals;
  
end architecture rtl;

