library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is

  type ram_type is array(0 to 1023) of std_logic_vector(31 downto 0);
  signal memory: ram_type;
  signal s_address_latency : std_logic_vector(9 downto 0);
  signal s_read_and_cs : std_logic;

begin

  process(clk)
  begin
  if(rising_edge(clk)) then
    s_address_latency <= address;
    s_read_and_cs <= read and cs;
  end if;
  end process;

  reading: process(s_read_and_cs, s_address_latency, memory)
  begin
    if (s_read_and_cs = '1') then
        rddata <= memory(to_integer(unsigned(s_address_latency)));
    else
        rddata <= (others => 'Z');
    end if;
  end process;

  writing: process(clk)
  begin
    if (rising_edge(clk)) then
        if ((write and cs) = '1') then
            memory(to_integer(unsigned(address))) <= wrdata;
        end if;
    end if;
  end process;
end synth;
