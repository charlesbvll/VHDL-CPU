library ieee;
use ieee.std_logic_1164.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is

component ROM_Block
    port(
        address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
end component;

signal s_q : std_logic_vector(31 downto 0);
signal s_read_and_cs : std_logic;

begin

    R: ROM_Block port map(
        address => address,
        clock => clk,
        q => s_q
    );

    process(clk)
    begin
    if(rising_edge(clk)) then
        s_read_and_cs <= read and cs;
    end if;
    end process;

    reading: process(s_read_and_cs, address, s_q)
    begin
        if (s_read_and_cs = '1') then
            rddata <= s_q;
        else
            rddata <= (others => 'Z');
        end if;
    end process;

end synth;
