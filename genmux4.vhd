 library ieee;
use ieee.std_logic_1164.all;

entity genmux4 is
  generic(
    WIDTH : natural := 32);  -- Number of input bits
  port(
    A, B, C, D   : in  std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	 Y   : out std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	 S   : in  std_logic_vector(1 downto 0) := "00");
end entity;

architecture syn of genmux4 is
begin

Y <= A when (S = "00")
     else B when (S = "01")
	  else C when (S = "10")
	  else D;

end architecture;