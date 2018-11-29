library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity Memory is
        port (
            baddr   : in  std_logic_vector(31 downto 0) := (others => '0');
            dataIn   : in  std_logic_vector(31 downto 0) := (others => '0');
				memRead, memWrite, clk, rst : in  std_logic;
				InPort0_en, InPort1_en   : in  std_logic := '0';
            InPort0_in, InPort1_in   : in  std_logic_vector(31 downto 0) := (others => '0');
            OutPort   : out  std_logic_vector(31 downto 0) := (others => '0');
            dataOut   : out std_logic_vector(31 downto 0) := (others => '0')
            );
end Memory;

architecture logic of Memory is
SIGNAL InPort0_out, InPort1_out, q : STD_LOGIC_vector(31 downto 0) := (others => '0');
SIGNAL Outport_addr_true, legal_write : std_logic := '0';


component LARams
        PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;
component bus_latch
   port
   (
      en : in std_logic;
      
      d : in std_logic_vector(31 downto 0);

      q : out std_logic_vector(31 downto 0)
   );
end component;

begin  -- STR

Inport0 : bus_latch
        port map (
            en => InPort0_en,
				d => InPort0_in,
            q => InPort0_out);
				
Inport1 : bus_latch
        port map (
            en => InPort1_en,
				d => InPort1_in,
            q => InPort1_out);

Outputport : bus_latch
        port map (
            en => Outport_addr_true,
				d => dataIn,
            q => OutPort);
				
				
legal_write <= '0' when baddr = conv_std_logic_vector(16#0000FFF8#, baddr'length) else --prevent writing to inport with the matching address
					'0' when baddr = conv_std_logic_vector(16#0000FFF9#, baddr'length) else
					'0' when baddr = conv_std_logic_vector(16#0000FFFA#, baddr'length) else
					'0' when baddr = conv_std_logic_vector(16#0000FFFB#, baddr'length) else
					'0' when baddr = conv_std_logic_vector(16#0000FFFC#, baddr'length) else
					'0' when baddr = conv_std_logic_vector(16#0000FFFD#, baddr'length) else
					'0' when baddr = conv_std_logic_vector(16#0000FFFE#, baddr'length) else
					'0' when baddr = conv_std_logic_vector(16#0000FFFF#, baddr'length) else
					'1' when memWrite = '1'  and memRead = '0'
							else '0';			
Rammy : LARams
        port map (
            address => baddr(9 downto 2),
            clock => clk,
            data => dataIn,
				wren => legal_write,
            q => q);
				
Outport_addr_true <= '1' when baddr=conv_std_logic_vector(16#0000FFFC#, baddr'length) else
							'1' when baddr=conv_std_logic_vector(16#0000FFFD#, baddr'length) else
							'1' when baddr=conv_std_logic_vector(16#0000FFFE#, baddr'length) else
							'1' when baddr=conv_std_logic_vector(16#0000FFFF#, baddr'length)
							else '0';
				
dataOut <= InPort0_out when baddr = conv_std_logic_vector(16#0000FFF8#, baddr'length) else
			  InPort0_out when baddr = conv_std_logic_vector(16#0000FFF9#, baddr'length) else
			  InPort0_out when baddr = conv_std_logic_vector(16#0000FFFA#, baddr'length) else
			  InPort0_out when baddr = conv_std_logic_vector(16#0000FFFB#, baddr'length) else
			  InPort1_out when baddr = conv_std_logic_vector(16#0000FFFC#, baddr'length) else
			  InPort1_out when baddr = conv_std_logic_vector(16#0000FFFD#, baddr'length) else
			  InPort1_out when baddr = conv_std_logic_vector(16#0000FFFE#, baddr'length) else
			  InPort1_out when baddr = conv_std_logic_vector(16#0000FFFF#, baddr'length)
			  else q;
				

end logic;