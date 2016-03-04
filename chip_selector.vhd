library ieee;
use ieee.std_logic_1164.all;

entity chip_selector is
  port(
    addr : in  std_logic_vector(15 downto 0);
    cs0  : out std_logic;
    cs1  : out std_logic;
    cs2  : out std_logic);
end entity chip_selector;

architecture arc of chip_selector is

begin
  process (addr) is
  begin
    cs0 <= '0';
    cs1 <= '0';
    cs2 <= '0';
    --------------------------------------------
    -- MEMORY  0x0000 to 0x07FF
    --------------------------------------------
    if addr(15 downto 12) = "0000" then
      -- ---------------------------------------
      -- ROM  0x000 to 0x03FF
      -- ---------------------------------------
      if addr(11 downto 10) = "00" then
        cs0 <= '1';
      -- ---------------------------------------
      -- RAM  0x0400 to 0x07FF
      -- ---------------------------------------
      elsif addr(11 downto 10) = "01" then
        cs1 <= '1';
      end if;
    --------------------------------------------  
    -- I/O  0x8000 to 0xFFFF
    -------------------------------------------
    elsif addr(15) = '1' then
      cs2 <= '1';
    end if;
  end process;
end architecture arc;
