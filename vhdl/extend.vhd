library ieee;
use ieee.std_logic_1164.all;

entity extend is
    port(
        imm16  : in  std_logic_vector(15 downto 0);
        signed : in  std_logic;
        imm32  : out std_logic_vector(31 downto 0)
    );
end extend;

architecture synth of extend is
  signal s_vect_to_add : std_logic_vector(15 downto 0);

begin

  process(imm16, signed) is
    begin
    if (signed = '1') then
      s_vect_to_add <= (others => imm16(15));
    else
      s_vect_to_add <= (others => '0');
    end if;
  end process;

  imm32 <= s_vect_to_add & imm16;

end synth;
