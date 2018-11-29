library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Memory_tb is
end Memory_tb;

architecture TB of Memory_tb is

    component Memory
        port (
            baddr   : in  std_logic_vector(31 downto 0);
            dataIn   : in  std_logic_vector(31 downto 0);
				memRead, memWrite, clk : in  std_logic;
				InPort0_en, InPort1_en   : in  std_logic;
            InPort0_in, InPort1_in   : in  std_logic_vector(31 downto 0);
            OutPort   : out  std_logic_vector(31 downto 0);
            dataOut   : out std_logic_vector(31 downto 0)
            );

    end component;

    signal address   : std_logic_vector(31 downto 0) := (others => '0');
	 signal data, InPort0_in, InPort1_in   : std_logic_vector(31 downto 0) := (others => '0');
    signal clock, InPort0_en, InPort1_en   : std_logic := '0';
	 signal wren: std_logic := '0';
	 signal rden: std_logic := '0';
    signal q, OutPort   : std_logic_vector(31 downto 0);

begin  -- TB

    UUT : Memory
        port map (
            baddr => address,
				dataIn => data,
            clk => clock,
				memWrite => wren,
				memRead => rden,
				InPort0_en => InPort0_en,
				InPort1_en => InPort1_en,
				InPort0_in => InPort0_in,
				InPort1_in => InPort1_in,
				OutPort => OutPort,
            dataOut => q);
    process
    begin
        -- Write 0x0A0A0A0A to byte address 0x0000000
		  clock <= '0';
        address    <= conv_std_logic_vector(16#00000000#, address'length);
        data <= conv_std_logic_vector(16#0A0A0A0A#, data'length);
        wren <= '1';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  assert(q = conv_std_logic_vector(16#0A0A0A0A#, q'length)) report "Error : ramw = " severity warning;
		  
		  -- Write 0xF0F0F0F0 to byte address 0x00000004
		  clock <= '0';
        address    <= conv_std_logic_vector(16#00000004#, address'length);
        data <= conv_std_logic_vector(16#F0F0F0F0#, data'length);
        wren <= '1';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  assert(q = conv_std_logic_vector(16#F0F0F0F0#, q'length)) report "Error : ramw = " severity warning;
	 
	 -- Read from byte address 0x00000000 (should show 0x0A0A0A0A on read data output) 
		  clock <= '0';
        address    <= conv_std_logic_vector(16#00000000#, address'length);
        wren <= '0';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  assert(q = conv_std_logic_vector(16#0A0A0A0A#, q'length)) report "Error : ramrd = " severity warning;
	 
	 -- Read from byte address 0x00000001 (should show 0x0A0A0A0A on read data output)
		  clock <= '0';
        address    <= conv_std_logic_vector(16#00000001#, address'length);
        wren <= '0';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  assert(q = conv_std_logic_vector(16#0A0A0A0A#, q'length)) report "Error : ramrd = " severity warning;
	 
	 -- Read from byte address 0x00000004 (should show 0xF0F0F0F0 on read data output)
		  clock <= '0';
        address    <= conv_std_logic_vector(16#00000004#, address'length);
        wren <= '0';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  assert(q = conv_std_logic_vector(16#F0F0F0F0#, q'length)) report "Error : ramrd = " severity warning;
	 
	 --Read from byte address 0x00000005 (should show 0xF0F0F0F0 on read data output)
		  clock <= '0';
        address    <= conv_std_logic_vector(16#00000005#, address'length);
        wren <= '0';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  assert(q = conv_std_logic_vector(16#F0F0F0F0#, q'length)) report "Error : ramrd = " severity warning;
	 
	 -- Write 0x00001111 to the outport (should see value appear on outport)
		  clock <= '0';
        address    <= conv_std_logic_vector(16#0000FFFC#, address'length);
        data <= conv_std_logic_vector(16#00001111#, data'length);
        wren <= '1';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  assert(OutPort = conv_std_logic_vector(16#00001111#, OutPort'length)) report "Error : outw = " severity warning;
	 
	 --Load 0x00010000 into inport 0
		  clock <= '0';
        InPort0_in <= conv_std_logic_vector(16#00010000#, address'length);
        InPort0_en <= '1';
		  wren <= '1';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  InPort0_en <= '0';
    --Load 0x00000001 into inport 1
		  clock <= '0';
        InPort1_in <= conv_std_logic_vector(16#00000001#, address'length);
        InPort1_en <= '1';
		  wren <= '1';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  InPort1_en <= '0';
    --Read from inport 0 (should show 0x00010000 on read data output)
		  clock <= '0';
        address    <= conv_std_logic_vector(16#0000FFF8#, address'length);
        wren <= '0';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  assert(q = conv_std_logic_vector(16#00010000#, q'length)) report "Error : inrd = " severity warning;
	 
    --Read from inport 1 (should show 0x00000001 on read data output)
		  clock <= '0';
        address    <= conv_std_logic_vector(16#0000FFFC#, address'length);
        wren <= '0';
        wait for 120 ns;
        clock <= '1';
		  wait for 120 ns;
		  assert(q = conv_std_logic_vector(16#00000001#, q'length)) report "Error : inrd = " severity warning;
	 
	
        wait;

    end process;

	 rden <= not wren;


end TB;