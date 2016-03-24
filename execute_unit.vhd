library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute_unit is
  port (
    clk          : in  std_logic;
    pc           : in  std_logic_vector(31 downto 0);
    rs           : in  std_logic_vector(31 downto 0);
    rt           : in  std_logic_vector(31 downto 0);
    se           : in  std_logic_vector(31 downto 0);
    instr        : in  std_logic_vector(31 downto 0);
    alu_op_a_sel : in  std_logic;
    alu_op_b_sel : in  std_logic_vector(1 downto 0);
    alu_arith_fn : in  std_logic;
    alu_logic_fn : in  std_logic_vector(1 downto 0);
    alu_fn       : in  std_logic_vector(1 downto 0);
    jmp_addr_sel : in  std_logic;
    alu_zero     : out std_logic;
    alu_ovfl     : out std_logic;
    alu_res      : out std_logic_vector(31 downto 0);
    jmp_addr     : out std_logic_vector(29 downto 0));
end entity execute_unit;

architecture rtl of execute_unit is

  -- --------------------------------------------------------------------------
  -- COMPONENT DEFINITIONS
  -- --------------------------------------------------------------------------
  component alu is
    port (
      op_a     : in  std_logic_vector(31 downto 0);
      op_b     : in  std_logic_vector(31 downto 0);
      fn_class : in  std_logic_vector(1 downto 0);
      logic_fn : in  std_logic_vector(1 downto 0);
      arith_fn : in  std_logic;
      result   : out std_logic_vector(31 downto 0);
      ovfl     : out std_logic);
  end component alu;

  -- --------------------------------------------------------------------------
  -- INTERNAL SIGNALS
  -- --------------------------------------------------------------------------
  signal op_a_sig     : std_logic_vector(31 downto 0);
  signal op_b_sig     : std_logic_vector(31 downto 0);
  signal jmp_addr_sig : std_logic_vector(29 downto 0);

  -- Vector table
  signal rst_vec_addr : std_logic_vector(29 downto 0) := std_logic_vector(to_unsigned(0, 30));
  signal sys_vec_addr : std_logic_vector(29 downto 0) := std_logic_vector(to_unsigned(1, 30));
  
begin  -- architecture rtl

  alu_inst : alu port map (
    op_a     => op_a_sig,
    op_b     => op_b_sig,
    fn_class => alu_fn,
    logic_fn => alu_logic_fn,
    arith_fn => alu_arith_fn,
    result   => alu_res,
    ovfl     => alu_ovfl);

  -- Select operand A for ALU
  op_a_sel_mux : process (pc, rs, alu_op_a_sel) is
  begin
    case (alu_op_a_sel) is
      when '0' =>
        op_a_sig <= pc;
      when others =>
        op_a_sig <= rs;
    end case;
  end process op_a_sel_mux;

  -- Select operand B for ALU
  op_b_sel_mux : process (rt, se, alu_op_b_sel) is
  begin
    case (alu_op_b_sel) is
      when "00" =>
        op_b_sig <= (("00000000000000000000000000000") & "100");  -- FIX ME
      when "01" =>
        op_b_sig <= rt;
      when "10" =>
        op_b_sig <= se;
      when others =>
        op_b_sig <= std_logic_vector(unsigned(se) sll 2);
    end case;
  end process op_b_sel_mux;

  -- Selects jump address
  jmp_addr_sel_mux : process (pc, instr, jmp_addr_sel, rst_vec_addr) is
  begin
    case jmp_addr_sel is
      when '0' =>
        jmp_addr_sig <= pc(31 downto 28) & instr(25 downto 0);
      when others =>
        jmp_addr_sig <= rst_vec_addr;
    end case;
  end process jmp_addr_sel_mux;

  -- Output next jump address
  jmp_addr <= jmp_addr_sig;
end architecture rtl;
