library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instr_decoder is
     Port (
        clk : in std_logic;
        InstrIn : in std_logic_vector(31 downto 0);
        rs : out std_logic_vector(4 downto 0);
		rt : out std_logic_vector(4 downto 0);
		rd : out std_logic_vector(4 downto 0);
		shamt : out std_logic_vector(4 downto 0);
		addressImmediate : out std_logic_vector(15 downto 0);
		RegDst : out std_logic;
		Branch : out std_logic;
		MemRead : out std_logic;
		MemtoReg : out std_logic;
		aluControl : out std_logic_vector(3 downto 0);
		MemWrite : out std_logic;
		ALUSrc : out std_logic;
		RegWrite : out std_logic;
		jump: out std_logic;
		IMenable : out std_logic;
		PCenable : out std_logic);
end instr_decoder;

architecture Behavioral of instr_decoder is
	
	signal instructionOp : std_logic_vector(5 downto 0);
	signal ALUOp : std_logic_vector(1 downto 0); -- ????
	signal funct : std_logic_vector(5 downto 0);
	signal inIMenable : std_logic;
	signal inPCenable : std_logic;
	signal count : std_logic;
	signal PCcount : std_logic;
	signal inBranch: std_logic;
	
begin
    
	-- Decoder (Folie 45 MIPS Single Cycle CPU)
	
	instructionOp <= InstrIn(31 downto 26);
	rs <= InstrIn(25 downto 21);
	rt <= InstrIn(20 downto 16);
	rd <= InstrIn(15 downto 11);
	shamt <= InstrIn(10 downto 6);
	funct <= InstrIn(5 downto 0);
	addressImmediate <= InstrIn(15 downto 0);
	
	
	-- Control unit 
	
	MEMenableIM : process(count, inIMenable)
	begin 
	   if (inIMenable = '0' and count = '0') then 
	       IMenable <= '0';
	   elsif (count ='1') then
	       IMenable <= '1';
	   elsif(inIMenable = '1') then
	       IMenable <= '1';
	   end if; 
    end process; 
    
 
	enableIM : process(clk)
	begin 
	   if (rising_edge(clk)) then
	       if(inIMenable = '0' and count = '0') then
	           count <= '1';
	       else    
	           count <= '0';
	       end if;
	   end if;
	end process;
	
	MEMenablePC : process(PCcount, inPCenable, inBranch)
	begin 
	   if (inPCenable = '0' and PCcount = '0' and inBranch = '1') then 
	       PCenable <= '0';
	   elsif (PCcount ='1') then
	       PCenable <= '1';
	   elsif(inPCenable = '1') then
	       PCenable <= '1';
	   end if; 
    end process; 
    
 
	enablePC : process(clk)
	begin 
	   if (rising_edge(clk)) then
	       if(inPCenable = '0' and PCcount = '0') then
	           PCcount <= '1';
	       else    
	           PCcount <= '0';
	       end if;
	   end if;
	end process;
	
	Branch <= inBranch;
	
	Control : process(instructionOp)
	
	begin
	   case instructionOp is
	       when "000000" => -- R-Type
	           RegDst <= '1';
	           inBranch <= '0';
	           MemRead <= '0';
	           MemtoReg <= '0';
	           ALUOp <= "10";
	           MemWrite <= '0';
	           ALUSrc <= '0';
	           RegWrite <= '1';
	           jump <= '0';
	           inIMenable <= '1';
	           inPCenable <= '1';
	       when "101011" => -- SW   = 0x2B
	           RegDst <= '-';
	           inBranch <= '0';
	           MemRead <= '1'; -- ACHTUNG!!! gendert gegenber Tabelle, weil unser BRAM anders funktioniert
	           MemtoReg <= '-';
	           ALUOp <= "00";
	           MemWrite <= '1'; -- ACHTUNG!!!
	           ALUSrc <= '1';
	           RegWrite <= '0';     
	           jump <= '0';
	           inIMenable <= '0';
	           inPCenable <= '0';
	       when "100011" => -- LW = 0x23
	           RegDst <= '0';
	           inBranch <= '0';
	           MemRead <= '1';
	           MemtoReg <= '1';
	           ALUOp <= "00";
	           MemWrite <= '0';
	           ALUSrc <= '1';
	           RegWrite <= '1';  
	           jump <= '0';
	           inIMenable <= '0';
	           inPCenable <= '0';
	       when "000100" => -- BEQ = 0x04
	           RegDst <= '-';
	           inBranch <= '1';
	           MemRead <= '0';
	           MemtoReg <= '0';
	           ALUOp <= "01";
	           MemWrite <= '0';
	           ALUSrc <= '0';
	           RegWrite <= '0';  
	           jump <= '0';
	           inIMenable <= '0';
	           inPCenable <= '0';
	       when "001000" => -- ADDI = 0x08
	           RegDst <= '0';
	           inBranch <= '0';
	           MemRead <= '0';
	           MemtoReg <= '0';
	           ALUOp <= "00";
	           MemWrite <= '0';
	           ALUSrc <= '1';
	           RegWrite <= '1';
	           jump <= '0';
	           inIMenable <= '1';
	           inPCenable <= '1';
	       when "001111" => -- LUI = 0x0F
	           RegDst <= '1';
	           inBranch <= '0';
	           MemRead <= '0';
	           MemtoReg <= '0';
	           ALUOp <= "11";
	           MemWrite <= '0';
	           ALUSrc <= '1';
	           RegWrite <= '1';
	           jump <= '0';
	           inIMenable <= '1';
	           inPCenable <= '1';
	       when "000010" => -- JUMP = 0x02
	           RegDst <= '0';
	           inBranch <= '0';
	           MemRead <= '0';
	           MemtoReg <= '0';
	           ALUOp <= "--";
	           MemWrite <= '0';
	           ALUSrc <= '0';
	           RegWrite <= '0';
	           jump <= '1';
	           inIMenable <= '0';
	           inPCenable <= '1';
	       when others => 
	           RegDst <= '-';
	           inBranch <= '0';
	           MemRead <= '-';
	           MemtoReg <= '0';
	           ALUOp <= "--";
	           MemWrite <= '0';
	           ALUSrc <= '-';
	           RegWrite <= '-';
	           jump <= '0';
	           inIMenable <= '1';
	           inPCenable <= '1';
	   end case;
	end process;
	
	
	-- ALU Control 
	
	ALUcontroller : process(ALUOp, funct) -- rein kombinatorischer Prozess
	
	begin
		if (ALUOp = "10") then -- R-Type
			case funct is 
				when  "100100" =>   -- 0x24
					aluControl <= "0000"; -- AND
				when  "100101" =>   -- 0x25
					aluControl <= "0001"; -- OR
				when "100000" =>   -- 0x20
					aluControl <= "0010"; -- ADD
				when "100110" =>   -- 0x26
					aluControl <= "0101"; -- XOR
				when "100010" =>   -- 0x22
					aluControl <= "0110"; -- SUB
				when "101010" =>   -- 0x24 
					aluControl <= "0111"; -- SLT
				when "100111" =>   -- 0x27
					aluControl <= "1100"; -- NOR
				when "000000" =>   --0x00
				    aluControl <= "0011"; -- SLL
				when others => 
					aluControl <= "0000";
			end case;
		elsif (ALUOp = "00") then -- I-Type | load word | store word
			aluControl <= "0010"; -- ALU desired operation is ADD siehe Folie 42 (MIPS Single Cycle CPU)
		elsif (ALUOp = "01") then -- I-TYPE | branch equal 
			aluControl <= "0110"; -- ALU desired operation is SUB siehe Folie 42
		else
			aluControl <= "0100"; -- I-TYPE LUI
		end if;
	end process;
	
end Behavioral;