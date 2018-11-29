library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bus_latch is
   port
   (
		en : in std_logic := '0';
      d : in std_logic_vector(31 downto 0);
      q : out std_logic_vector(31 downto 0) := (others => '0')
   );
end entity bus_latch;
 
architecture flip of bus_latch is
signal DATA : STD_LOGIC_VECTOR(31 downto 0);
begin
    DATA <= d when (en = '1') else DATA;
    q <= DATA;
end flip;