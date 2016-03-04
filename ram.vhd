library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
  
  port (
    chip_en  : in  std_logic;
    addr     : in  std_logic_vector(9 downto 0);
    data_in  : in  std_logic_vector(31 downto 0);
    read_en  : in  std_logic;
    write_en : in  std_logic;
    data_out : out std_logic_vector(31 downto 0));

end entity ram;

architecture rtl of ram is

  type ram_t is array (0 to 1023) of std_logic_vector(31 downto 0);
  signal ram_s    : ram_t                        := (others => (others => '0'));
 
begin  -- architecture rtl
  
  read: process (chip_en, read_en, addr, write_en, data_in, ram_s) is
  begin  -- process read
      data_out <= (others => 'Z');
      if chip_en = '1' then
        if write_en = '1' then
           ram_s(to_integer(unsigned(addr))) <= data_in;
        end if;
        if read_en = '1' then
           data_out <= ram_s(to_integer(unsigned(addr)));
        end if;
    end if;
  end process read;
end architecture rtl;
