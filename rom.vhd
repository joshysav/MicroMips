library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
  
  port (
    addr : in  std_logic_vector(31 downto 0);
    data : out std_logic_vector(31 downto 0));

end entity rom;

architecture rtl of rom is
  signal addr_s : std_logic_vector(3 downto 0) := (others => '0');
  
  type rom_t is array (0 to 15) of std_logic_vector(31 downto 0);
  signal rom_s : rom_t :=
    (
      ("00000000000000000000000000000000"),
      ("00000000000000000000000000000001"),
      ("00000000000000000000000000000010"),
      ("00000000000000000000000000000011"),
      ("00000000000000000000000000000100"),
      ("00000000000000000000000000000101"),
      ("00000000000000000000000000000110"),
      ("00000000000000000000000000000111"),
      ("00000000000000000000000000001000"),
      ("00000000000000000000000000001001"),
      ("00000000000000000000000000001010"),
      ("00000000000000000000000000001011"),
      ("00000000000000000000000000001100"),
      ("00000000000000000000000000001101"),
      ("00000000000000000000000000001110"),
      ("00000000000000000000000000001111")
      );

begin  -- architecture rtl

  read: process (addr) is
  begin  -- process read
      addr_s <= addr(5 downto 2);
  end process read;

  data <= rom_s(to_integer(unsigned(addr_s)));
  
end architecture rtl;
