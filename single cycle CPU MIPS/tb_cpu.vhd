library ieee;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity tb_cpu is
end tb_cpu;

architecture testbench of tb_cpu is

	constant CLOCK_PERIOD  : time := 10 ns;
	constant buswidth : integer := 32;
	constant addressWidth: integer := 5;
	constant numberOfRegisters: integer := 32;

    -- Signale fuer die Testbench
	signal clock           : std_logic;
	signal reset           : std_logic;
	signal cpuEnable       : std_logic;
	signal LD             : std_logic_vector(7 downto 0);
    
	
	component cpu is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        LD : out std_logic_vector(7 downto 0);
        cpuEnable : in std_logic);
    end component;

begin

-- instantiate an instance of the signal barrier
uut: cpu
port map(
	clk => clock,
	reset => reset,
	LD => LD,
	cpuEnable => cpuEnable);

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
	reset <= '1';
	
    wait for CLOCK_PERIOD*2;
    reset <= '0';
    cpuEnable <= '1';
    
	wait for CLOCK_PERIOD*2;
	
	
	
	wait;
end process;

end testbench;