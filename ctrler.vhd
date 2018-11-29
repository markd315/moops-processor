library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrler is
  port (
	 clk, rst    : in  std_logic;
	 en1, en2 : in std_logic;
	 OutPort : out std_logic_vector(31 downto 0) := (others => '0');
	 inport1, inport2 : in std_logic_vector(31 downto 0));
end entity;


architecture FSM of ctrler is

COMPONENT datapath
		port (
				PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemToReg, IRWrite, JumpAndLink, IsSigned, ALUSrcA, RegWrite, RegDst, HILO_clk : in  std_logic;
				PCSource, ALUSrcB : in std_logic_vector(1 downto 0);
				InPort0_en, InPort1_en   : in  std_logic;
            InPort0_in, InPort1_in   : in  std_logic_vector(31 downto 0);
				clk, rst   : in  std_logic;
				controllerIR   : out  std_logic_vector(5 downto 0);
            OutPort   : out  std_logic_vector(31 downto 0));
END COMPONENT ;

TYPE State_type IS (iFetchRead, iFetchInc, iDecode, memAddr, memAccessR, memAccessW, readComplete, exec, rComplete, rWrite, branchComplete, jumpComplete);  -- Define the states
	SIGNAL state : State_Type;    -- Create a signal that uses 
signal PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemToReg, IRWrite, JumpAndLink, IsSigned, ALUSrcA, RegWrite, RegDst, HILO_clk : std_logic := '0';
signal PCSource, ALUSrcB, ALUOp : std_logic_vector(1 downto 0) := "00";
signal InPort0_en, InPort1_en, iSub, isIType :  std_logic := '0';
signal InPort0_in, InPort1_in :  std_logic_vector(31 downto 0);
signal controllerIR : std_logic_vector(5 downto 0);

begin  
--todo implement datapath wiring
dp : entity work.datapath(logic)
        port map (
            PCWriteCond => PCWriteCond,
				PCWrite => PCWrite,
				IorD => IorD,
				MemRead => MemRead,
				MemWrite => MemWrite,
				MemToReg => MemToReg,
				IRWrite => IRWrite,
				JumpAndLink => JumpAndLink,
				IsSigned => IsSigned,
				ALUSrcA => ALUSrcA,
				RegWrite => RegWrite,
				RegDst => RegDst,
				HILO_clk => HILO_clk,
				PCSource => PCSource,
				ALUSrcB => ALUSrcB,
				InPort0_en => InPort0_en,
				InPort1_en => InPort1_en,
				InPort0_in => InPort0_in,
				InPort1_in => InPort1_in,
				clk => clk,
				rst => rst,
				ALUOp => ALUOp,
				controllerIR => controllerIR,
				OutPort => OutPort);
				
iSub <= '1' WHEN controllerIR="010000" ELSE '0';--bullshit stray subtract Itype
isIType <= (controllerIR(3) or iSub); --most Itypes
				
process(clk, rst)
begin
if (rst = '1') then            -- Upon reset
	state <= iFetchRead;
elsif(clk'event and clk = '1') then
case state is
		WHEN iFetchRead => 
			state <= iFetchInc;
			
		WHEN iFetchInc => 
			state <= iDecode;
 
		WHEN iDecode => 
			IF controllerIR(5)='1' THEN --msb implies sw/lw
				state <= memAddr; 
			ELSIF controllerIR(3)='1' THEN
				state <= exec; --0x08 bit implies rType (immediate opcodes)
			ELSIF controllerIR(5 downto 0)="000011" or controllerIR(5 downto 0)="000010" THEN
				state <= jumpComplete; --0x2 / 0x3
			ELSIF controllerIR(5 downto 0)="010000" THEN
				state <= exec; --for nonmips sub immediate unsigned
			ELSIF controllerIR(5 downto 0)="000000" THEN
				state <= exec; --for non-immediate rTypes
			ELSE
				state <= branchComplete; --0x00 to 0x07 not covered yet
			END IF; 
			
		WHEN memAddr => --0x2? is implied already
			IF controllerIR(3 downto 0)="0011" THEN --load 0011
				state <= memAccessR;
			ELSE
				state <= memAccessW; --"1011"
			END IF; 
 
		WHEN memAccessR => 
			state <= readComplete;
		WHEN memAccessW => 
			state <= readComplete;
		WHEN exec => 
			state <= rComplete;
		WHEN rComplete => 
			state <= rWrite;
		WHEN branchComplete => 
			state <= readComplete;
		WHEN jumpComplete => 
			state <= readComplete;
		WHEN rWrite => 
			state <= iFetchRead;
		WHEN readComplete => 
			state <= iFetchRead;
		WHEN others =>
			state <= iFetchRead;
	END CASE; 
end if;
end process;
MemRead <= '1' WHEN (state=iFetchRead or state=memAddr) ELSE '0';
MemWrite <= '1' WHEN (state=memAccessW) ELSE '0';
ALUSrcA <= '1' WHEN (state=memAddr or state=rComplete or state=branchComplete) ELSE '0';
ALUSrcB <= "01" WHEN (state=iFetchRead) ELSE 
				"00" WHEN state=branchComplete ELSE
				"10" WHEN (state=rComplete and isIType='1') ELSE 
				"10" WHEN (state=memAddr or state=iDecode) ELSE
				"00";
IorD <= '1' WHEN state=memAddr or state=iFetchInc ELSE '0';
IRWrite <= '1' WHEN (state=iFetchInc) ELSE '0';
PCWrite <= '1' WHEN (state=iFetchInc or state=jumpComplete) ELSE '0';
ALUOp <= "01" WHEN (state=branchComplete) ELSE "10" WHEN (state=rComplete) ELSE "00";
PCSource <= "01" WHEN (state=branchComplete or state=iFetchInc) ELSE "10" WHEN (state=jumpComplete) ELSE "00";
PCWriteCond <= '1' WHEN (state=branchComplete) ELSE '0';
RegDst <= '1' WHEN (state=rComplete or (state=rWrite and isIType='0')) ELSE '0';
RegWrite <= '1' WHEN (state=readComplete or state=rWrite) ELSE '0';
MemToReg <= '0' WHEN (state=rWrite) ELSE '1';
HILO_clk <= '1' WHEN (state=rComplete) ELSE '0';
InPort0_en <= en1;
InPort1_en <= en2;
InPort0_in <= inport1;
InPort1_in <= inport2;
end FSM;
