----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
 
-- Create Date: 27.05.2020 15:33:09
-- Design Name: 
-- Module Name: alu - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
 
-- Dependencies: 
 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
 
----------------------------------------------------------------------------------

----------------------------------------
-- Version ohne AND-Gating um den Energieverbrauch zu reduzieren
---------------------------------------------


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

--entity alu is
--	generic (constant buswidth: integer := 32);
--	Port ( dataA : in std_logic_vector(31 downto 0);
--		   dataB : in std_logic_vector(31 downto 0);
--		   aluControl : in std_logic_vector(3 downto 0);
--		   dataOut : out std_logic_vector(31 downto 0);
--		   zeroFlag : out std_logic;
--		   --ovfFlag : out std_logic;
--		   negFlag : out std_logic);
--end entity;

--architecture Behavioral of alu is
---- Signale definieren
--	signal result : signed(31 downto 0); 
--	signal A : signed(31 downto 0);
--	signal B : signed(31 downto 0);
	
--	begin
	
--	A <= signed(dataA);
--	B <= signed(dataB);
	
--	aluControl_Calculate : process(A, B, aluControl)
--		begin
--			case aluControl is
--				when "0000" => -- AND
--					result <= A and B;
--				when "0001" => -- OR
--					result <= A or B;
--				when "0010" => -- ADD
--					result <= A + B;
--				when "0100" => -- LUI
--					result(31 downto 16) <= B(15 downto 0);
--					result(15 downto 0) <= x"0000";
--				when "0101" => -- XOR
--					result <= A xor B;
--				when "0110" => -- SUB
--					result <= A - B;
--				when "0111" => -- SLT
--					if (A < B) then
--						result <= (0 => '1', others => '0');
--					else
--						result <= (0 => '0', others => '0');
--					end if;
--				when "1100" => -- NOR
--					result <= A nor B;
--				when others => 
--					result <= A and B;
--			end case;
--	end process;
		
--	dataOut <= std_logic_vector(result);
	
--	flags : process(result)
--	   begin
--	       if (result = 0) then
--	           zeroFlag <= '1';
--		       negFlag <= '0';
--		   elsif (result < 0) then
--		       zeroFlag <= '0';
--		       negFlag <= '1';
--		   else
--		       zeroFlag <= '0';
--		       negFlag <= '0';
--		   end if;
--   end process;
	
	
--end architecture;


----------------------------------------
-- Version mit AND-Gating um den Energieverbrauch zu reduzieren
---------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity alu is
	generic (constant buswidth: integer := 32);
	Port ( dataA : in std_logic_vector(31 downto 0);
		   dataB : in std_logic_vector(31 downto 0);
		   aluControl : in std_logic_vector(3 downto 0);
		   dataOut : out std_logic_vector(31 downto 0);
		   zeroFlag : out std_logic;
		   --ovfFlag : out std_logic;
		   negFlag : out std_logic);
end entity;

architecture Behavioral of alu is
-- Signale definieren
	signal result : signed(31 downto 0); 
	signal A : signed(31 downto 0);
	signal B : signed(31 downto 0);
	
	-- Signale fr die Operationen
	
	signal ADDed : signed(31 downto 0);
	signal ANDed : signed(31 downto 0);
	signal ORed : signed(31 downto 0);
	signal LUIed : signed(31 downto 0);
	signal XORed : signed(31 downto 0);
	signal SUBed : signed(31 downto 0);
	signal SLTed : signed(31 downto 0);
	signal NORed : signed(31 downto 0);
	signal SLLed : signed(31 downto 0);
	
	-- Signale fr AND-Gating
	
	signal ADD, UND, ODER, LUI, XODER, SUB, SLT, NODER, ourSLL : std_logic;
	
	begin
	
	A <= signed(dataA);
	B <= signed(dataB);
	
	ADDed <= (A and ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD) + (B and ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD&ADD); 
	         
	ANDed <= (A and UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND) and (B and UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND&UND);
	
    ORed <= (A and ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER) or (B and ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER&ODER);
	          
	LUIed <= (B(15 downto 0) & x"0000") and LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI&LUI;

	XORed <= (A and XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER) xor (B and XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER&XODER);
	         
	SUBed <= (A and SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB) - (B and SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB&SUB); 
	          
	SLTed <= (0 => '1', others => '0')  when ( (A AND SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT) < (B AND SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT&SLT)) else
	         (0 => '0', others => '0');
	         
	NORed <= (A and NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER) nor (B and NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER&NODER);
	      
	SLLed <= (A and ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL&ourSLL) sll 0;                  
	         	         	         	         	
	aluOPdecode : process(aluControl, ADD, UND, ODER, LUI, XODER, SUB, SLT, NODER, ourSLL)
	   begin
	       case aluControl is
				when "0000" => -- AND
					ADD <= '0';
					UND <= '1';
					ODER <= '0';
					LUI <= '0';
					XODER <= '0';
					SUB <= '0';
					SLT <= '0';
					NODER <= '0';
					ourSLL <= '0';
				when "0001" => -- OR
					ADD <= '0';
					UND <= '0';
					ODER <= '1';
					LUI <= '0';
					XODER <= '0';
					SUB <= '0';
					SLT <= '0';
					NODER <= '0';
					ourSLL <= '0';
				when "0010" => -- ADD
					ADD <= '1';
					UND <= '0';
					ODER <= '0';
					LUI <= '0';
					XODER <= '0';
					SUB <= '0';
					SLT <= '0';
					NODER <= '0';
					ourSLL <= '0';
				when "0011" => -- SLL bzw. nur NOP!
				    ADD <= '0';
					UND <= '0';
					ODER <= '0';
					LUI <= '0';
					XODER <= '0';
					SUB <= '0';
					SLT <= '0';
					NODER <= '0';
					ourSLL <= '1';
				when "0100" => -- LUI
					ADD <= '0';
					UND <= '0';
					ODER <= '0';
					LUI <= '1';
					XODER <= '0';
					SUB <= '0';
					SLT <= '0';
					NODER <= '0';
					ourSLL <= '0';
				when "0101" => -- XOR
					ADD <= '0';
					UND <= '0';
					ODER <= '0';
					LUI <= '0';
					XODER <= '1';
					SUB <= '0';
					SLT <= '0';
					NODER <= '0';
					ourSLL <= '0';
				when "0110" => -- SUB
					ADD <= '0';
					UND <= '0';
					ODER <= '0';
					LUI <= '0';
					XODER <= '0';
					SUB <= '1';
					SLT <= '0';
					NODER <= '0';
					ourSLL <= '0';
				when "0111" => -- SLT
					ADD <= '0';
					UND <= '0';
					ODER <= '0';
					LUI <= '0';
					XODER <= '0';
					SUB <= '0';
					SLT <= '1';
					NODER <= '0';
					ourSLL <= '0';
				when "1100" => -- NOR
					ADD <= '0';
					UND <= '0';
					ODER <= '0';
					LUI <= '0';
					XODER <= '0';
					SUB <= '0';
					SLT <= '0';
					NODER <= '1';
					ourSLL <= '0';
				when others => 
					ADD <= '0';
					UND <= '0';
					ODER <= '0';
					LUI <= '0';
					XODER <= '0';
					SUB <= '0';
					SLT <= '0';
					NODER <= '0';
					ourSLL <= '0';
			end case;
	end process;
	
	aluMultiplexer : process(ANDed, ORed, ADDed, LUIed, XORed, SUBed, SLTed, NORed, aluControl)
		begin
			case aluControl is
				when "0000" => -- AND
					result <= ANDed;
				when "0001" => -- OR
					result <= ORed;
				when "0010" => -- ADD
					result <= ADDed;
				when "0011" => -- SLL / NOP
				    result <= SLLed;
				when "0100" => -- LUI
					result <= LUIed;
				when "0101" => -- XOR
					result <= XORed;
				when "0110" => -- SUB
					result <= SUBed;
				when "0111" => -- SLT
					result <= SLTed;
				when "1100" => -- NOR
					result <= NORed;
				when others => 
					result <= ANDed;
			end case;
	end process;
		
	dataOut <= std_logic_vector(result);
	
	flags : process(result)
	   begin
	       if (result = 0) then
	           zeroFlag <= '1';
		       negFlag <= '0';
		   elsif (result > 0) then
		       zeroFlag <= '0';
		       negFlag <= '1';
		   else
		       zeroFlag <= '0';
		       negFlag <= '0';
		   end if;
   end process;
	
	
end architecture;