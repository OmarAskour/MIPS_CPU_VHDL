library ieee;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity tb_program_counter is
end tb_program_counter;

architecture testbench of tb_program_counter is

	constant CLOCK_PERIOD  : time := 10 ns;
	constant buswidth : integer := 32;

	signal clock           : std_logic;
	signal reset           : std_logic;
	signal addr            : std_logic_vector(buswidth-1 downto 0);
	signal addr_in         : std_logic_vector(buswidth-1 downto 0);
    signal LD              : std_logic;
    signal EN              : std_logic;
	
	component programCounter
    Port ( addr_in : in std_logic_vector(buswidth-1 downto 0);
         addr : out std_logic_vector(buswidth-1 downto 0);
         EN : in std_logic;
         LD : in std_logic;
         clk : in std_logic;
         reset : in std_logic);
    end component;

begin

-- instantiate an instance of the signal barrier
uut: programCounter
port map(
	addr_in => addr_in,
	addr => addr,
	EN => EN,
	LD => LD,
	clk => clock,
	reset => reset);

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
	addr_in <= (others => '0');
	reset <= '0';
    LD <= '0';
    EN <= '0';
    
    wait for CLOCK_PERIOD*2;
    reset <= '1';
    
	wait for CLOCK_PERIOD*10;
	
	reset <= '0';
	EN <= '1';
	
    wait for CLOCK_PERIOD*10;
    
    addr_in <= std_logic_vector(to_unsigned(120, addr_in'length));
    LD <= '1';
    
    wait for CLOCK_PERIOD;
    LD <= '0';
    
    wait for CLOCK_PERIOD*10;
    
    EN <= '0';
    
    wait for CLOCK_PERIOD*2;
    
	reset <= '1';
	
	wait for CLOCK_PERIOD*2;
	
	wait;
end process;

end testbench;