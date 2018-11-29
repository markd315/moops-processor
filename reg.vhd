library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
   generic(WIDTH : natural := 32);
   port
   (
      clk : in std_logic;

      rst : in std_logic := '0';
		
		en : in std_logic := '1';
      
      d : in std_logic_vector(WIDTH-1 downto 0) := (others => '0');

      q : out std_logic_vector(WIDTH-1 downto 0) := (others => '0')
   );
end entity reg;
 
architecture flip of reg is
signal DATA: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
begin
   process (clk, en, rst) is
   begin
		if(rst = '1') then
			DATA <= (others => '0');
		elsif (clk'event and clk = '1' and en = '1') then  
			DATA <= d;
      end if;
   end process;
	q<= DATA;
end architecture flip;