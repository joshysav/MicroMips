-- Author: Joshua Savage & Andris Birza
-- Date: 20.04.2016
-- Filename: fetch_unit.vhd
-- Description: Datapath Fetch Unit for Micro Mips CPU
library ieee;
use ieee.std_logic_1164.all;

entity fetch_unit is
  port (
    rst           : in  std_logic;                       -- Resets Fetch Unit
    clk           : in  std_logic;                       -- System clock input
    pc_in         : in  std_logic_vector(31 downto 0);   -- New PC value
    data_addr     : in  std_logic_vector(31 downto 0);   -- Addr to fetch data
    data          : in  std_logic_vector(31 downto 0);   -- Data from memory
    pc_write      : in  std_logic;                       -- PC write enable
    inst_data_sel : in  std_logic;                       -- Instruction or data
                                                         -- select
    ir_write      : in  std_logic;                       -- IR write enable
    ir_out        : out std_logic_vector(31 downto 0);   -- IR output
    dr_out        : out std_logic_vector(31 downto 0);   -- DR output
    addr          : out std_logic_vector(31 downto 0);
    pc_out        : out std_logic_vector(31 downto 0));  -- Addr to memory
end entity fetch_unit;

architecture rtl of fetch_unit is

-- --------------------------------------------------------------------------
-- REGISTERS
-- --------------------------------------------------------------------------
  signal pc_register : std_logic_vector(31 downto 0);
  signal ir_register : std_logic_vector(31 downto 0);
  signal dr_register : std_logic_vector(31 downto 0);

-- --------------------------------------------------------------------------
-- INTERNAL SIGNALS
-- --------------------------------------------------------------------------

begin  -- architecture rtl
  -- Process updates PC value
  pc_update : process (clk, rst, pc_write, pc_in) is
  begin  -- process
    if rst = '0' then
      pc_register <= (others => '0');
    elsif clk'event and clk = '1'and pc_write = '1' then
      pc_register <= pc_in;
    end if;
  end process;

  -- Selects source for addr output, can be PC or data address
  inst_data_sel_proc : process (pc_register, data_addr, inst_data_sel) is
  begin  -- process inst_data_sel_proc
    case inst_data_sel is
      when '0' =>
        addr <= pc_register;
      when others =>
        addr <= data_addr;
    end case;
  end process inst_data_sel_proc;

  -- Update IR
  ir_register_update : process (clk, data, ir_write) is
  begin
    if clk'event and clk = '1' and ir_write = '1' then
      ir_register <= data;
    end if;
  end process ir_register_update;

  -- Update DR
  dr_register_update : process (clk, data) is
  begin
    if clk'event and clk = '1' then
      dr_register <= data;
    end if;
  end process dr_register_update;

  ir_out <= ir_register;
  dr_out <= dr_register;
  pc_out <= pc_register;

end architecture rtl;
