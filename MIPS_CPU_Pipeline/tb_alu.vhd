library ieee;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu is
end tb_alu;

architecture testbench of tb_alu is

	constant CLOCK_PERIOD  : time := 10 ns;
	constant buswidth : integer := 32;


	signal SIGdataA            : std_logic_vector(buswidth-1 downto 0);
	signal SIGdataB            : std_logic_vector(buswidth-1 downto 0);
    signal SIGaluControl       : std_logic_vector(3 downto 0);
    signal SIGdataOut          : std_logic_vector(buswidth-1 downto 0);
    signal clock               : std_logic;
    signal SIGnegFlag, SIGzeroFlag : std_logic;
	
	component alu 
		generic (constant buswidth: integer := 32);
		Port ( dataA : in std_logic_vector(31 downto 0);
			   dataB : in std_logic_vector(31 downto 0);
		       aluControl : in std_logic_vector(3 downto 0);
		       dataOut : out std_logic_vector(31 downto 0);
		       zeroFlag : out std_logic;
		       --ovfFlag : out std_logic;
		       negFlag : out std_logic);
    end component;

begin

-- instantiate an instance of the signal barrier
uut: ALU
port map(
	dataA => SIGdataA,
	dataB => SIGdataB,
	aluControl => SIGaluControl,
	dataOut => SIGdataOut,
	zeroFlag => SIGzeroFlag,
	negFlag => SIGnegFlag);

-- generate a (virtual) simulation clock
generate_sim_clock: process
begin
	clock <= '1';
	wait for CLOCK_PERIOD/2;
	clock <= '0';
	wait for CLOCK_PERIOD/2;
end process;

-- a simple testbench process:
-- reset the unit under test and afterwards assign various input values
stimuli: process
begin
	-- set input signals to initial value (no undefined values)
	SIGdataA <= (others => '0');
	SIGdataB <= (others => '0');
	SIGaluControl <= (others => '0');
    
    wait for CLOCK_PERIOD;
    -- AND testen
	SIGaluControl <= "0000";
	SIGdataA <= x"FFFF_0000";
	SIGdataB <= x"AF00_45C1";
	
	wait for CLOCK_PERIOD;
    -- OR testen
	SIGaluControl <= "0001";
	SIGdataA <= x"FFFF_0000";
	SIGdataB <= x"AF00_45C1";
	
	wait for CLOCK_PERIOD;
    -- ADD testen
	SIGaluControl <= "0010";
	SIGdataA <= std_logic_vector(to_signed(12, SIGdataA'length));
	SIGdataB <= std_logic_vector(to_signed(136, SIGdataB'length));
	
	wait for CLOCK_PERIOD;
    -- LUI testen
	SIGaluControl <= "0100";
	SIGdataB <= x"AF00_40E1";
	
	wait for CLOCK_PERIOD;
    -- XOR testen
	SIGaluControl <= "0101";
	SIGdataA <= x"AF25_45CE";
	SIGdataB <= x"AF00_4001";
	
	wait for CLOCK_PERIOD;
    -- SUB testen
	SIGaluControl <= "0110";
	SIGdataA <= std_logic_vector(to_signed(136, SIGdataA'length));
	SIGdataB <= std_logic_vector(to_signed(100, SIGdataB'length));
	
	wait for CLOCK_PERIOD;
    -- SUB testen
	SIGaluControl <= "0110";
	SIGdataA <= std_logic_vector(to_signed(100, SIGdataA'length));
	SIGdataB <= std_logic_vector(to_signed(136, SIGdataB'length));
	
	wait for CLOCK_PERIOD;
    -- SUB testen
	SIGaluControl <= "0110";
	SIGdataA <= std_logic_vector(to_signed(100, SIGdataA'length));
	SIGdataB <= std_logic_vector(to_signed(100, SIGdataB'length));
	
	wait for CLOCK_PERIOD;
    -- SLT testen
	SIGaluControl <= "0111";
	SIGdataA <= std_logic_vector(to_signed(100, SIGdataA'length));
	SIGdataB <= std_logic_vector(to_signed(136, SIGdataB'length));
	
	wait for CLOCK_PERIOD;
    -- SLT testen
	SIGaluControl <= "0111";
	SIGdataA <= std_logic_vector(to_signed(136, SIGdataA'length));
	SIGdataB <= std_logic_vector(to_signed(100, SIGdataB'length));
	
	wait for CLOCK_PERIOD;
    -- NOR testen
	SIGaluControl <= "1100";
	SIGdataA <= x"AF25_45CE";
	SIGdataB <= x"AF00_4001";
	
	wait for CLOCK_PERIOD;
    -- Nicht verwendetes Steuersignal exemplarisch testen
	SIGaluControl <= "0011";
	SIGdataA <= x"AF25_45CE";
	SIGdataB <= x"AF00_4001";
	
	
	
	wait;
end process;

end testbench;;