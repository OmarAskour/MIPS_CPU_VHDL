
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity ProgramCounter_tb is
end;

architecture bench of ProgramCounter_tb is

  component ProgramCounter
      port(CLK, Rst, Enable, ld : in std_logic;
           D : in unsigned(31 downto 0);
           Q : out unsigned(31 downto 0));
  end component;

  signal CLK, Rst, Enable, ld: std_logic;
  signal D: unsigned(31 downto 0);
  signal Q: unsigned(31 downto 0);

  constant clock_period: time := 10 ns;

begin

  uut: ProgramCounter port map ( 
                             CLK    => CLK,
                             Rst    => Rst,
                             Enable => Enable,
                             ld     => ld,
                             D      => D,
                             Q      => Q );
                             
                             
    generate_sim_clock: process
begin
	CLK <= '1';
	wait for CLOCK_PERIOD/2;
	CLK<= '0';
	wait for CLOCK_PERIOD/2;
end process;                         

  stimulus: process
  begin
  
    -- Put initialisation code here
 --to do
 
 D <= (others => '0');
 Rst <= '1';
 wait for CLOCK_PERIOD*2;

 
    -- Put test bench stimulus code here
--to do
Rst <= '0';

    wait;
  end process;
  
  
end;
  

