library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.all;



entity ProgramCounter is
    Port ( CLK : in STD_LOGIC;
           Rst : in STD_LOGIC;
           Enable : in STD_LOGIC;
           ld : in STD_LOGIC;
           D : in STD_LOGIC_vector(31 downto 0);
           Q : out STD_LOGIC_vector(31 downto 0)
          );
end ProgramCounter;

architecture Behavioral of ProgramCounter is
signal count: STD_LOGIC_vector(31 downto 0);
begin
process(CLK)
begin
if (Rst = '1') then
count <= (others => '0');
elsif (CLK'event and CLK = '1') then


                   if Enable ='1' then
                              if ld= '1' then
                                       count <= D; 
                               else
                                       count <= count + 4;                                   end if;
            
                   end if;

end if;
end process;
Q <= count;

end Behavioral;

