library ieee;
use ieee.std_logic_1164.all;

entity soc is
  
  port (
    gpio_in  : in  std_logic_vector(7 downto 0);
    gpio_out : out std_logic_vector(7 downto 0);
    clk      : in  std_logic;
    rst      : in  std_logic);

end entity soc;

architecture arc of soc is

  -- -----------------------------------------------------------------
  -- COMPONENT DEFINITIONS
  -- ----------------------------------------------------------------
  component chip_selector is
    port(
      addr : in  std_logic_vector(15 downto 0);
      cs0  : out std_logic;
      cs1  : out std_logic;
      cs2  : out std_logic;
      cs3  : out std_logic;
      cs4  : out std_logic);
  end component chip_selector;

  component clock_unit is
    port (
      clk_ext : in  std_logic;
      clk_out : out std_logic;
      cs      : in  std_logic;
      re      : in  std_logic;
      we      : in  std_logic;
      addr    : in  std_logic_vector(15 downto 0);
      data    : in  std_logic_vector(31 downto 0));
  end component clock_unit;

  component core is
    port (
      clk       : in    std_logic;
      rst       : in    std_logic;
      mem_read  : out   std_logic;
      mem_write : out   std_logic;
      mem_data  : inout std_logic_vector(31 downto 0);
      mem_addr  : out   std_logic_vector(31 downto 0));
  end component core;

  component rom is
    port (
      ce       : in  std_logic;
      oe       : in  std_logic;
      byte_sel : in  std_logic_vector(3 downto 0);
      addr     : in  std_logic_vector(15 downto 0);
      data_out : out std_logic_vector(31 downto 0));
  end component rom;

  component ram is
    port (
      clk      : in    std_logic;
      ce       : in    std_logic;
      oe       : in    std_logic;
      we       : in    std_logic;
      byte_sel : in    std_logic_vector(3 downto 0);
      addr     : in    std_logic_vector(15 downto 0);
      data     : inout std_logic_vector(31 downto 0));
  end component ram;

  -- ------------------------------------------------------------------
  -- INTERNAL SIGNALS
  -- ------------------------------------------------------------------
  signal addr_bus_s    : std_logic_vector(31 downto 0);  -- CPU to BUS Data
  signal data_bus_s    : std_logic_vector(31 downto 0);  -- CPU to BUS Addr
  signal we_bus_s      : std_logic;     -- CPU tu BUS Write Enable
  signal re_bus_s      : std_logic;     -- CPU to BUS Read Enable
  signal cs_clk_unit_s : std_logic;     -- Chip Sel for CLOCK UNIT 
  signal cs_rom_s      : std_logic;
  signal cs_ram_s      : std_logic;
  signal cs_gpio_out_s : std_logic;
  signal cs_gpio_in_s  : std_logic;
  signal sys_clk_s     : std_logic;     -- System Clock
  
begin  -- architecture arc

  chip_sel : chip_selector port map (
    addr => addr_bus_s(15 downto 0),
    cs0  => cs_rom_s,
    cs1  => cs_ram_s,
    cs2  => cs_gpio_out_s,
    cs3  => cs_gpio_in_s,
    cs4  => cs_clk_unit_s);
  
  clk_unit : clock_unit port map (
    clk_ext => clk,
    clk_out => sys_clk_s,
    cs      => cs_clk_unit_s,
    re      => re_bus_s,
    we      => we_bus_s,
    addr    => addr_bus_s(15 downto 0),
    data    => data_bus_s);

  core_inst : core port map (
    clk       => sys_clk_s,
    rst       => rst,
    mem_read  => re_bus_s,
    mem_write => we_bus_s,
    mem_data  => data_bus_s,
    mem_addr  => addr_bus_s);

  rom_inst : rom port map (
    ce       => cs_rom_s,
    oe       => re_bus_s,
    byte_sel => "1111",
    addr     => addr_bus_s(15 downto 0),
    data_out => data_bus_s);

  ram_inst : ram port map (
    clk      => sys_clk_s,
    ce       => cs_ram_s,
    oe       => re_bus_s,
    we       => we_bus_s,
    byte_sel => "1111",
    addr     => addr_bus_s(15 downto 0),
    data     => data_bus_s);


end architecture arc;
