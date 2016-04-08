library ieee;
use ieee.std_logic_1164.all;


entity core is
  port (
    clk       : in    std_logic;
    rst       : in    std_logic;
    mem_read  : out   std_logic;
    mem_write : out   std_logic;
    mem_data  : inout std_logic_vector(31 downto 0);
    mem_addr  : out   std_logic_vector(31 downto 0));
end entity core;

architecture arc of core is

  -- --------------------------------------------------------------------------
  -- COMPONENT DEFINITIONS
  -- --------------------------------------------------------------------------
  component control_unit is
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      op            : in  std_logic_vector(5 downto 0);
      fn            : in  std_logic_vector(5 downto 0);
      alu_overflow  : in  std_logic;
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
  end component control_unit;

  component datapath is
    port (
      clk           : in    std_logic;
      rst           : in    std_logic;
      pc_write      : in    std_logic;
      inst_data_sel : in    std_logic;  -- inst'Data from RAM
      ir_write      : in    std_logic;  -- InstructionRegister Write
      rd_sel        : in    std_logic_vector(1 downto 0);
      rd_data_sel   : in    std_logic;
      rd_write_en   : in    std_logic;
      alu_op_a_sel  : in    std_logic;
      alu_op_b_sel  : in    std_logic_vector(1 downto 0);
      alu_arith_fn  : in    std_logic;
      alu_logic_fn  : in    std_logic_vector(1 downto 0);
      alu_fn        : in    std_logic_vector(1 downto 0);
      pc_src_sel    : in    std_logic_vector(1 downto 0);
      jmp_addr_sel  : in    std_logic;
      mem_read      : in    std_logic;
      mem_write     : in    std_logic;
      alu_overflow  : out   std_logic;
      alu_zero      : out   std_logic;
      opcode        : out   std_logic_vector(5 downto 0);
      func          : out   std_logic_vector(5 downto 0);
      mem_addr      : out   std_logic_vector(31 downto 0);
      mem_data      : inout std_logic_vector(31 downto 0));
  end component datapath;

  -- --------------------------------------------------------------------------
  -- INTERNAL SIGNALS
  -- --------------------------------------------------------------------------

  signal pc_write_sig      : std_logic;
  signal inst_data_sel_sig : std_logic;  -- inst'Data from RAM
  signal ir_write_sig      : std_logic;  -- InstructionRegister Write
  signal rd_sel_sig        : std_logic_vector(1 downto 0);
  signal rd_data_sel_sig   : std_logic;
  signal rd_write_en_sig   : std_logic;
  signal alu_op_a_sel_sig  : std_logic;
  signal alu_op_b_sel_sig  : std_logic_vector(1 downto 0);
  signal alu_arith_fn_sig  : std_logic;
  signal alu_logic_fn_sig  : std_logic_vector(1 downto 0);
  signal alu_fn_sig        : std_logic_vector(1 downto 0);
  signal pc_src_sel_sig    : std_logic_vector(1 downto 0);
  signal jmp_addr_sel_sig  : std_logic;
  signal alu_overflow_sig  : std_logic;
  signal opcode_sig        : std_logic_vector(5 downto 0);
  signal func_sig          : std_logic_vector(5 downto 0);
  signal mem_read_sig      : std_logic;
  signal mem_write_sig     : std_logic;
  signal alu_zero_sig      : std_logic;
  
begin  -- architecture arc

  cu : control_unit port map (
    clk           => clk,
    rst           => rst,
    op            => opcode_sig,
    fn            => func_sig,
    alu_overflow  => alu_overflow_sig,
    pc_write      => pc_write_sig,
    inst_data_sel => inst_data_sel_sig,
    mem_read      => mem_read_sig,
    mem_write     => mem_write_sig,
    ir_write      => ir_write_sig,
    rd_sel        => rd_sel_sig,
    rd_data_sel   => rd_data_sel_sig,
    rd_write_en   => rd_write_en_sig,
    alu_op_a_sel  => alu_op_a_sel_sig,
    alu_op_b_sel  => alu_op_b_sel_sig,
    alu_arith_fn  => alu_arith_fn_sig,
    alu_logic_fn  => alu_logic_fn_sig,
    alu_fn        => alu_fn_sig,
    pc_src_sel    => pc_src_sel_sig,
    jmp_addr_sel  => jmp_addr_sel_sig);

  datap : datapath port map (
    clk           => clk,
    rst           => rst,
    pc_write      => pc_write_sig,
    inst_data_sel => inst_data_sel_sig,
    ir_write      => ir_write_sig,
    rd_sel        => rd_sel_sig,
    rd_data_sel   => rd_data_sel_sig,
    rd_write_en   => rd_write_en_sig,
    alu_op_a_sel  => alu_op_a_sel_sig,
    alu_op_b_sel  => alu_op_b_sel_sig,
    alu_arith_fn  => alu_arith_fn_sig,
    alu_logic_fn  => alu_logic_fn_sig,
    alu_fn        => alu_fn_sig,
    pc_src_sel    => pc_src_sel_sig,
    jmp_addr_sel  => jmp_addr_sel_sig,
    mem_read      => mem_read_sig,
    mem_write     => mem_write_sig,
    alu_overflow  => alu_overflow_sig,
    alu_zero      => alu_zero_sig,
    opcode        => opcode_sig,
    func          => func_sig,
    mem_addr      => mem_addr,
    mem_data      => mem_data);

  mem_read  <= mem_read_sig;
  mem_write <= mem_write_sig;


end architecture arc;
