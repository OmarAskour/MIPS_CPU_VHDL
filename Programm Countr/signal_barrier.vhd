library ieee;
use ieee.std_logic_1164.all;

entity signal_barrier is
port(
	clk        : in  std_logic;
	rst        : in  std_logic;	

	signals_in : in  std_logic_vector(4 downto 0);
	signal_out : out std_logic
);
end entity;

architecture behav of signal_barrier is
	signal next_sig_reg : std_logic_vector(4 downto 0);
	signal sig_reg      : std_logic_vector(4 downto 0);
	signal received_all : std_logic;
begin

	-- asynchronous assignment: assign the result of the OR function to an internal signal
	next_sig_reg <= sig_reg or signals_in;

	-- synchronous process: set flip-flop value to next value every clock cycle
	collect: process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst='1') then
				sig_reg <= (others => '0');
			else
				sig_reg <= next_sig_reg;
			end if;
		end if;
	end process;

	-- asynchronous process: evaluate if all bits are set
	evaluate: process(sig_reg)
	begin
		received_all <= sig_reg(0) and sig_reg(1) and sig_reg(2) and sig_reg(3) and sig_reg(4);
	end process;

	-- connect internal signal with the output port
	signal_out <= received_all;

end architecture;

