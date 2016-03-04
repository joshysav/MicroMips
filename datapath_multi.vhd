library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath_multi is
  port (
    clk :               in std_logic;
    rst:                in std_logic;
    pc_write:           in std_logic;
    inst_data_sel:      in std_logic;                   -- inst'Data from RAM
    ir_write:           in std_logic;                   -- InstructionRegister Write
    rd_sel:             in std_logic_vector(1 downto 0);
    rd_data_sel:        in std_logic;
    rd_write_en:        in std_logic;
    alu_op_a_sel:       in std_logic;
    alu_op_b_sel:       in std_logic_vector(1 downto 0);
    alu_arith_fn:       in std_logic;
    alu_logic_fn:       in std_logic_vector(1 downto 0);
    alu_fn:             in std_logic_vector(1 downto 0);
    pc_src_sel:         in std_logic_vector(1 downto 0);
    jmp_addr_sel:       in std_logic;

    mem_data_in:            in std_logic_vector(31 downto 0);
    
    -- output
    alu_overflow :      out std_logic;

    mem_addr:           out std_logic_vector(31 downto 0);
    mem_data_out:       out std_logic_vector(31 downto 0);

    opcode:             out std_logic_vector(5 downto 0);
    func:               out std_logic_vector(5 downto 0)

    );	--port end



end entity datapath_multi;

architecture rtl of datapath_multi is

 component register_file is

   port (
     rs_sel, rt_sel, rd_sel : in  std_logic_vector(4 downto 0);
     rd_data                : in  std_logic_vector(31 downto 0);
     write_en, clk          : in  std_logic;
     rs_data, rt_data       : out std_logic_vector(31 downto 0));

 end component register_file;

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


---- REGISTERS
    signal pc_register :            std_logic_vector(31 downto 0);
    signal ir_register :           std_logic_vector(31 downto 0);
 signal dr_register : std_logic_vector(31 downto 0);
  signal x_register :    std_logic_vector(31 downto 0);
  signal y_register :    std_logic_vector(31 downto 0);
  signal z_register :    std_logic_vector(31 downto 0);


---- INTERNAL SIGNALS
    signal pc_src_mux_out_sig : std_logic_vector(31 downto 0); -- output from pc src select mux

    signal inst_data_mux_out :  std_logic_vector(31 downto 0);

    signal ram_out_sig      :  std_logic_vector(31 downto 0);  -- out signal from RAM

    signal rd_mux_out_sig   :    std_logic_vector(4 downto 0);
    signal rd_data_mux_out_sig :    std_logic_vector(31 downto 0);

    signal reg_file_rs_out_sig : std_logic_vector(31 downto 0);
    signal reg_file_rt_out_sig : std_logic_vector(31 downto 0);

    signal op_a_mux_out_sig : std_logic_vector(31 downto 0);
    signal op_b_mux_out_sig : std_logic_vector(31 downto 0);

    signal immediate_se : std_logic_vector(31 downto 0);

    signal alu_out_sig : std_logic_vector(31 downto 0);

    signal jmp_addr_mux_out_sig : std_logic_vector(29 downto 0);

begin  -- architecture rtl

reg_file : register_file port map (
  rs_sel => ir_register(25 downto 21),
  rt_sel => ir_register(20 downto 16),
  rd_sel => rd_mux_out_sig,
  rd_data => rd_data_mux_out_sig,
  write_en => rd_write_en,
  clk => clk,
  rs_data => reg_file_rs_out_sig,
  rt_data => reg_file_rt_out_sig
);

alu_inst : alu port map (
  op_a      => op_a_mux_out_sig,
  op_b      => op_b_mux_out_sig,
  fn_class  => alu_fn,
  logic_fn  => alu_logic_fn,
  arith_fn  => alu_arith_fn,
  result    => alu_out_sig,
  ovfl      => alu_overflow

);

--  -- PROGRAM COUNTER
 pc_update: process (clk, rst, pc_write, pc_src_mux_out_sig) is
 begin  -- process
   if rst = '0' then                   -- asynchronous reset (active low)
     pc_register <= (others => '0');
   elsif clk'event and clk = '1'and pc_write = '1' then
      pc_register <= pc_src_mux_out_sig;
   end if;
 end process;

---- RAM
mem_data_output: process (y_register) is
  begin
    mem_data_out <= y_register;
  end process mem_data_output;

  

---- SELECT ADDRESS SOURCE FOR RAM
inst_data_sel_proc: process (pc_register, z_register, inst_data_sel) is
begin  -- process inst_data_sel_proc
  case inst_data_sel is
    when '0' =>
      mem_addr <= pc_register;                  -- program counter to address
    when others =>
      mem_addr <= z_register;       --
  end case;
end process inst_data_sel_proc;

-- -- REGISTERS
ir_register_update: process (clk, mem_data_in, ir_write) is
begin
  if clk'event and clk ='1' and ir_write = '1' then
      ir_register <= mem_data_in;
  end if;
end process ir_register_update;


-- -- DATA REGISTERS
dr_register_update: process (clk, mem_data_in) is
begin
  if clk'event and clk ='1' then
      dr_register <= mem_data_in;
  end if;
end process dr_register_update;

rd_sel_mux: process (ir_register, rd_sel) is
begin
  case( rd_sel ) is
    when "00" =>
        rd_mux_out_sig <= ir_register(20 downto 16);
    when "01" =>
          rd_mux_out_sig <= ir_register(15 downto 11);
    when others =>
          rd_mux_out_sig <= (others => '1');
  end case;

end process rd_sel_mux;


rd_data_sel_mux: process (rd_data_sel, dr_register , z_register) is
begin
  case( rd_data_sel ) is
    when '0' =>
        rd_data_mux_out_sig <= dr_register;
    when others =>
      rd_data_mux_out_sig <= z_register;
  end case;
end process rd_data_sel_mux;

x_register_update: process (clk, reg_file_rs_out_sig) is
begin
  if clk'event and clk ='1' then
      x_register <= reg_file_rs_out_sig;
  end if;
end process x_register_update;

y_register_update: process (clk, reg_file_rt_out_sig) is
begin
  if clk'event and clk ='1' then
      y_register <= reg_file_rt_out_sig;
  end if;
end process y_register_update;

op_a_sel_mux: process (pc_register, x_register, alu_op_a_sel) is
begin
  case( alu_op_a_sel ) is
    when '0' =>
        op_a_mux_out_sig <= pc_register;
    when others =>
          op_a_mux_out_sig <= x_register;
  end case;
end process op_a_sel_mux;


sign_extend: process (ir_register) is
begin
  -- converts 16 to 32
  immediate_se <= std_logic_vector(resize(signed(ir_register(15 downto 0)), 32));
end process sign_extend;

op_b_sel_mux : process (y_register, immediate_se, alu_op_b_sel)
begin
  case( alu_op_b_sel ) is
    when "00" =>
      op_b_mux_out_sig <= (("00000000000000000000000000000") & "100"); -- change function
      when "01" =>
        op_b_mux_out_sig <= y_register;
        when "10" =>
          op_b_mux_out_sig <= immediate_se;
          when others =>
            op_b_mux_out_sig <= std_logic_vector(unsigned(immediate_se) sll 2);

  end case;
end process op_b_sel_mux;

z_register_update : process (clk, alu_out_sig) is
begin
  if clk'event and clk ='1' then
      z_register <= alu_out_sig;
  end if;
end process z_register_update;


jmp_addr_mux : process (ir_register, jmp_addr_sel, pc_register) is
begin
case( jmp_addr_sel ) is
  when '0' =>
      jmp_addr_mux_out_sig <= (pc_register(31 downto 28) & ir_register(25 downto 0));
  when others =>
      --TODO: add sysCallAddr
        jmp_addr_mux_out_sig <= (others => '0');
end case;
end process jmp_addr_mux;


pc_src_sel_mux : process (jmp_addr_mux_out_sig, x_register, z_register, alu_out_sig, pc_src_sel)
begin
  case( pc_src_sel ) is
    when "00" =>
      pc_src_mux_out_sig <= jmp_addr_mux_out_sig & "00"; -- add 2 bits (30)
      when "01" =>
        pc_src_mux_out_sig <= x_register;
        when "10" =>
          pc_src_mux_out_sig <= z_register;
          when others =>
          pc_src_mux_out_sig <= alu_out_sig;
  end case;
end process pc_src_sel_mux;

opcode <= ir_register(31 downto 26);
func <= ir_register(5 downto 0);


end architecture rtl;

