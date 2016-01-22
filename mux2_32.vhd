library ieee;
use ieee.std_logic_1164.all;

entity mux2_32 is
  port (
    a, b : in  std_logic_vector(31 downto 0);
    sel        : in  std_logic;
    o          : out std_logic_vector(31 downto 0));
end entity mux2_32;

architecture arc of mux2_32 is

begin  -- architecture arc
  process(a, b, sel)
  begin
    case sel is
      when '0'   => o <= a;
      when '1'   => o <= b;
      when others => o <= (others => '-');
    end case;
  end process;
end architecture arc;


