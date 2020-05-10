library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ProgramCounter is
    port(CLK, Rst, Enable, ld : in std_logic;
         D : in unsigned(31 downto 0);
         Q : out unsigned(31 downto 0));
end ProgramCounter;

architecture archi of ProgramCounter is
    signal count: unsigned(31 downto 0);
begin
    process (CLK, Rst, ld, Enable)
    begin
   
    if (CLK'event and CLK='1') then
           if (Rst='1') then
                  count <= (others => '0');
            else
                                            
                   if Enable ='1' then
                              if ld= '1' then
                                       count <= D; 
                               else
                                       count <= count + 4;
                               end if;
               -- else --count <= D;
                   end if;
                        
            end if;
     end if;
        
    end process;

    Q <= count;

end archi;