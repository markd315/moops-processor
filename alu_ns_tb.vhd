library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu_ns_tb is
end alu_ns_tb;

architecture TB of alu_ns_tb is

    component alu_ns

        generic (
            WIDTH : positive := 32
            );
        port (
            input1   : in  std_logic_vector(WIDTH-1 downto 0);
            input2   : in  std_logic_vector(WIDTH-1 downto 0);
            sel      : in  std_logic_vector(5 downto 0);
				shift_amt: in  std_logic_vector(4 downto 0);
            output   : out std_logic_vector(WIDTH-1 downto 0);
				output_hi   : out std_logic_vector(WIDTH-1 downto 0);
            overflow, branch_taken : out std_logic
            );

    end component;

    constant WIDTH  : positive                           := 32;
    signal input1   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal input2   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal sel      : std_logic_vector(5 downto 0)       := (others => '0');
	 signal shift_amt: std_logic_vector(4 downto 0)       := (others => '0');
    signal output   : std_logic_vector(WIDTH-1 downto 0);
    signal overflow, branch_taken : std_logic;

begin  -- TB

    UUT : alu_ns
        generic map (WIDTH => WIDTH)
        port map (
            input1   => input1,
            input2   => input2,
            sel      => sel,
				shift_amt      => shift_amt,
            output   => output,
				branch_taken  => branch_taken,
            overflow => overflow);

    process
    begin

        -- test 10+15 (no overflow)
        sel    <= "100001";
        input1 <= conv_std_logic_vector(10, input1'length);
        input2 <= conv_std_logic_vector(15, input2'length);
        wait for 120 ns;
        assert(output = conv_std_logic_vector(25, output'length)) report "Error : 10+15 = " & integer'image(conv_integer(output)) severity warning;
        assert(overflow = '0') report "Error                                   : overflow incorrect for 10+15" severity warning;

        -- test 25-10 (with overflow)
        sel    <= "100011";
        input1 <= conv_std_logic_vector(25, input1'length);
        input2 <= conv_std_logic_vector(10, input2'length);
        wait for 120 ns;
        assert(output = conv_std_logic_vector(15, output'length)) report "Error : 25+10 = " & integer'image(conv_integer(output)) severity warning;
        assert(overflow = '0') report "Error                                     : overflow incorrect for 25+10" severity warning;
        
		  -- test 10*(-4) signed
        sel    <= "011000";
        input1 <= conv_std_logic_vector(10, input1'length);
        input2 <= conv_std_logic_vector(-4, input2'length);
        wait for 120 ns;
        assert(output = conv_std_logic_vector(-40, output'length)) report "Error : -4*10 = " & integer'image(conv_integer(output)) severity warning;
        assert(overflow = '0') report "Error                                    : overflow incorrect for -4*10" severity warning;

        -- test 65536 * 131072 unsigned
        sel    <= "011001";
        input1 <= conv_std_logic_vector(65536, input1'length);
        input2 <= conv_std_logic_vector(131072, input2'length);
        wait for 120 ns;
        assert(output = conv_std_logic_vector(0, output'length)) report "Error : 65536*131072 = " & integer'image(conv_integer(output))  severity warning;
		  assert(overflow = '1') report "Error                                      : overflow incorrect for 64*64" severity warning;

		  -- test and
        sel    <= "100100";
        input1 <= conv_std_logic_vector(16#0000FFFF#, input1'length);
        input2 <= conv_std_logic_vector(16#FFFF1234#, input2'length);
        wait for 120 ns;
        assert(output = conv_std_logic_vector(16#00001234#, output'length)) report "Error : and= " & integer'image(conv_integer(output))  severity warning;
		  
		   -- test srl
        sel    <= "000010";
		  shift_amt    <= "00100";
        input1 <= conv_std_logic_vector(16#0000000F#, input1'length);
        wait for 120 ns;
        assert(output = conv_std_logic_vector(16#00000000#, output'length)) report "Error : srl= " & integer'image(conv_integer(output))  severity warning;
		  
		  -- Shift right arithmetic of 0xF0000008 by 1
        sel    <= "000011";
		  shift_amt    <= "00001";
        input1 <= conv_std_logic_vector(16#F0000008#, input1'length);
        wait for 120 ns;
        assert(output = conv_std_logic_vector(16#F8000004#, output'length)) report "Error : sra= " & integer'image(conv_integer(output))  severity warning;
		  
		  -- Shift right arithmetic of 0x00000008 by 1
        sel    <= "000011";
		  shift_amt    <= "00001";
        input1 <= conv_std_logic_vector(16#00000008#, input1'length);
        wait for 120 ns;
        assert(output = conv_std_logic_vector(16#00000004#, output'length)) report "Error : sra= " & integer'image(conv_integer(output))  severity warning;
		   
		  --Set on less than using 10 and 15 (for “set less than” instructions slt, slti, slu, and sltiu)
		  sel    <= "101010";
        input1 <= conv_std_logic_vector(10, input1'length);
		  input2 <= conv_std_logic_vector(15, input2'length);
        wait for 120 ns;
        assert(output = conv_std_logic_vector(1, output'length)) report "Error : slt= " & integer'image(conv_integer(output))  severity warning;
		  
		  --Set on less than using 15 and 10 (for “set less than” instructions slt, slti, slu, and sltiu)
		  sel    <= "101010";
        input1 <= conv_std_logic_vector(15, input1'length);
		  input2 <= conv_std_logic_vector(10, input2'length);
        wait for 120 ns;
        assert(output = conv_std_logic_vector(0, output'length)) report "Error : slt= " & integer'image(conv_integer(output))  severity warning;
		  
		  --Branch Taken output = ‘0’ for for 5 <= 0 (for blez instruction)
		  sel    <= "000110";
        input1 <= conv_std_logic_vector(5, input1'length);
        wait for 120 ns;
        assert(branch_taken = '0') report "Error : blez= " & integer'image(conv_integer(output))  severity warning;
		  
		  
		  
		  --Branch Taken output = ‘1’ for for 5 > 0 (for bgtz instruction)/
        sel    <= "000111";
        input1 <= conv_std_logic_vector(5, input1'length);
        wait for 120 ns;
        assert(branch_taken = '1') report "Error : bgtz= " & integer'image(conv_integer(output))  severity warning;
		  
        wait;

    end process;



end TB;