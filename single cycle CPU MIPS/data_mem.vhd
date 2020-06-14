library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_mem is
     Port (
        clk : in std_logic;
        enable : in std_logic;
        writeEnable : in std_logic;
        dataIn : in std_logic_vector(31 downto 0);
        dataOut : out std_logic_vector(31 downto 0);
        addr : in std_logic_vector(7 downto 0));
end data_mem;

architecture Behavioral of data_mem is
    type dataMem is array(255 downto 0) of std_logic_vector(31 downto 0);
    -- Shared variable fuer Schreibzugriff ber 2 Ports
    shared variable DATA_MEM: dataMem :=(0 => X"11111111", 1 => X"22222222", others => X"00000000");
begin
    
    -- Port
    
   schnittstelle : process(clk)
    begin   
        if rising_edge(clk) then
            if enable = '1' then
                if writeEnable = '1' then
                    DATA_MEM(to_integer(unsigned(addr))) := dataIn;
                end if;
                dataOut <= DATA_MEM(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;

end Behavioral;