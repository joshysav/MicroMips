library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
  port (
    clk           : in    std_logic;
    rst           : in    std_logic;
    pc_write      : in    std_logic;
    inst_data_sel : in    std_logic;    -- inst'Data from RAM
    ir_write      : in    std_logic;    -- InstructionRegister Write
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
end entity datapath;

architecture rtl of datapath is

  -- --------------------------------------------------------------------------
  -- COMPONENT DEFINITIONS
  -- --------------------------------------------------------------------------
  component fetch_unit is
    port (
      rst           : in  std_logic;                             -- Resets Fetch Unit
      clk           : in  std_logic;                             -- System clock input
      pc_in         : in  std_logic_vector(31 downto 0);         -- New PC value
      data_addr     : in  std_logic_vector(31 downto 0);  -- Addr to fetch data
      data          : in  std_logic_vector(31 downto 0);  -- Data from memory
      pc_write      : in  std_logic;    -- PC write enable
      inst_data_sel : in  std_logic;    -- Instruction or data
                                        -- select
      ir_write      : in  std_logic;    -- IR write enable
      ir_out        : out std_logic_vector(31 downto 0);  -- IR output
      dr_out        : out std_logic_vector(31 downto 0);  -- DR output
      addr          : out std_logic_vector(31 downto 0);
      pc_out        : out std_logic_vector(31 downto 0));
  end component fetch_unit;

  component decode_unit is
    port (
      clk         : in  std_logic;
      instr       : in  std_logic_vector(31 downto 0);
      data        : in  std_logic_vector(31 downto 0);
      alu_out     : in  std_logic_vector(31 downto 0);
      rd_sel      : in  std_logic_vector(1 downto 0);
      rd_data_sel : in  std_logic;
      rd_write_en : in  std_logic;
      rs          : out std_logic_vector(31 downto 0);
      rt          : out std_logic_vector(31 downto 0);
      se          : out std_logic_vector(31 downto 0));
  end component decode_unit;

  component execute_unit is
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
  end component execute_unit;

  component writeback_unit is
    port (
      clk        : in  std_logic;
      alu_res    : in  std_logic_vector(31 downto 0);
      rs         : in  std_logic_vector(31 downto 0);
      jmp_addr   : in  std_logic_vector(29 downto 0);
      pc_src_sel : in  std_logic_vector(1 downto 0);
      pc_next    : out std_logic_vector(31 downto 0);
      data       : out std_logic_vector(31 downto 0));
  end component writeback_unit;

  -- --------------------------------------------------------------------------
  -- INTERNAL SIGNALS
  -- --------------------------------------------------------------------------

  signal pc_next_sig   : std_logic_vector(31 downto 0);
  signal data_addr_sig : std_logic_vector(31 downto 0);
  signal ir_out_sig    : std_logic_vector(31 downto 0);
  signal dr_out_sig    : std_logic_vector(31 downto 0);
  signal pc_out_sig    : std_logic_vector(31 downto 0);
  signal mem_addr_sig  : std_logic_vector(31 downto 0);
  signal rs_out_sig    : std_logic_vector(31 downto 0);
  signal rt_out_sig    : std_logic_vector(31 downto 0);
  signal se_out_sig    : std_logic_vector(31 downto 0);
  signal alu_res_sig   : std_logic_vector(31 downto 0);
  signal jmp_addr_sig  : std_logic_vector(29 downto 0);
  
begin
  
  fetch_u : fetch_unit port map (
    rst           => rst,
    clk           => clk,
    pc_in         => pc_next_sig,
    data_addr     => data_addr_sig,
    data          => mem_data,
    pc_write      => pc_write,
    inst_data_sel => inst_data_sel,
    ir_write      => ir_write,
    ir_out        => ir_out_sig,
    dr_out        => dr_out_sig,
    addr          => mem_addr_sig,
    pc_out        => pc_out_sig);

  decode_u : decode_unit port map (
    clk         => clk,
    instr       => ir_out_sig,
    data        => dr_out_sig,
    alu_out     => data_addr_sig,
    rd_sel      => rd_sel,
    rd_data_sel => rd_data_sel,
    rd_write_en => rd_write_en,
    rs          => rs_out_sig,
    rt          => rt_out_sig,
    se          => se_out_sig);

  execute_u : execute_unit port map (
    clk          => clk,
    pc           => pc_out_sig,
    rs           => rs_out_sig,
    rt           => rt_out_sig,
    se           => se_out_sig,
    instr        => ir_out_sig,
    alu_op_a_sel => alu_op_a_sel,
    alu_op_b_sel => alu_op_b_sel,
    alu_arith_fn => alu_arith_fn,
    alu_logic_fn => alu_logic_fn,
    alu_fn       => alu_fn,
    jmp_addr_sel => jmp_addr_sel,
    alu_zero     => alu_zero,
    alu_ovfl     => alu_overflow,
    alu_res      => alu_res_sig,
    jmp_addr     => jmp_addr_sig);

  writeback_u : writeback_unit port map (
    clk        => clk,
    alu_res    => alu_res_sig,
    rs         => rs_out_sig,
    jmp_addr   => jmp_addr_sig,
    pc_src_sel => pc_src_sel,
    pc_next    => pc_next_sig,
    data       => data_addr_sig);

  mem_data <= rt_out_sig when (mem_write = '1' and mem_read = '0') else (others => 'Z');

  opcode   <= ir_out_sig(31 downto 26);
  func     <= ir_out_sig(5 downto 0);
  mem_addr <= mem_addr_sig;

end architecture rtl;
