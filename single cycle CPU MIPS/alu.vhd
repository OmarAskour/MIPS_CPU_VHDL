library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity alu is
	generic (constant buswidth integer = 32);
	Port ( dataA  in std_logic_vector(31 downto 0);
		   dataB  in std_logic_vector(31 downto 0);
		   aluControl  in std_logic_vector(3 downto 0);
		   dataOut  out std_logic_vector(31 downto 0);
		   zeroFlag  out std_logic;
		   --ovfFlag  out std_logic;
		   negFlag  out std_logic);
end entity;

architecture Behavioral of alu is
-- Signale definieren
	signal result  signed(31 downto 0); 
	signal A  signed(31 downto 0);
	signal B  signed(31 downto 0);
	
	begin
	
	A = signed(dataA);
	B = signed(dataB);
	
	aluControl_Calculate  process(A, B, aluControl)
		begin
			case aluControl is
				when 0000 = -- AND
					result = A and B;
				when 0001 = -- OR
					result = A or B;
				when 0010 = -- ADD
					result = A + B;
				when 0100 = -- LUI
					result(31 downto 16) = B(15 downto 0);
					result(15 downto 0) = x0000;
				when 0101 = -- XOR
					result = A xor B;
				when 0110 = -- SUB
					result = A - B;
				when 0111 = -- SLT
					if (A  B) then
						result = (0 = '1', others = '0');
					else
						result = (0 = '0', others = '0');
					end if;
				when 1100 = -- NOR
					result = A nor B;
				when others = 
					result = A and B;
			end case;
	end process;
		
	dataOut = std_logic_vector(result);
	
	flags  process(result)
	   begin
	       if (result = 0) then
	           zeroFlag = '1';
		       negFlag = '0';
		   elsif (result  0) then
		       zeroFlag = '0';
		       negFlag = '1';
		   else
		       zeroFlag = '0';
		       negFlag = '0';
		   end if;
   end process;
	
	
end architecture;