library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ALUcontroller is
   port(ALUOp : in std_logic_vector(1 downto 0);
		fn : in std_logic_vector(5 downto 0);
		Opcode : in std_logic_vector(5 downto 0);
		OpSelect : out std_logic_vector(5 downto 0);
		ALU_LO_HI : out std_logic_vector(1 downto 0) := "00";
		HI_en, LO_en : out std_logic := '0');
end entity ALUcontroller;
 
architecture flip of ALUcontroller is

begin
   process (ALUOp, fn, Opcode) is
   begin
		HI_en <= '0';
		LO_en <= '0';
		if(ALUOp = "00") then --for address calculation
			OpSelect<= "100001";
		elsif(Opcode = "000000") then --this is an rtype, just send the function
			OpSelect<=fn;
		elsif(Opcode = "001001") then --for immediate addition
			OpSelect<= "100001";
		elsif(Opcode = "010000") then --for immediate subtration
			OpSelect<= "100011";
		elsif(Opcode = "001100") then --for immediate and
			OpSelect<= "100100";
		elsif(Opcode = "001101") then --for immediate or
			OpSelect<= "100101";
		elsif(Opcode = "001110") then --for immediate xor
			OpSelect<= "100110";
		elsif(Opcode = "001101") then --for immediate or
			OpSelect<= "100101";
		else
			OpSelect<=fn;
		end if;

		
		if(fn = "011000" or fn="011001") then --0x18/0x19 are multiply
			HI_en <= '1';
			LO_en <= '1';
		end if;
		
		if(fn = "010000")  then --0x10/0x12 
			ALU_LO_HI <= "10";--hi
		elsif (fn="010010") then
			ALU_LO_HI <= "01";--lo
		else
			ALU_LO_HI <= "00"; --default result
		end if;
		
		--If ALUOp is 00, do addition for memaddr calculation or PC+4 (add immediate) 0x21
		--If ALUOp is 01, this is a branch instruction (ignore)
		
   end process;
end architecture flip;