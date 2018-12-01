library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end top_level_tb;

architecture TB of top_level_tb is

  signal clk    : std_logic := '1';
  signal input      : std_logic_vector(8 downto 0) := (others => '0');
  signal output : std_logic_vector(31 downto 0);
  signal portSpec, reset : std_logic := '0';
  signal inen : std_logic := '0';

begin

  UUT : entity work.top_level
    port map (
      clk    => clk,
		input       => input,
		portSpec => portSpec,
		inen => inen,
		reset => reset,
      output => output);

  process
  begin
  reset <= '1';
  reset <= '0';
  inen <= '1';
  input  <= "000000100"; --input1 = 4
  clk <= '0';
  wait for 120 ns;
  clk <= '1';
  wait for 120 ns;
  for l in 0 to 10 loop --cycle a few times to wipe the data lines
    clk <= std_logic(to_unsigned(l, 1)(0));
	 portSpec <= '1';
	 input  <= "000000010"; --input2 = 2
    wait for 120 ns;
  end loop;
 
    -- test all input combinations
	 for k in 0 to 1 loop
	  for j in 0 to 127 loop --try the first few input combos
			for l in 0 to 1023 loop --cycle 1024 times for each input to make it through some opcodes
          clk <= std_logic(to_unsigned(l, 1)(0));
			 inen<= '0';
			 --portSpec <= std_logic(to_unsigned(k, 1)(0));
			 --input  <= std_logic_vector(to_unsigned(j, 9));
          wait for 120 ns;
        end loop;
      end loop;
		end loop;

    report "SIMULATION FINISHED!";
    
    wait;

  end process;

end TB;
