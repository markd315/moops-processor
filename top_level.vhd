library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
  port (
	 input : in std_logic_vector(8 downto 0);
	 portSpec : in std_logic; --input9
	 clk      : in  std_logic;
	 inen      : in  std_logic; --btn1
	 reset   : in  std_logic; --btn2
    output  : out std_logic_vector(31 downto 0) := (others => '0'));
end entity;


architecture tl of top_level is

COMPONENT ctrler is
  port (
	 clk, rst    : in  std_logic;
	 en1, en2 : in std_logic;
	 OutPort : out std_logic_vector(31 downto 0);
	 inport1, inport2 : in std_logic_vector(31 downto 0));
END COMPONENT;

signal en1, en2 : std_logic;
signal inport1, inport2 : std_logic_vector(31 downto 0);

begin

en1 <= (not portSpec) and inen;
en2 <= portSpec and inen;

inport1 <= "00000000000000000000000" & input;
inport2 <= "00000000000000000000000" & input;

controller : ctrler port map(clk, reset, en1, en2, output, inport1, inport2);

end tl;
