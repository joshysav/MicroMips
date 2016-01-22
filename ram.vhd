library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
  
  port (
    clk      : in  std_logic;
    addr     : in  std_logic_vector(31 downto 0);
    data_in  : in  std_logic_vector(31 downto 0);
    read_en  : in  std_logic;
    write_en : in  std_logic;
    data_out : out std_logic_vector(31 downto 0));

end entity ram;

architecture rtl of ram is

  type ram_t is array (0 to 127) of std_logic_vector(31 downto 0);
  signal ram_s : ram_t := (others => (others => '0'));
  
begin  -- architecture rtl

  read : process (clk, read_en, write_en) is
  begin  -- process 
    if clk'event and clk = '1' then     -- rising clock edge
      if(read_en = '1') then
        data_out <= ram_s(to_integer(unsigned(addr)));
      elsif(write_en = '1') then
        ram_s(to_integer(unsigned(addr))) <= data_in;
      end if;
    end if;
  end process read;

end architecture rtl;
