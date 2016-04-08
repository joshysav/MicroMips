library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
  port (
    clk      : in    std_logic;
    ce       : in    std_logic;
    oe       : in    std_logic;
    we       : in    std_logic;
    byte_sel : in    std_logic_vector(3 downto 0);
    addr     : in    std_logic_vector(15 downto 0);
    data     : inout std_logic_vector(31 downto 0));
end entity ram;

architecture rtl of ram is

  type ram_t is array (255 downto 0) of std_logic_vector(31 downto 0);
  signal mem_s : ram_t := (others => (others => '0'));
  signal data_out_sig : std_logic_vector(31 downto 0);

begin

  data <= data_out_sig when (ce = '1' and oe = '1' and we = '0') else (others => 'Z');

  WRITE : process (clk, ce, we) is
  begin  -- process write
    if clk'event and clk = '1' and ce = '1' and we = '1' then
      mem_s(to_integer(unsigned(addr(9 downto 2)))) <= data;
    end if;
  end process write;

  READ : process (addr, mem_s) is
  begin  -- process
      data_out_sig <= mem_s(to_integer(unsigned(addr(9 downto 2))));
  end process;
  
end architecture rtl;

--architecture rtl of ram is

--  component mem_256x8 is
--    port (
--      clk  : in    std_logic;
--      ce   : in    std_logic;
--      we   : in    std_logic;
--      oe   : in    std_logic;
--      addr : in    std_logic_vector(7 downto 0);
--      data : inout std_logic_vector(7 downto 0));
--  end component mem_256x8;

--  signal we_sig_0 : std_logic := '0';
--  signal we_sig_1 : std_logic := '0';
--  signal we_sig_2 : std_logic := '0';
--  signal we_sig_3 : std_logic := '0';


--begin  -- architecture rtl

--  ram_bank_0 : mem_256x8 port map (
--    clk  => clk,
--    ce   => ce,
--    we   => we_sig_0,
--    oe   => oe,
--    addr => addr(9 downto 2),
--    data => data(31 downto 24));

--  ram_bank_1 : mem_256x8 port map (
--    clk  => clk,
--    ce   => ce,
--    we   => we_sig_1,
--    oe   => oe,
--    addr => addr(9 downto 2),
--    data => data(23 downto 16));

--  ram_bank_2 : mem_256x8 port map (
--    clk  => clk,
--    ce   => ce,
--    we   => we_sig_2,
--    oe   => oe,
--    addr => addr(9 downto 2),
--    data => data(15 downto 8));

--  ram_bank_3 : mem_256x8 port map (
--    clk  => clk,
--    ce   => ce,
--    we   => we_sig_3,
--    oe   => oe,
--    addr => addr(9 downto 2),
--    data => data(7 downto 0));

--  SEL_BANKS : process (byte_sel, we) is
--  begin
--    if byte_sel = "1111" and we = '1' then
--      we_sig_0 <= '1';
--      we_sig_1 <= '1';
--      we_sig_2 <= '1';
--      we_sig_3 <= '1';
--    elsif byte_sel = "1100" and we = '1'then
--      we_sig_0 <= '1';
--      we_sig_1 <= '1';
--      we_sig_2 <= '0';
--      we_sig_3 <= '0';
--    elsif byte_sel = "0011" and we = '1'then
--      we_sig_0 <= '0';
--      we_sig_1 <= '0';
--      we_sig_2 <= '1';
--      we_sig_3 <= '1';
--    elsif byte_sel = "1000" and we = '1'then
--      we_sig_0 <= '1';
--      we_sig_1 <= '0';
--      we_sig_2 <= '0';
--      we_sig_3 <= '0';
--    elsif byte_sel = "0100" and we = '1'then
--      we_sig_0 <= '0';
--      we_sig_1 <= '1';
--      we_sig_2 <= '0';
--      we_sig_3 <= '0';
--    elsif byte_sel = "0010" and we = '1' then
--      we_sig_0 <= '0';
--      we_sig_1 <= '0';
--      we_sig_2 <= '1';
--      we_sig_3 <= '0';
--    elsif byte_sel = "0001" and we = '1'then
--      we_sig_0 <= '0';
--      we_sig_1 <= '0';
--      we_sig_2 <= '0';
--      we_sig_3 <= '1';
--    else
--      we_sig_0 <= '0';
--      we_sig_1 <= '0';
--      we_sig_2 <= '0';
--      we_sig_3 <= '0';
--    end if;
--  end process SEL_BANKS;

--end architecture rtl;
