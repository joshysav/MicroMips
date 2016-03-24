library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode_unit is
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
end entity decode_unit;

architecture rtl of decode_unit is

  -- --------------------------------------------------------------------------
  -- COMPONENT DEFINITIONS
  -- --------------------------------------------------------------------------
  component register_file is
    port (
      rs_sel, rt_sel, rd_sel : in  std_logic_vector(4 downto 0);
      rd_data                : in  std_logic_vector(31 downto 0);
      write_en, clk          : in  std_logic;
      rs_data, rt_data       : out std_logic_vector(31 downto 0));
  end component register_file;

  -- --------------------------------------------------------------------------
  -- REGISTERS
  -- --------------------------------------------------------------------------
  signal x_register : std_logic_vector(31 downto 0);
  signal y_register : std_logic_vector(31 downto 0);

  -- --------------------------------------------------------------------------
  -- INTERNAL SIGNALS
  -- --------------------------------------------------------------------------
  signal rd_data_s : std_logic_vector(31 downto 0);
  signal rd_sel_s  : std_logic_vector(4 downto 0);
  
begin

  -- Instance of register file
  reg_file : register_file port map (
    rs_sel   => instr(25 downto 21),
    rt_sel   => instr(20 downto 16),
    rd_sel   => rd_sel_s,
    rd_data  => rd_data_s,
    write_en => rd_write_en,
    clk      => clk,
    rs_data  => rs,
    rt_data  => rt);

  -- Selects destination register
  rd_sel_mux : process (instr, rd_sel) is
  begin
    case rd_sel is
      when "00" =>
        rd_sel_s <= instr(20 downto 16);
      when "01" =>
        rd_sel_s <= instr(15 downto 11);
      when others =>
        rd_sel_s <= (others => '1');
    end case;
  end process rd_sel_mux;

  -- Selects data source for destination register
  rd_data_sel_mux : process (rd_data_sel, data, alu_out) is
  begin
    case (rd_data_sel) is
      when '0' =>
        rd_data_s <= data;
      when others =>
        rd_data_s <= alu_out;
    end case;
  end process rd_data_sel_mux;

  -- Sign extend 16 bit immediate value from instruction to 32 bits
  sign_extend : process (instr) is
  begin
    se <= std_logic_vector(resize(signed(instr(15 downto 0)), 32));
  end process sign_extend;

end architecture rtl;
