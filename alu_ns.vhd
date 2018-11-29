library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_ns is
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


end alu_ns;

architecture logic of alu_ns is
constant nullsig : STD_LOGIC_vector(WIDTH-1 downto 0) := "00000000000000000000000000000000";
constant onesig : STD_LOGIC_vector(WIDTH-1 downto 0) := "00000000000000000000000000000001" ;
SIGNAL notsig : STD_LOGIC_vector(WIDTH-1 downto 0) ;
SIGNAL norsig : STD_LOGIC_vector(WIDTH-1 downto 0) ;
SIGNAL orsig : STD_LOGIC_vector(WIDTH-1 downto 0) ;
SIGNAL xorsig : STD_LOGIC_vector(WIDTH-1 downto 0) ;
SIGNAL andsig : STD_LOGIC_vector(WIDTH-1 downto 0) ;
SIGNAL nandsig : STD_LOGIC_vector(WIDTH-1 downto 0) ;
SIGNAL sumsig : STD_LOGIC_vector(WIDTH-1 downto 0) ;
SIGNAL subsig : STD_LOGIC_vector(WIDTH-1 downto 0) ;
SIGNAL leftsig, rightsig, srasig : STD_LOGIC_vector(WIDTH-1 downto 0);
SIGNAL smultsig : STD_LOGIC_vector(WIDTH -1 downto 0);
SIGNAL smultresult : signed(WIDTH + WIDTH - 1 downto 0);
SIGNAL umultsig : STD_LOGIC_vector(WIDTH -1 downto 0);
SIGNAL umultresult : unsigned(WIDTH + WIDTH - 1 downto 0);
SIGNAL sumresult : unsigned(WIDTH downto 0);
SIGNAL add_overflow : STD_LOGIC;
SIGNAL left_carry : STD_LOGIC;
SIGNAL right_carry : STD_LOGIC;
SIGNAL smult_carry, carry_any_zero, carry_any_one : STD_LOGIC;
SIGNAL umult_carry : STD_LOGIC;
SIGNAL usinput1, usinput2 : unsigned(WIDTH-1 downto 0);
SIGNAL sinput1, sinput2 : signed(WIDTH-1 downto 0);
SIGNAL shiftamt : natural;
	COMPONENT addergeneric
		generic (
            WIDTH : positive := 32
            );
		port(input1, input2 : in std_logic_vector(WIDTH-1 downto 0);
			carry_in : in std_logic;
			sum : out std_logic_vector(WIDTH-1 downto 0);
			carry_out : out std_logic);
	END COMPONENT ;
begin  -- STR
	shiftamt <= to_integer(unsigned(shift_amt));
	usinput1 <= unsigned(input1);
	usinput2 <= unsigned(input2);
	sinput1 <= signed(input1);
	sinput2 <= signed(input2);
	notsig <= not(input1);
	norsig <= not(input1 or input2);
	xorsig <= input1 xor input2;
	orsig <= input1 or input2;
	andsig <= input1 and input2;
	nandsig <= not(input1 and input2);
	subsig <= std_logic_vector(usinput1 - usinput2);
	left_carry <= input1(WIDTH-1);
	right_carry <= input1(0);
	leftsig <= std_logic_vector(SHIFT_LEFT(usinput1, shiftamt));
	rightsig <= std_logic_vector(SHIFT_RIGHT(usinput1, shiftamt));
	srasig <= std_logic_vector(SHIFT_RIGHT(sinput1, shiftamt));
	umultresult <= usinput1 * usinput2;
	umultsig <= std_logic_vector(umultresult(WIDTH-1 downto 0));
	smultresult <= signed(input1) * signed(input2);
	smultsig <= std_logic_vector(smultresult(WIDTH-1 downto 0));
	sumresult <= unsigned('0' & input1(WIDTH-1 downto 0)) + unsigned('0' & input2(WIDTH-1 downto 0));
	sumsig <= std_logic_vector(sumresult(WIDTH-1 downto 0));
	add_overflow <= std_logic(sumresult(WIDTH));
	process(smultresult)
	begin
		carry_any_zero <= '0';
		carry_any_one <= '0';
		for i in WIDTH-1 to WIDTH+WIDTH-1 loop
			if(smultresult(i) = '0') then
				carry_any_zero <= '1';
			else
				carry_any_one <= '1';
			end if;
		end loop;
	end process;
	smult_carry <= '1' when (carry_any_one = '1' and carry_any_zero = '1') else '0';
	process(umultresult)
	begin
		umult_carry <= '0';
		for i in WIDTH-1 to WIDTH+WIDTH-1 loop
			if(umultresult(i) = '1') then
				umult_carry <= '1';
			end if;
		end loop;
	end process;
	output <= xorsig when sel(5 downto 0) = "100110" else 
				orsig when sel(5 downto 0) = "100101" else 
				andsig when sel(5 downto 0) = "100100" else 
				sumsig when sel(5 downto 0) = "100001" else 
				subsig when sel(5 downto 0) = "100011" else 
				smultsig when sel(5 downto 0) = "011000" else 
				umultsig when sel(5 downto 0) = "011001" else 
				leftsig when sel(5 downto 0) = "000000" else 
				rightsig when sel(5 downto 0) = "000010" else 
				--those are logical shifts
				srasig when sel(5 downto 0) = "000011" else
				--that's an arithmetic
				onesig when ((sinput1 < sinput2) and sel = "101010") --slt signed
						or ((usinput1 < usinput2) and sel = "101011") --slt unsigned
				else nullsig;
	output_hi<=std_logic_vector(smultresult(WIDTH+WIDTH - 1 downto WIDTH)) when sel(5 downto 0) = "011000" else 
				std_logic_vector(umultresult(WIDTH+WIDTH - 1 downto WIDTH)) when sel(5 downto 0) = "011001"
				else nullsig;
	overflow <= add_overflow when sel(5 downto 0) = "100001" else 
				left_carry when sel(5 downto 0) = "000000" else 
				right_carry when sel(5 downto 0) = "000010" else 
				umult_carry when sel(5 downto 0) = "011001" else
			   smult_carry when sel(5 downto 0) = "011000" else 
				'0';
	branch_taken <= '1' when sel(5 downto 0) = "000110" and (sinput1 <= 0) else --blez
				'1' when sel(5 downto 0) = "000111" and (sinput1 > 0) else --bgtz
				'0';
end logic;