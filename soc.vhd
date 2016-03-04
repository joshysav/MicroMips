library ieee;
use ieee.std_logic_1164.all;

entity soc is
  
  port (
    gpio_in  : in  std_logic_vector(31 downto 0);
    gpio_out : out std_logic_vector(31 downto 0);
    clk      : in  std_logic;
    rst      : in  std_logic);

end entity soc;

architecture arc of soc is

  component core is
    port (
      clk          : in  std_logic;
      rst          : in  std_logic;
      mem_read     : out std_logic;
      mem_write    : out std_logic;
      mem_data_in  : in  std_logic_vector(31 downto 0);
      mem_data_out : out std_logic_vector(31 downto 0);
      mem_addr     : out std_logic_vector(31 downto 0));
  end component core;

  component chip_selector is
    port(
      addr : in  std_logic_vector(15 downto 0);
      cs0  : out std_logic;
      cs1  : out std_logic;
      cs2  : out std_logic
      );
  end component chip_selector;

  component rom is
    port (
      chip_en : in  std_logic;
      read_en : in  std_logic;
      addr    : in  std_logic_vector(9 downto 0);
      data    : out std_logic_vector(31 downto 0));
  end component rom;

  component ram is
    port (
      chip_en  : in  std_logic;
      addr     : in  std_logic_vector(9 downto 0);
      data_in  : in  std_logic_vector(31 downto 0);
      read_en  : in  std_logic;
      write_en : in  std_logic;
      data_out : out std_logic_vector(31 downto 0));
  end component ram;

  signal mem_read_sig     : std_logic;
  signal mem_write_sig    : std_logic;
  signal mem_data_in_sig  : std_logic_vector(31 downto 0);
  signal mem_data_out_sig : std_logic_vector(31 downto 0);
  signal mem_addr_sig     : std_logic_vector(31 downto 0);

  signal cs0_sig : std_logic;
  signal cs1_sig : std_logic;
  signal cs2_sig : std_logic;

begin  -- architecture arc

  core_inst : core port map (
    clk          => clk,
    rst          => rst,
    mem_read     => mem_read_sig,
    mem_write    => mem_write_sig,
    mem_data_in  => mem_data_in_sig,
    mem_data_out => mem_data_out_sig,
    mem_addr     => mem_addr_sig);

  chip_selector_inst : chip_selector port map (
    addr => mem_addr_sig(15 downto 0),
    cs0  => cs0_sig,
    cs1  => cs1_sig,
    cs2  => cs2_sig);

  rom_inst : rom port map (
    chip_en => cs0_sig,
    read_en => mem_read_sig,
    addr    => mem_addr_sig(9 downto 0),
    data    => mem_data_in_sig);

  ram_inst : ram port map (
    chip_en  => cs1_sig,
    addr     => mem_addr_sig(9 downto 0),
    read_en  => mem_read_sig,
    data_in  => mem_data_out_sig,
    write_en => mem_write_sig,
    data_out => mem_data_in_sig);


end architecture arc;
