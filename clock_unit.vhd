library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_unit is
  
  port (
    clk_ext : in  std_logic;
    clk_out : out std_logic;
    cs      : in  std_logic;
    re      : in  std_logic;
    we      : in  std_logic;
    addr    : in  std_logic_vector(15 downto 0);
    data    : in std_logic_vector(31 downto 0));

end entity clock_unit;

architecture arc of clock_unit is

  signal counter   : integer   := 0;
  signal divider   : integer   := 0;
  signal clk_value : std_logic := '0';
  
begin  -- architecture arc

  rising_clock : process (clk_ext) is
  begin  -- process clock
    if rising_edge(clk_ext) then
      if counter = divider then
        counter   <= 0;
        clk_value <= not clk_value;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process rising_clock;

  sys_clk: process(clk_value, cs, we) is
  begin  -- process
    if rising_edge(clk_value) and cs = '1' and we = '1' then
      divider <= to_integer(unsigned(data));
    end if;
  end process sys_clk;

  clk_out <= clk_value;

end architecture arc;
