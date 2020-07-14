library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
Port (
	clk : in std_logic;
	reset : in std_logic;
	LD : out std_logic_vector(7 downto 0);
	cpuEnable : in std_logic);
end cpu;

architecture aufbau of cpu is
-- Konstanten
constant buswidth: integer := 32;
constant addressWidth: integer := 5;
constant numberOfRegisters: integer := 32;

-- LED IO einbinden

component LED_IO is
Port (
    reset : in std_logic;
    clk : in std_logic;
    dataIn : in std_logic_vector(31 downto 0);
    load : in std_logic;
    address: in std_logic_vector(31 downto 0);
    ledout : out std_logic_vector(7 downto 0));
end component;

-- PC einbinden
component programCounter is
  generic( constant buswidth: integer := 32);
  port ( addr_in : in std_logic_vector(buswidth-1 downto 0);
         addr : out std_logic_vector(buswidth-1 downto 0);
         EN : in std_logic;
         LD : in std_logic;
         clk : in std_logic;
         reset : in std_logic);
end component;

-- Registerfile einbinden
component regfile is
  generic ( constant addressWidth: integer := 5;
            constant buswidth: integer := 32;
            constant numberOfRegisters: integer := 32);
  Port ( addr_Ra : in std_logic_vector(addressWidth-1 downto 0);
         addr_Rb : in std_logic_vector(addressWidth-1 downto 0);
         addr_Rc : in std_logic_vector(addressWidth-1 downto 0);
         dataIn_Rc : in std_logic_vector(buswidth-1 downto 0);
         dataOut_Ra : out std_logic_vector(buswidth-1 downto 0);
         dataOut_Rb : out std_logic_vector(buswidth-1 downto 0);
         writeEN : in std_logic;
         reset : in std_logic;
         clk : in std_logic );
end component;

-- ALU einbinden
component alu is
	generic (constant buswidth: integer := 32);
	Port ( dataA : in std_logic_vector(31 downto 0);
		   dataB : in std_logic_vector(31 downto 0);
		   aluControl : in std_logic_vector(3 downto 0);
		   dataOut : out std_logic_vector(31 downto 0);
		   zeroFlag : out std_logic;
		   --ovfFlag : out std_logic;
		   negFlag : out std_logic);
end component;

-- Data Memory einbinden
component data_mem is
     Port (
        clk : in std_logic;
        enable : in std_logic;
        writeEnable : in std_logic;
        dataIn : in std_logic_vector(31 downto 0);
        dataOut : out std_logic_vector(31 downto 0);
        addr : in std_logic_vector(7 downto 0));
end component;

-- Instruction Memory einbinden
component instr_mem is
     Port (
        clk : in std_logic;
        enable : in std_logic;
        dataOut : out std_logic_vector(31 downto 0);
        addr : in std_logic_vector(4 downto 0));
end component;

-- Instruction Decoder = Control Unit der CPU

component instr_decoder is
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
		jump : out std_logic;
		IMenable : out std_logic;
		PCenable : out std_logic);
		
end component;


-- Signale

-- Signale Programmcounter
-------------------------------------------------------------
-- Signal Programmcounter output --> Instruction Memory
signal pcAddrOut : std_logic_vector(buswidth-1 downto 0);
signal pcAddrIn :  std_logic_vector(buswidth-1 downto 0);
signal pcLD : std_logic;

-- Signale Registerfile
-------------------------------------------------------------
signal REGaddr_Ra : std_logic_vector(addressWidth-1 downto 0);
signal REGaddr_Rb : std_logic_vector(addressWidth-1 downto 0);
signal REGaddr_Rc : std_logic_vector(addressWidth-1 downto 0);
signal REGdataIn_Rc : std_logic_vector(buswidth-1 downto 0);
-- signal REGdataOut_Ra : std_logic_vector(buswidth-1 downto 0);
signal REGdataOut_Rb : std_logic_vector(buswidth-1 downto 0);
signal REGwriteEnable : std_logic;

-- Signale Instruction Memory
------------------------------------------------------------
signal IMenable : std_logic;
--signal IMwriteEnable : std_logic;
signal IMdataOut : std_logic_vector(buswidth-1 downto 0);
signal IMaddr : std_logic_vector(4 downto 0);

-- Signale ALU 
------------------------------------------------------------
signal ALUdataA : std_logic_vector(buswidth-1 downto 0);
signal ALUdataB : std_logic_vector(buswidth-1 downto 0);
signal ALUControl : std_logic_vector(3 downto 0);
signal ALUdataOut : std_logic_vector(buswidth-1 downto 0);
signal ALUzeroFlag : std_logic;
signal ALUnegFlag : std_logic;

-- Signale Data Memory
------------------------------------------------------------
signal DMenable : std_logic;
signal DMwriteEnable : std_logic;
-- signal DMdataIn : std_logic_vector(buswidth-1 downto 0);
signal DMdataOut : std_logic_vector(buswidth-1 downto 0);
-- signal DMaddr : std_logic_vector(7 downto 0));

-- Signale Allgemein 
-------------------------------------------------------------
signal Branch : std_logic;
signal RegDst : std_logic;
signal MemToReg : std_logic;
signal ALUSrc : std_logic;
signal addressImmediate : std_logic_vector(15 downto 0);
signal RD : std_logic_vector (4 downto 0);
signal shamt : std_logic_vector(4 downto 0);
signal signExtended :std_logic_vector(buswidth-1 downto 0);
signal jump : std_logic;
signal PCenable : std_logic;
signal PCEN : std_logic;

begin

-- Instanz der LED

memIO :  LED_IO
port map (
    reset => reset,
    clk => clk,
    dataIn => REGdataOut_Rb,
    load => DMwriteEnable,
    address => ALUdataOut,
    ledout => LD);

-- Instanz des Programmcounters
pc : programCounter
generic map(buswidth => buswidth)
port map(addr_in => pcAddrIn,
		 addr => pcAddrOut,
		 EN => PCEN,
		 LD => pcLD,
		 clk => clk,
		 reset => reset);

-- Instanz des Registerfiles 
reg : regfile
generic map(buswidth => buswidth,
			addressWidth => addressWidth,
			numberOfRegisters => numberOfRegisters)
port map(addr_Ra => REGaddr_Ra,
         addr_Rb => REGaddr_Rb,
         addr_Rc => REGaddr_Rc,
         dataIn_Rc => REGdataIn_Rc,
         dataOut_Ra => ALUdataA,
         dataOut_Rb => REGdataOut_Rb,
         writeEN => REGwriteEnable,
         reset => reset,
         clk => clk);

-- Instanz des Instruktion Memorys
IM : instr_mem
port map(clk => clk,
        enable => IMenable,
        dataOut => IMdataOut,
        addr => IMaddr);

-- Instanz der ALU
ALUcpu : alu
generic map(buswidth => buswidth)
port map(dataA => ALUdataA,
		   dataB => ALUdataB,
		   aluControl => ALUControl,
		   dataOut => ALUdataOut,
		   zeroFlag => ALUzeroFlag,
		   negFlag => ALUnegFlag);

-- Instanz des Data Memory
DM : data_mem
port map(clk => clk,
        enable => DMenable,
        writeEnable => DMwriteEnable,
        dataIn => REGdataOut_Rb,
        dataOut => DMdataOut,
        addr => ALUdataOut(7 downto 0));

-- Instanz des Instruction Decoders / Control Unit

controlUnit : instr_decoder
port map(
        clk => clk,
        InstrIn => IMdataOut,
        rs => REGaddr_Ra,
		rt => REGaddr_Rb,
		rd => RD,
		shamt => shamt,
		addressImmediate => addressImmediate,
		RegDst => RegDst,
		Branch => Branch,
		MemRead => DMenable,
		MemtoReg => MemToReg,
		aluControl => ALUControl,
		MemWrite => DMwriteEnable,
		ALUSrc => ALUSrc,
		RegWrite => REGwriteEnable,
		jump => jump,
		IMenable => IMenable,
		PCenable => PCenable);


PCEN <= cpuEnable and PCenable;

--IMaddr <= pcAddrOut(7 downto 0);

process(pcAddrOut)
begin
    if (pcAddrOut(31 downto 8) = x"000000") then 
        IMaddr <= pcAddrOut(4 downto 0);
    else
        IMaddr <= "11111";
    end if;
end process;

pcLD <= (Branch and ALUzeroFlag) or jump;

signExtended <= std_logic_vector(resize(signed(IMdataOut(15 downto 0)), signExtended'length)); -- sign extend

-- Mulitplexer auf DataMem

with ALUSrc select ALUdataB <= 
    signExtended when '1',
    REGdataOut_Rb when others;

-- Mulitplexer nach InstrMem
with MemToReg select REGdataIn_Rc <= 
    DMdataOut when '1',
	ALUdataOut when others;

-- Mulitplexer WriteRegister

with RegDst select REGaddr_Rc <=
     REGaddr_Rb when '0',
     RD when others;
     
-- Multiplexer Jump 
     
with jump select pcAddrIn <=
    std_logic_vector(signed(signExtended) + 1 + signed(pcAddrOut)) when '0', -- offset value for e.g. beq nicht optimal sigend fr pcAddrOut???
    "000000" & IMdataOut(25 downto 0) when others;  -- absolute jump address
end aufbau; 