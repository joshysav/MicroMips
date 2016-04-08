library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_256x8 is
  port (
    clk  : in    std_logic;
    ce   : in    std_logic;
    we   : in    std_logic;
    oe   : in    std_logic;
    addr : in    std_logic_vector(7 downto 0);
    data : inout std_logic_vector(7 downto 0));
end entity mem_256x8;

architecture rtl of mem_256x8 is

  type ram_t is array (255 downto 0) of std_logic_vector(7 downto 0);
  signal mem_s : ram_t := (others => (others => '0'));

  signal data_out_sig : std_logic_vector(7 downto 0);
  
begin
  
  data <= data_out_sig when (ce = '1' and oe = '1' and we = '0') else (others => 'Z');

  WRITE : process (clk, ce, we) is
  begin  -- process write
    if clk'event and clk = '1' and ce = '1' and we = '1' then
      mem_s(to_integer(unsigned(addr))) <= data;
    end if;
  end process write;

  READ : process (clk, ce, oe) is
  begin  -- process
    if clk'event and clk = '1' and ce = '1' and oe = '1' then
      data_out_sig <= mem_s(to_integer(unsigned(addr)));
    end if;
  end process;

end architecture rtl;
