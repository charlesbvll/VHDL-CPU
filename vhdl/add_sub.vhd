library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is

signal temp: std_logic_vector(32 downto 0);
signal signal_for_xor : std_logic_vector(31 downto 0);

begin

process (a, b, sub_mode, signal_for_xor, temp)
  begin

      if (sub_mode = '1') then
        signal_for_xor <= (31 downto 0 => '1');
        temp <= std_logic_vector(unsigned('0' & (b xor signal_for_xor)) + 1 + unsigned('0' & a));
      else
        temp <= std_logic_vector(unsigned('0' & b) + unsigned('0' & a));
      end if;

      if (temp(31 downto 0)=X"00000000") then
        zero <= '1';
      else
        zero <= '0';
      end if;

      r <= temp(31 downto 0);
      carry <= temp(32);
  end process;



end synth;
