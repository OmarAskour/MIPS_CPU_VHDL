library ieee;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;

entity tb_signal_barrier is
end tb_signal_barrier;

architecture behav of tb_signal_barrier is

	constant CLOCK_PERIOD  : time := 10 ns;

	signal clock           : std_logic;
	signal reset           : std_logic;
	signal s_input_signals : std_logic_vector(4 downto 0);
	signal s_output_signal : std_logic;

begin

-- instantiate an instance of the signal barrier
uut: entity work.signal_barrier
port map(
	clk        => clock,
	rst        => reset,
	signals_in => s_input_signals,
	signal_out => s_output_signal
);

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
	s_input_signals <= "00000";

	reset <= '1';
	wait for CLOCK_PERIOD*2;

	for i in 0 to 4 loop
		reset <= '0';
        wait for CLOCK_PERIOD;
		s_input_signals <= "00011";
		wait for CLOCK_PERIOD;
		s_input_signals <= "00010";
		wait for CLOCK_PERIOD;
		s_input_signals <= "00100";
		wait for CLOCK_PERIOD;
		s_input_signals <= "11000";
		wait for CLOCK_PERIOD;
		wait until s_output_signal = '1';
		reset <= s_output_signal;
		s_input_signals <= "00000";
		wait until s_output_signal = '0';
	end loop;
	reset <= '0';
	wait;
end process;

end behav;

