library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
  port (
    chip_en : in  std_logic;
    read_en : in  std_logic;
    addr    : in  std_logic_vector(9 downto 0);
    data    : out std_logic_vector(31 downto 0));
end entity rom;

architecture rtl of rom is

  type rom_t is array (0 to 1023) of std_logic_vector(31 downto 0);
  signal rom_s : rom_t := ((others => (others => '0')));
  
begin  -- architecture rtl
  rom_s(0)  <= "00100001000010000000000000000000";
  rom_s(1)  <= "00100001001010010000001111111111";
  rom_s(2)  <= "00100000000010100000000000010000";
  rom_s(3)  <= "00000000000000000101100000100000";
  rom_s(4)  <= "00010001010010110000000000000110";
  rom_s(5)  <= "10001101000100000000000000000000";
  rom_s(6)  <= "10101101001100000000000000000000";
  rom_s(7)  <= "00100001011010110000000000000001";
  rom_s(8)  <= "00100001000010000000000000000100";
  rom_s(9)  <= "00100001001010010000000000000100";
  rom_s(10) <= "00001000000100000000000000000100";


  read : process (addr, read_en, chip_en, rom_s) is
  begin  -- process read
    data <= (others => 'Z');
    if(chip_en = '1' and read_en = '1') then
      data <= rom_s(to_integer(unsigned(addr)));
    end if;
  end process read;

end architecture rtl;
