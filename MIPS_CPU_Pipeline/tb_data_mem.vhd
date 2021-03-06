library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity tb_data_mem is 
end tb_data_mem;

architecture testbench of tb_data_mem is

    constant CLOCK_PERIOD  : time := 10 ns;
	constant buswidth : integer := 32;

	signal clock           : std_logic;
	signal addr            : std_logic_vector(7 downto 0);
	signal enable          : std_logic;
    signal writeEnable     : std_logic;
    signal dataIn          : std_logic_vector(buswidth-1 downto 0);
    signal dataOut         : std_logic_vector(buswidth-1 downto 0);

    component data_mem is
         Port (
            clk : in std_logic;
            enable : in std_logic;
            writeEnable : in std_logic;
            dataIn : in std_logic_vector(31 downto 0);
            dataOut : out std_logic_vector(31 downto 0);
            addr : in std_logic_vector(7 downto 0));
    end component;

begin

uut: data_mem
     Port map(
        clk => clock,
        enable => enable,
        writeEnable => writeEnable,
        dataIn => dataIn,
        dataOut => dataOut,
        addr => addr);

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
    
    enable <= '0';
    writeEnable <= '0';
    
    addr <= "00000001";
   
	wait for CLOCK_PERIOD*2;
	
	enable <= '1';
	
	wait for CLOCK_PERIOD*2;
	
	dataIn <= X"AAAAAAAA";
	writeEnable <= '1';
	
	wait for CLOCK_PERIOD*2;
	
	writeEnable <= '0';
	addr <= "00000000";
	
	wait for CLOCK_PERIOD*2;
	
	wait;
end process;

end testbench;