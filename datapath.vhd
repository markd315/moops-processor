library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity datapath is
        port (
				PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemToReg, IRWrite, JumpAndLink, IsSigned, ALUSrcA, RegWrite, RegDst, HILO_clk : in  std_logic := '0';
				PCSource, ALUSrcB, ALUOp : in std_logic_vector(1 downto 0):= (others => '0');
				InPort0_en, InPort1_en   : in  std_logic;
            InPort0_in, InPort1_in   : in  std_logic_vector(31 downto 0):= (others => '0');
				clk, rst   : in  std_logic;
				controllerIR   : out  std_logic_vector(5 downto 0):= (others => '0');
            OutPort   : out  std_logic_vector(31 downto 0) := (others => '0'));
end datapath;

architecture logic of datapath is
component registerfile port(clk : in std_logic;
        rst : in std_logic;
        rd_addr0 : in std_logic_vector(4 downto 0) := "00000"; --read reg 1
        rd_addr1 : in std_logic_vector(4 downto 0) := "00000"; --read reg 2
        wr_addr : in std_logic_vector(4 downto 0); --write register
        wr_en : in std_logic;
        wr_data : in std_logic_vector(31 downto 0); --write data
        rd_data0 : out std_logic_vector(31 downto 0); --read data 1
        rd_data1 : out std_logic_vector(31 downto 0); --read data 2
		  --JAL
		  PC_4 : in std_logic_vector(31 downto 0);
		  JumpAndLink : in std_logic);
end component;
component reg generic(WIDTH : natural := 32);
			port(clk : in std_logic;
				en : in std_logic := '1';
				rst : in std_logic := '0';
				d : in std_logic_vector(31 downto 0);
				q : out std_logic_vector(31 downto 0));
end component;
component bus_latch
   port
   (
      en : in std_logic;
      
      d : in std_logic_vector(31 downto 0);

      q : out std_logic_vector(31 downto 0)
   );
end component;
component signextend port(d : in std_logic_vector(15 downto 0);
		isSigned : in std_logic;
      q : out std_logic_vector(31 downto 0));
end component;
component genmux4
generic(
    WIDTH : natural);  -- Number of input bits
  port(
    A, B, C, D   : in  std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	 Y   : out std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	 S   : in  std_logic_vector(1 downto 0) := "00");
end component;
component genmux
generic(
    WIDTH : natural);  -- Number of input bits
  port(
    A, B   : in  std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	 Y   : out std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	 S   : in  std_logic := '0');
end component;
component ALUcontroller
	port(ALUOp : in std_logic_vector(1 downto 0);
		fn : in std_logic_vector(5 downto 0);
		Opcode : in std_logic_vector(5 downto 0);
		OpSelect : out std_logic_vector(5 downto 0);
		ALU_LO_HI : out std_logic_vector(1 downto 0);
		HI_en, LO_en : out std_logic);
end component;

component alu_ns generic (WIDTH : positive := 32);
        port (
            input1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
            input2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
            sel      : in  std_logic_vector(5 downto 0);
				shift_amt: in  std_logic_vector(4 downto 0);
            output, output_hi   : out std_logic_vector(WIDTH-1 downto 0);
            overflow, branch_taken : out std_logic);
end component;

--component pathController
--port(clk : in std_logic;
  --    rst : in std_logic;
    --  d : in std_logic_vector(31 downto 0);
      --q : out std_logic_vector(31 downto 0)); --todo
--end component;
component Memory port (baddr   : in  std_logic_vector(31 downto 0);
            dataIn   : in  std_logic_vector(31 downto 0);
				memRead, memWrite, clk, rst : in  std_logic;
				InPort0_en, InPort1_en   : in  std_logic;
            InPort0_in, InPort1_in   : in  std_logic_vector(31 downto 0);
            OutPort   : out  std_logic_vector(31 downto 0);
            dataOut   : out std_logic_vector(31 downto 0));
end component;

SIGNAL regA, regB, PCmuxout, IRandMDRin, IRout, input1, input2, signextended, shiftedleft, IRconcatenated : STD_LOGIC_vector(31 downto 0) := (others => '0');
SIGNAL pcSourceOut, AregMemMuxIn, ALUout, MDRout, WRdata, HILOmuxOut, rd_data0, rd_data1, ALUreg, LOout, HIout, result_hi : STD_LOGIC_vector(31 downto 0) := (others => '0');
SIGNAL WRreg : STD_LOGIC_vector(4 downto 0) := (others => '0');
SIGNAL OpSelect : STD_LOGIC_vector(5 downto 0) := (others => '0');
SIGNAL ALU_LO_HI : STD_LOGIC_vector(1 downto 0) := (others => '0');
SIGNAL HI_en, LO_en, PC_en, branch_taken, lo_wr, hi_wr, iSub, isIType: STD_LOGIC := '0';
constant const4 : STD_LOGIC_vector(31 downto 0) := "00000000000000000000000000000100";

begin  -- STR

Memmy : Memory
        port map (
            baddr => PCmuxout,
				dataIn => regB,
            clk => clk,
				rst => rst,
            memRead => MemRead,
				memWrite => MemWrite,
				InPort0_en => InPort0_en,
				InPort0_in => InPort0_in,
				InPort1_en => InPort1_en,
				InPort1_in => InPort1_in,
				OutPort => OutPort,
            dataOut => IRandMDRin);
PClatch : bus_latch
			port map(en=>PC_en,
			d=>pcSourceOut,
			q=>AregMemMuxIn);
			
PCmux : genmux generic map(WIDTH=> 32)
			port map(A=>AregMemMuxIn,
			B=>ALUout,
			S=>IorD,
			Y=>PCmuxout);
			
--latch bc IRandMDRin was avail by instruction decode, but not IRout
IR : reg
			generic map(WIDTH=>32)
			port map(clk=>clk,
			en=>IRwrite,
			rst=>rst,
			d=>IRandMDRin,
			q=>IRout);
MDR : reg
			generic map(WIDTH=>32)
			port map(clk=>clk,
			rst=>rst,
			d=>IRandMDRin,
			q=>MDRout);
			
WRregMux : genmux generic map(WIDTH=> 5)
			port map(A=>IRout(20 downto 16),
			B=>IRout(15 downto 11),
			S=>RegDst,
			Y=>WRreg);

WRdataMux : genmux generic map(WIDTH=> 32)
			port map(A=>HILOmuxOut,
			B=>MDRout,
			S=>MemToReg,
			Y=>WRdata);
			
reggiefile : registerfile port map(clk=>clk,
        rst=>rst,
        rd_addr0=>IRout(25 downto 21),
        rd_addr1=>IRout(20 downto 16),
        wr_addr=>WRreg,
        wr_en=>RegWrite,
        wr_data=>WRdata,
        rd_data0=>rd_data0,
        rd_data1=>rd_data1,
		  PC_4 => PCmuxout,--?
		  JumpAndLink=>JumpAndLink);
			
signextender : signextend port map(d=>IRout(15 downto 0),
			isSigned=>isSigned,
			q=>signextended);			
			
registerA : reg
			generic map(WIDTH=>32)
			port map(clk=>clk,
			d=>rd_data0,
			rst=>rst,
			q=>regA);
			
registerB : reg
			generic map(WIDTH=>32)
			port map(clk=>clk,
			d=>rd_data1,
			q=>regB);
			
input1mux : genmux generic map(WIDTH=> 32)
			port map(A=>AregMemMuxIn,
			B=>regA,
			S=>ALUSrcA,
			Y=>input1);		
input2mux : genmux4 generic map(WIDTH=> 32)
			port map(A=>regB,
			B=>const4,
			C=>signextended,
			D=>shiftedleft,
			S=>ALUSrcB,
			Y=>input2);
ALU : alu_ns generic map(WIDTH=>32)
        port map(
            input1=>input1,
            input2=>input2,
            sel=>OpSelect,
				shift_amt=>IRout(10 downto 6),
            output=>ALUout,
            output_hi=> result_hi,
				branch_taken=>branch_taken);
				
alucard : ALUcontroller	port map(ALUOp=> ALUOp,
		fn=>IRout(5 downto 0),
		Opcode=>IRout(31 downto 26),
		OpSelect=>OpSelect,
		ALU_LO_HI=>ALU_LO_HI,
		HI_en=>HI_en, 
		LO_en=>LO_en);
			
ALUoutReg : reg
			generic map(WIDTH=>32)
			port map(clk=>clk,
			d=>ALUout,
			rst=>rst,
			q=>ALUreg);
			
lo_wr <= (LO_en and HILO_clk); --Only update these during a multiply in rComplete state
hi_wr <= (HI_en and HILO_clk);

LOReg : reg
			generic map(WIDTH=>32)
			port map(clk=>clk,
			d=>ALUout,
			en=>lo_wr,
			q=>LOout);			
HIReg : reg
			generic map(WIDTH=>32)
			port map(clk=>clk,
			d=>result_hi,
			en=>hi_wr,
			rst=>rst,
			q=>HIout);
				
HILOmux : genmux4 generic map(WIDTH=> 32)
			port map(A=>ALUreg,
			B=>LOout,
			C=>HIout,
			D=>HIout,
			S=>ALU_LO_HI,
			Y=>HILOmuxOut);
			
PCsourceMux : genmux4 generic map(WIDTH=> 32)
			port map(A=>ALUout,
			B=>ALUreg,
			C=>IRconcatenated,
			D=>IRconcatenated,
			S=>PCSource,
			Y=>pcSourceOut);
			
IRconcatenated <= AregMemMuxIn(31 downto 28) & AregMemMuxIn(25 downto 0) & "00";
shiftedleft <= signextended(29 downto 0) & "00";
controllerIR <= IRout(31 downto 26);
iSub <= '1' WHEN IRout(31 downto 26)="010000" ELSE '0';--bullshit stray subtract Itype
isIType <= (IRout(29) or iSub); --most Itypes
PC_en <= (branch_taken and PCWriteCond) or PCWrite;
end logic;