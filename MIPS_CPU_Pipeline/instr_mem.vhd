-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.06.2020 14:44:25
-- Design Name: 
-- Module Name: data_mem - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instr_mem is
     Port (
        clk : in std_logic;
        enable : in std_logic;
        dataOut : out std_logic_vector(31 downto 0);
        addr : in std_logic_vector(4 downto 0));
end instr_mem;

architecture Behavioral of instr_mem is
    type instrMem is array(31 downto 0) of std_logic_vector(31 downto 0);
    -- Shared variable fuer Schreibzugriff ber 2 Ports
    shared variable INSTR_MEM: instrMem :=(0=> X"8e130000", 1 => X"02739820", 2 => X"22140001", 3 => X"2215ffff", 4 => X"12700004", 5 => X"2273ffff", 6 => X"0295a020", 7 => X"0295a822", 8 => X"08000004", 9 => X"ae142000", 10 => X"00000000" , others => X"00000000");
    -- shared variable INSTR_MEM: instrMem :=(0 => X"22130008", 1 => X"22140001", 2 => X"2215ffff", 3 => X"12700004", 4 => X"2273ffff", 5 => X"0295a020", 6 => X"0295a822", 7 => X"08000003", 8 => X"ae142000", 9 => X"00000000" , others => X"00000000");
    --    shared variable INSTR_MEM: instrMem :=(0 => X"22130008", 1 => X"22140001", 2 => X"2215ffff", 3 => X"12700005", 4 => X"00000000", 5 => X"0295a020", 6 => X"0295a822", 7 => X"2273ffff", 8 => X"08000003", 9 => X"ae142000", 10 => X"00000000" , others => X"00000000");

begin
    
    -- Port
    
   schnittstelle : process(clk)
    begin   
        if rising_edge(clk) then
            if enable = '1' then
                dataOut <= INSTR_MEM(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;

end Behavioral;


-- hier unten wird BRAM inferiert, hat nicht gepasst wegen Slack 


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

--entity instr_mem is
--     Port (
--        clk : in std_logic;
--        enable : in std_logic;
--        writeEnable : in std_logic;
--        dataIn : in std_logic_vector(31 downto 0);
--        dataOut : out std_logic_vector(31 downto 0);
--        addr : in std_logic_vector(7 downto 0));
--end instr_mem;

--architecture Behavioral of instr_mem is
--    type instrMem is array(255 downto 0) of std_logic_vector(31 downto 0);
--    -- Shared variable fuer Schreibzugriff ber 2 Ports
--    shared variable INSTR_MEM: instrMem :=(0 => X"22130008", 1 => X"22140001", 2 => X"2215ffff", 3 => X"12700004", 4 => X"0295a020", 5 => X"0295a822", 6 => X"2273ffff", 7 => X"08000003", 8 => X"ae142000", others => X"00000000");
--begin
    
--    -- Port
    
--   schnittstelle : process(clk)
--    begin   
--        if rising_edge(clk) then
--            if enable = '1' then
--                if writeEnable = '1' then
--                    INSTR_MEM(to_integer(unsigned(addr))) := dataIn;
--                end if;
--                dataOut <= INSTR_MEM(to_integer(unsigned(addr)));
--            end if;
--        end if;
--    end process;

--end Behavioral;