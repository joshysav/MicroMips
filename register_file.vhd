library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
  
  port (
    rs_sel, rt_sel, rd_sel : in  std_logic_vector(4 downto 0);
    rd_data                : in  std_logic_vector(31 downto 0);
    write_en, clk          : in  std_logic;
    rs_data, rt_data       : out std_logic_vector(31 downto 0));

end entity register_file;

architecture rtl of register_file is

  type register_f is array(0 to 31) of std_logic_vector(31 downto 0);
  signal register_f_s         : register_f := (others => (others => '0'));
  signal rs_data_s, rt_data_s : std_logic_vector(31 downto 0);
  
begin  -- architecture rtl

  write : process (clk) is
  begin
    if rising_edge(clk) and write_en = '1' then
      register_f_s(to_integer(unsigned(rd_sel))) <= rd_data;
    end if;
  end process;

  read : process (rs_sel, rt_sel) is
  begin  -- process read
    if (rs_sel = "00000") then
      rs_data_s <= (others => '0');
    else
      rs_data_s <= register_f_s(to_integer(unsigned(rs_sel)));
    end if;

    if (rt_sel = "00000") then
      rt_data_s <= (others => '0');
    else
      rt_data_s <= register_f_s(to_integer(unsigned(rt_sel)));
    end if;
  end process read;

  rs_data <= rs_data_s;
  rt_data <= rt_data_s;
end architecture rtl;
