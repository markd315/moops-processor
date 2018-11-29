library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bus_latch is
   generic(WIDTH : natural := 32);
   port
   (
      rst : in std_logic := '0';
		
		en : in std_logic := '1';
      
      d : in std_logic_vector(WIDTH-1 downto 0) := (others => '0');

      q : out std_logic_vector(WIDTH-1 downto 0) := (others => '0')
   );
end entity bus_latch;
 
architecture flip of bus_latch is
signal DATA: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
begin
   process (d, en, rst) is
   begin
		if(rst = '1') then
			DATA <= (others => '0');
		elsif (en = '1') then
			DATA <= d;
      end if;
   end process;
	q<= DATA;
end architecture flip;