----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.06.2020 17:05:21
-- Design Name: 
-- Module Name: LED_IO - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LED_IO is
Port (
    reset : in std_logic;
    clk : in std_logic;
    dataIn : in std_logic_vector(31 downto 0);
    load : in std_logic;
    address: in std_logic_vector(31 downto 0);
    ledout : out std_logic_vector(7 downto 0));
end LED_IO;

architecture Behavioral of LED_IO is
    signal led : std_logic_vector(31 downto 0);
begin
    
ledFFs : process(clk)    
begin
    if (rising_edge(clk)) then
        if (reset = '1') then 
            led <= "00000000000000000000000000000000";
        elsif (load = '1' and address = x"00002000") then
            led <= dataIn;
        end if;
    end if;
end process;

ledout <= led(7 downto 0);


end Behavioral;