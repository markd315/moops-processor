library ieee;
use ieee.std_logic_1164.all;

entity genmux is
  generic(
    WIDTH : natural);  -- Number of input bits
  port(
    A   : in  std_logic_vector(WIDTH-1 downto 0);
	 B   : in  std_logic_vector(WIDTH-1 downto 0);
	 Y   : out std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	 S   : in  std_logic := '0');
end entity;

architecture syn of genmux is
begin

Y <= B when (S = '1') else A;

end architecture;