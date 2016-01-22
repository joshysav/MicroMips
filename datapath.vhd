library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
  
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    rd_sel      : in  std_logic_vector(1 downto 0);
    alu_src_sel : in  std_logic;
    fn_class    : in  std_logic_vector(1 downto 0);
    logic_fn    : in  std_logic_vector(1 downto 0);
    arith_fn    : in  std_logic;
    ovfl        : out std_logic;
    ram_read    : in  std_logic;
    ram_write   : in  std_logic;
    rd_data_sel: in std_logic_vector(1 downto 0));

end entity datapath;

architecture rtl of datapath is

  -- ======================================================
  -- COMPONENT DEFINITIONS
  -- ======================================================
  component rom is
    port (
      addr : in  std_logic_vector(31 downto 0);
      data : out std_logic_vector(31 downto 0));
  end component rom;

  component register_file is
    port (
      rs_sel, rt_sel, rd_sel : in  std_logic_vector(4 downto 0);
      rd_data                : in  std_logic_vector(31 downto 0);
      write_en, clk          : in  std_logic;
      rs_data, rt_data       : out std_logic_vector(31 downto 0));
  end component register_file;

  component mux3_5 is
    port (
      a, b, c : in  std_logic_vector(4 downto 0);
      sel     : in  std_logic_vector(1 downto 0);
      o       : out std_logic_vector(4 downto 0));
  end component mux3_5;

  component mux2_32 is
    port (
      a, b : in  std_logic_vector(31 downto 0);
      sel  : in  std_logic;
      o    : out std_logic_vector(31 downto 0));
  end component mux2_32;

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

  component ram is
    port (
      clk      : in  std_logic;
      addr     : in  std_logic_vector(31 downto 0);
      data_in  : in  std_logic_vector(31 downto 0);
      read_en  : in  std_logic;
      write_en : in  std_logic;
      data_out : out std_logic_vector(31 downto 0));
  end component ram;

  component mux3_32 is
    port (
      a, b, c : in  std_logic_vector(31 downto 0);
      sel     : in  std_logic_vector(1 downto 0);
      o       : out std_logic_vector(31 downto 0));
  end component mux3_32;

  -- ======================================================
  -- SIGNALS
  -- ======================================================

  signal pc            : std_logic_vector(31 downto 0) := (others => '0');
  signal instruction_s : std_logic_vector(31 downto 0);

  signal rd_sel_s   : std_logic_vector(4 downto 0);
  signal rs_data_s  : std_logic_vector(31 downto 0);
  signal rt_data_s  : std_logic_vector(31 downto 0);
  signal alu_op_b_s : std_logic_vector(31 downto 0);

  signal alu_result_s : std_logic_vector(31 downto 0);

  signal ram_out_s : std_logic_vector(31 downto 0);
  signal rd_data_s : std_logic_vector(31 downto 0);
  signal incr_pc_s : std_logic_vector(31 downto 0);
  
begin  -- architecture rtl

  i_rom : component rom port map (
    addr => pc,
    data => instruction_s);

  reg_file : component register_file port map (
    rs_sel   => instruction_s(25 downto 21),
    rt_sel   => instruction_s(20 downto 16),
    rd_sel   => rd_sel_s,
    rd_data  => rd_data_s,
    write_en => '0',
    clk      => clk,
    rs_data  => rs_data_s,
    rt_data  => rt_data_s);

  rd_sel_mux : component mux3_5 port map (
    a   => instruction_s(20 downto 16),
    b   => instruction_s(15 downto 11),
    c   => (others => '1'),
    sel => rd_sel,
    o   => rd_sel_s);

  alu_src_mux : component mux2_32 port map (
    a   => rt_data_s,
    b   => std_logic_vector(resize(signed(instruction_s(15 downto 0)), 32)),
    sel => alu_src_sel,
    o   => alu_op_b_s);

  alu_inst : component alu port map (
    op_a     => rs_data_s,
    op_b     => alu_op_b_s,
    fn_class => fn_class,
    logic_fn => logic_fn,
    arith_fn => arith_fn,
    result   => alu_result_s,
    ovfl     => ovfl);

  ram_inst : component ram port map (
    clk      => clk,
    addr     => alu_result_s,
    data_in  => rt_data_s,
    read_en  => ram_read,
    write_en => ram_write,
    data_out => ram_out_s);

  rd_data_mux : component mux3_32 port map (
    a   => ram_out_s,
    b   => alu_result_s,
    c   => incr_pc_s,
    sel => rd_data_sel,
    o => rd_data_s);

  update_pc : process (clk, rst) is
  begin  -- process update_pc
    if rst = '1' then                   -- asynchronous reset (active low)
      pc <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      pc <= std_logic_vector(unsigned(pc) + 4);
    end if;
  end process update_pc;
  
end architecture rtl;
