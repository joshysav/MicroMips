library ieee;
use ieee.std_logic_1164.all;

entity writeback_unit is
  port (
    clk        : in  std_logic;
    alu_res    : in  std_logic_vector(31 downto 0);
    rs         : in  std_logic_vector(31 downto 0);
    jmp_addr   : in  std_logic_vector(29 downto 0);
    pc_src_sel : in  std_logic_vector(1 downto 0);
    pc_next    : out std_logic_vector(31 downto 0);
    data       : out std_logic_vector(31 downto 0));
end entity writeback_unit;

architecture rtl of writeback_unit is

  -- --------------------------------------------------------------------------
  -- REGISTERS
  -- --------------------------------------------------------------------------
  signal z_reg : std_logic_vector(31 downto 0);
  
begin  -- architecture rtl

-- Store ALU result into Z register
  update_x : process (clk) is
  begin
    if clk'event and clk = '1' then     -- rising clock edge
      z_reg <= alu_res;
    end if;
  end process;

-- Select source for next PC address
  pc_src_sel_mux : process (jmp_addr, rs, z_reg, alu_res, pc_src_sel)
  begin
    if pc_src_sel = "00" then
      pc_next <= jmp_addr & "00";       -- add 2 extra bits (30)
    elsif pc_src_sel = "01" then
      pc_next <= rs;
    elsif pc_src_sel = "10" then
      pc_next <= z_reg;
    else
      pc_next <= alu_res;
    end if;
  end process pc_src_sel_mux;

  -- Output Z register
  data <= z_reg;
end architecture rtl;
