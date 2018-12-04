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
	 led0 : out std_logic_vector(6 downto 0);
	 led1 : out std_logic_vector(6 downto 0);
	 led2 : out std_logic_vector(6 downto 0);
	 led3 : out std_logic_vector(6 downto 0);
	 led4 : out std_logic_vector(6 downto 0);
	 led5 : out std_logic_vector(6 downto 0);
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

component decoder7seg is
    port (
        input  : in  std_logic_vector(3 downto 0);
        output : out std_logic_vector(6 downto 0));
end component;

signal en1, en2 : std_logic;
signal inport1, inport2, outputbits : std_logic_vector(31 downto 0);

begin

en1 <= (not portSpec) and inen;
en2 <= portSpec and inen;

inport1 <= "00000000000000000000000" & input;
inport2 <= "00000000000000000000000" & input;

controller : ctrler port map(clk, reset, en1, en2, outputbits, inport1, inport2);

decoder0 : decoder7seg port map(outputbits(3 downto 0), led0);
decoder1 : decoder7seg port map(outputbits(7 downto 4), led1);
decoder2 : decoder7seg port map (outputbits(11 downto 8), led2);
decoder3 : decoder7seg port map(outputbits(15 downto 12), led3);
decoder4 : decoder7seg port map(outputbits(19 downto 16), led4);
decoder5 : decoder7seg port map(outputbits(23 downto 20), led5);

end tl;
