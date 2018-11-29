library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity signextend is
   port(isSigned : in std_logic;
      d : in std_logic_vector(15 downto 0);
      q : out std_logic_vector(31 downto 0) := (others => '0'));
end entity signextend;
 
architecture flip of signextend is

begin
   process (isSigned, d) is
   begin
		if(isSigned = '1') then
			q <= std_logic_vector(resize(signed(d), q'length));
		else
			q <= std_logic_vector(resize(unsigned(d), q'length));
		end if;
      
   end process;
end architecture flip;