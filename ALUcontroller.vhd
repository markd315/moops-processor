library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ALUcontroller is
   port(ALUOp : in std_logic_vector(1 downto 0);
		IR : in std_logic_vector(5 downto 0);
		OpSelect : out std_logic_vector(5 downto 0);
		ALU_LO_HI : out std_logic_vector(1 downto 0) := "00";
		HI_en, LO_en : out std_logic := '0');
end entity ALUcontroller;
 
architecture flip of ALUcontroller is

begin
   process (ALUOp, IR) is
   begin
		if(ALUOp = "00") then
			OpSelect<= "100001";
		else
			OpSelect<=IR;
		end if;
		
		if(IR = "011000" or IR="011001") then --0x18/0x19 
			HI_en <= '1';
		else
			HI_en <= '0';
		end if;
		
		if(IR = "010000")  then --0x10/0x12 
			ALU_LO_HI <= "10";--hi
		elsif (IR="010010") then
			ALU_LO_HI <= "01";--lo
		else
			ALU_LO_HI <= "00"; --default result
		end if;
		
		--If ALUOp is 00, do addition for memaddr calculation or PC+4 (add immediate) 0x21
		--If ALUOp is 01, this is a branch instruction (ignore)
		
   end process;
end architecture flip;