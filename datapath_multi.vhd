library ieee;
use ieee.std_logic_1164.all;

entity datapath_multi is
  
  port (
    clk : in std_logic;
    rst:in std_logic;
    pc_write: in std_logic;
    inst_data_sel: in std_logic;
    tmp_input: in std_logic_vector(31 downto 0);
    z_reg_out_sig: in std_logic_vector(31 downto 0);
    tmp: out std_logic_vector(31 downto 0));

end entity datapath_multi;

architecture rtl of datapath_multi is

-- REGISTERS
signal pc : std_logic_vector(31 downto 0);

-- INTERNAL SIGNALS
signal pc_src_sig : std_logic_vector(31 downto 0);   -- signal from .....
--signal z_reg_out_sig : std_logic_vector(31 downto 0);
signal addr_sig : std_logic_vector(31 downto 0);

begin  -- architecture rtl

  -- PROGRAM COUNTER
  pc_update: process (clk, rst, pc_write) is
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      pc <= (others => '0');
    elsif clk'event and clk = '1' and pc_write = '1' then  -- rising clock edge
      pc <= tmp_input;
    end if;
  end process;

-- SELECT ADDRESS SOURCE FOR RAM
inst_data_sel_proc: process (pc, z_reg_out_sig, inst_data_sel) is
 begin  -- process inst_data_sel_proc
   case inst_data_sel is
     when '0' =>
       addr_sig <= pc;
     when others =>
       addr_sig <= z_reg_out_sig;
   end case;
 end process inst_data_sel_proc;

 

 tmp <= addr_sig;
end architecture rtl;
