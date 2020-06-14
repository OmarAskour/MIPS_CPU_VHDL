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
        writeEnable : in std_logic;
        dataIn : in std_logic_vector(31 downto 0);
        dataOut : out std_logic_vector(31 downto 0);
        addr : in std_logic_vector(7 downto 0));
end instr_mem;

architecture Behavioral of instr_mem is
    type instrMem is array(255 downto 0) of std_logic_vector(31 downto 0);
    -- Shared variable fuer Schreibzugriff ber 2 Ports
    shared variable INSTR_MEM: instrMem :=(0 => X"22130008", 1 => X"22140001", 2 => X"2215ffff", 3 => X"12700004", 4 => X"0295a020", 5 => X"0295a822", 6 => X"2273ffff", 7 => X"08100003", 8 => X"08100003", others => X"00000000");
begin
    
    -- Port
    
   schnittstelle : process(clk)
    begin   
        if rising_edge(clk) then
            if enable = '1' then
                if writeEnable = '1' then
                    INSTR_MEM(to_integer(unsigned(addr))) := dataIn;
                end if;
                dataOut <= INSTR_MEM(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;

end Behavioral;