library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
        InstrIn : in std_logic_vector(31 downto 0); -- kein pipe
        rs : out std_logic_vector(4 downto 0); -- pipelining
		rt : out std_logic_vector(4 downto 0); -- pipelining
		rd : out std_logic_vector(4 downto 0); -- pipelining
		shamt : out std_logic_vector(4 downto 0); -- pipelining
		addressImmediate : out std_logic_vector(15 downto 0); -- pipelining
		RegDst : out std_logic; -- pipelining
		Branch : out std_logic;  -- pipelining
		MemRead : out std_logic;  -- pipelining
		MemtoReg : out std_logic; -- pipelining
		aluControl : out std_logic_vector(3 downto 0); -- pipelining
		MemWrite : out std_logic; -- pipelining
		ALUSrc : out std_logic; -- pipelining
		RegWrite : out std_logic; -- pipelining
		jump : out std_logic;  -- pipelining
		IMenable : out std_logic;     -- kein pipe
		PCenable : out std_logic;    -- kein pipe        
		compReg : in std_logic);             
		
end component;


-- Signale

-- Signale Programmcounter
-------------------------------------------------------------
-- Signal Programmcounter output --> Instruction Memory
signal pcAddrOut : std_logic_vector(buswidth-1 downto 0);
signal pcLD : std_logic;

-- Signale Registerfile
-------------------------------------------------------------
signal REGaddr_Ra : std_logic_vector(addressWidth-1 downto 0);
signal REGaddr_Rb : std_logic_vector(addressWidth-1 downto 0);
signal REGaddr_Ra_m : std_logic_vector(addressWidth-1 downto 0);
signal REGaddr_Rb_m : std_logic_vector(addressWidth-1 downto 0);

--signal REGaddr_Rc : std_logic_vector(addressWidth-1 downto 0);
signal REGdataIn_Rc : std_logic_vector(buswidth-1 downto 0);
signal REGdataOut_Ra : std_logic_vector(buswidth-1 downto 0);
signal REGdataOut_Rb : std_logic_vector(buswidth-1 downto 0);
signal REGwriteEnable : std_logic;

-- Signale Instruction Memory
------------------------------------------------------------
signal IMenable_res : std_logic;
--signal IMwriteEnable : std_logic;
signal IMdataOutIFID : std_logic_vector(buswidth-1 downto 0);
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
-- signal DMdataIn : std_logic_vector(buswidth-1 downto 0);
signal DMdataOutMEMWB : std_logic_vector(buswidth-1 downto 0);
-- signal DMaddr : std_logic_vector(7 downto 0));

-- Signale Allgemein 
-------------------------------------------------------------
signal Branch : std_logic;
signal RegDst : std_logic;
signal MemToReg : std_logic;
signal ALUSrc : std_logic;
signal addressImmediate : std_logic_vector(15 downto 0);
signal RD : std_logic_vector (4 downto 0);
signal RD_m : std_logic_vector (4 downto 0);
signal shamt : std_logic_vector(4 downto 0);
signal signExtended :std_logic_vector(buswidth-1 downto 0);
signal jump : std_logic;
signal PCenable : std_logic;
signal PCEN : std_logic;

-- Signale Pipelining
--------------------------------------------------------------
signal pcAddrOutIDEX : std_logic_vector(buswidth-1 downto 0);
signal pcAddrOutIFID : std_logic_vector(buswidth-1 downto 0);
signal pcAddrOutIFID_m : std_logic_vector(buswidth-1 downto 0); -- pre Mulitplexer Ausgang

signal pcAddrJump : std_logic_vector(buswidth-1 downto 0);

signal REGdataOut_RaIDEX : std_logic_vector(buswidth-1 downto 0);
signal REGdataOut_RbIDEX : std_logic_vector(buswidth-1 downto 0);

signal signExtendedIDEX : std_logic_vector(buswidth-1 downto 0);

signal REGdataOut_RbEXMEM : std_logic_vector(buswidth-1 downto 0);
signal REGdataOut_RbMEMWB : std_logic_vector(buswidth-1 downto 0);

signal REGaddr_Rb_IDEX : std_logic_vector(addressWidth-1 downto 0);
signal REGaddr_Ra_IDEX : std_logic_vector(addressWidth-1 downto 0);

signal RD_IDEX : std_logic_vector (4 downto 0);

signal RegDstIDEX : std_logic;

signal MemRead : std_logic;
signal MemReadIDEX : std_logic;
signal MemReadEXMEM : std_logic;

signal MemWrite : std_logic;
signal MemWriteIDEX : std_logic;
signal MemWriteEXMEM : std_logic;

signal MemToRegIDEX : std_logic;
signal MemToRegEXMEM : std_logic;
signal MemToRegMEMWB : std_logic;

signal ALUControlIDEX : std_logic_vector(3 downto 0);

signal ALUSrcIDEX : std_logic;

signal REGwriteIDEX : std_logic;
signal REGwriteEXMEM : std_logic;
signal REGwriteMEMWB : std_logic;

--signal IMdataOutIDEX : std_logic_vector(buswidth-1 downto 0);
signal IMdataOutIFID_m : std_logic_vector(buswidth-1 downto 0);

signal REGaddr_RcNew : std_logic_vector(addressWidth-1 downto 0);
signal REGaddr_RcNewEXMEM : std_logic_vector(addressWidth-1 downto 0);
signal REGaddr_RcNewMEMWB : std_logic_vector(addressWidth-1 downto 0);

signal ALUdataOutEXMEM : std_logic_vector(buswidth-1 downto 0);
signal ALUdataOutMEMWB : std_logic_vector(buswidth-1 downto 0);

-- Forwarding 

signal ForwardA : std_logic_vector(1 downto 0);
signal ForwardB : std_logic_vector(1 downto 0);
signal ForwardAMuxOut : std_logic_vector(buswidth-1 downto 0);
signal ForwardBMuxOut : std_logic_vector(buswidth-1 downto 0);

signal IFIDflush : std_logic;
signal IDEXflush : std_logic;

-- Signale Hazard Detection 

signal RegDst_m : std_logic;
signal Branch_m : std_logic;
signal MemRead_m : std_logic;
signal MemToReg_m : std_logic;
signal ALUControl_m : std_logic_vector(3 downto 0);
signal MemWrite_m : std_logic;
signal ALUSrc_m : std_logic; 
signal REGwriteEnable_m : std_logic;
signal jump_m : std_logic;

signal PCflush : std_logic;
signal IFIDenable : std_logic;
signal IMenable_e : std_logic;

signal xorREG : std_logic_vector(buswidth-1 downto 0);
signal compREG : std_logic;

signal ForwardCompA : std_logic_vector(1 downto 0);
signal ForwardCompB : std_logic_vector(1 downto 0);

signal REGdataOut_RaComp : std_logic_vector(buswidth-1 downto 0);
signal REGdataOut_RbComp : std_logic_vector(buswidth-1 downto 0);

begin

-- Instanz der LED

memIO :  LED_IO
port map (
    reset => reset,
    clk => clk,
    dataIn => REGdataOut_RbEXMEM,
    load => MemWriteEXMEM,
    address => ALUdataOutEXMEM,
    ledout => LD);

-- Instanz des Programmcounters
pc : programCounter
generic map(buswidth => buswidth)
port map(addr_in => pcAddrJump,
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
         addr_Rc => REGaddr_RcNewMEMWB,
         dataIn_Rc => REGdataIn_Rc,
         dataOut_Ra => REGdataOut_Ra,
         dataOut_Rb => REGdataOut_Rb,
         writeEN => REGwriteMEMWB,
         reset => reset,
         clk => clk);

-- Instanz des Instruktion Memorys
IM : instr_mem
port map(clk => clk,
        enable => IMenable_res,
        dataOut => IMdataOutIFID_m,
        addr => IMaddr);

-- Instanz der ALU
ALUcpu : alu
generic map(buswidth => buswidth)
port map(dataA => ForwardAMuxOut,
		   dataB => ALUdataB,
		   aluControl => ALUControlIDEX,
		   dataOut => ALUdataOut,
		   zeroFlag => ALUzeroFlag,
		   negFlag => ALUnegFlag);

-- Instanz des Data Memory
DM : data_mem
port map(clk => clk,
        enable => MemReadEXMEM,
        writeEnable => MemWriteEXMEM,
        dataIn => REGdataOut_RbEXMEM,
        dataOut => DMdataOutMEMWB,
        addr => ALUdataOutEXMEM(7 downto 0));

-- Instanz des Instruction Decoders / Control Unit

controlUnit : instr_decoder
port map(
        clk => clk,
        InstrIn => IMdataOutIFID,
        rs => REGaddr_Ra,
		rt => REGaddr_Rb,
		rd => RD,
		shamt => shamt, -- nicht benutzt
		addressImmediate => addressImmediate,
		RegDst => RegDst_m,
		Branch => Branch_m,
		MemRead => MemRead_m,
		MemtoReg => MemToReg_m,
		aluControl => ALUControl_m,
		MemWrite => MemWrite_m,
		ALUSrc => ALUSrc_m,
		RegWrite => REGwriteEnable_m,
		jump => jump_m,
		IMenable => IMenable_e,
		PCenable => PCenable,
		compREG => compREG);

-- NOPS in Kontrollsignale vor IDEX einfgen um bubbles zu erzeugen fr Hazardauflsung

IMenable_res <= IFIDenable and IMenable_e;

with IDEXflush select RegDst <=
     '0' when '1',
     RegDst_m when others;

with IDEXflush select Branch <=
     '0' when '1',
     Branch_m when others;
     
with IDEXflush select MemRead <=
     '0' when '1',
     MemRead_m when others;
     
with IDEXflush select MemToReg <=
     '0' when '1',
     MemToReg_m when others;
     
with IDEXflush select ALUControl <=
     "0011" when '1', -- entspricht NOP, entspricht wiederrum SLL
     ALUControl_m when others;
     
with IDEXflush select MemWrite <=
     '0' when '1',
     MemWrite_m when others;
     
with IDEXflush select ALUSrc <=
     '0' when '1',
     ALUSrc_m when others;
     
with IDEXflush select REGwriteEnable <=
     '0' when '1',
     REGwriteEnable_m when others;
     
with IDEXflush select jump <=
     '0' when '1',
     jump_m when others;
    
    
     
with IDEXflush select RD_m <=
     "00000" when '1',
     RD when others;
     
with IDEXflush select REGaddr_Rb_m <=
     "00000" when '1',
     REGaddr_Rb when others;

with IDEXflush select REGaddr_Ra_m <=
     "00000" when '1',
     REGaddr_Ra when others;




PCEN <= cpuEnable and PCenable and (not PCflush);


--IMaddr <= pcAddrOut(7 downto 0);

process(pcAddrOut)
begin
    if (pcAddrOut(31 downto 8) = x"000000" and pcAddrOut(7 downto 5) = "000") then 
        IMaddr <= pcAddrOut(4 downto 0);
    else
        IMaddr <= "11111";
    end if;
end process;

pcLD <= (Branch and compREG) or jump;
--pcLD <= (BranchIDEX and ALUzeroFlag) or jumpEXMEM; -- klappt nicht

signExtended <= std_logic_vector(resize(signed(addressImmediate), signExtended'length)); -- sign extend

-- Mulitplexer auf DataMem

with ALUSrcIDEX select ALUdataB <= 
    signExtendedIDEX when '1',
    ForwardBMuxOut when others;

-- Mulitplexer nach DataMem
with MemToRegMEMWB select REGdataIn_Rc <= 
    DMdataOutMEMWB when '1',
	ALUdataOutMEMWB when others; 

-- Mulitplexer WriteRegister

with RegDstIDEX select REGaddr_RcNew <=
     REGaddr_Rb_IDEX when '0',
     RD_IDEX when others;
     
-- Multiplexer Jump 
     
with jump select pcAddrJump <=
    std_logic_vector(signed(signExtended) + 1 + signed(pcAddrOutIFID)) when '0', -- offset value for e.g. beq nicht optimal sigend fr pcAddrOut???
    "000000" & IMdataOutIFID(25 downto 0) when others;  -- absolute jump address

-- Komparator fr Registerfile fr Sprungauswertung in Decodephase

xorREG <= (REGdataOut_RaComp xor REGdataOut_RbComp);


compREG <= not(xorREG(0) or xorREG(1) or  xorREG(2) or xorREG(3) or xorREG(4) or xorREG(5) or xorREG(6) or xorREG(7) or xorREG(8) or xorREG(9) or  xorREG(10) or xorREG(11) or xorREG(12) or xorREG(13) or xorREG(14) or xorREG(15) or xorREG(16) or xorREG(17) or xorREG(18) or xorREG(19) or xorREG(20) or xorREG(21) or xorREG(22) or xorREG(23) or xorREG(24) or xorREG(25) or xorREG(26) or xorREG(27) or xorREG(28) or xorREG(29) or xorREG(30) or xorREG(31));


-- Pipelinestufen 

-- Pipelining von pcAddrOut zu ID/EX
-- 1. Stufe IF/ID
IF_ID_PipelineReg: process(clk)
begin 
    if rising_edge(clk) then
        if (IFIDenable = '1') then 
            pcAddrOutIFID <= pcAddrOut;
        end if;
    end if;
end process;

--Multiplexer for flushing the pipe

IFIDflush <= '0'; -- Achtung das muss noch verwendet werden
     
with IFIDflush select IMdataOutIFID <=
     (others => '0') when '1',
     IMdataOutIFID_m when others;
      

-- 2. Stufe ID/EX

ID_EX_PipelineReg : process(clk)
begin 
    if rising_edge(clk) then
        if (reset = '1') then
            RegDstIDEX <= '0';
            MemReadIDEX <= '0';
            MemWriteIDEX <= '0';
            MemToRegIDEX <= '0';
            ALUControlIDEX <= "0000";
            ALUSrcIDEX <= '0';
            REGwriteIDEX <= '0';
        else
            REGdataOut_RaIDEX <= REGdataOut_Ra;
            REGdataOut_RbIDEX <= REGdataOut_Rb;
            signExtendedIDEX <= signExtended; -- Pipelining von Sign Extend
            RegDstIDEX <= RegDst; -- Pipelining von RegDst in IDEX
            MemReadIDEX <= MemRead;
            MemWriteIDEX <= MemWrite;
            MemToRegIDEX <= MemToReg;
            ALUControlIDEX <= ALUControl;
            ALUSrcIDEX <= ALUSrc;
            REGwriteIDEX <= REGwriteEnable;
            --IMdataOutIDEX <= IMdataOutIFID;
            RD_IDEX <= RD_m;
            REGaddr_Rb_IDEX <= REGaddr_Rb_m;
            REGaddr_Ra_IDEX <= REGaddr_Ra_m;
        end if;
    end if;
end process;

-- 3. Stufe EX/MEM

EX_MEM_PipelineReg : process(clk, reset)
begin 
    if rising_edge(clk) then 
        if (reset = '1') then 
            MemReadEXMEM <= '0'; -- macht Sinn
            MemWriteEXMEM <= '0'; -- macht Sinn
            MemToRegEXMEM <= '0';
            REGwriteEXMEM <= '0';
        else
            ALUdataOutEXMEM <= ALUdataOut;
            REGdataOut_RbEXMEM <= ForwardBMuxOut;
            MemReadEXMEM <= MemReadIDEX;
            MemWriteEXMEM <= MemWriteIDEX;
            MemToRegEXMEM <= MemToRegIDEX;
            REGwriteEXMEM <= REGwriteIDEX;
            REGaddr_RcNewEXMEM <= REGaddr_RcNew;
        end if;
    end if;
    
        
end process;

-- 4. Stufe MEM / WB

MEM_WB_PipelineReg : process(clk, reset)
begin 
    if rising_edge(clk) then 
        if (reset = '1') then
            MemToRegMEMWB <= '0';
            REGwriteMEMWB <= '0';
        else
            ALUdataOutMEMWB <= ALUdataOutEXMEM;
            REGdataOut_RbMEMWB <= REGdataOut_RbEXMEM;
            MemToRegMEMWB <= MemToRegEXMEM; 
            REGwriteMEMWB <= REGwriteEXMEM;
            REGaddr_RcNewMEMWB <= REGaddr_RcNewEXMEM;
        end if;
    end if;      
end process;

-- Forwarding unit

-- REGaddr_Rb_IDEX = rtIDEX
-- REGaddr_Ra_IDEX = rsIDED
-- REGaddr_RcNewEXMEM = rD aus EXMEM Phase
-- REGaddr_RcNewMEMWB = rD aus der MEMWB Phase
-- REGwriteEXMEM Steuersignal
-- REGwriteMEMWB Steuersignal


forward : process(REGaddr_Rb_IDEX, REGaddr_Ra_IDEX, REGaddr_RcNewEXMEM, REGaddr_RcNewMEMWB, REGwriteEXMEM, REGwriteMEMWB)
begin 
    if (REGwriteMEMWB = '1') then -- falls wir ins Registerfile schreiben wollen
    -- Forward A
        if ((REGaddr_RcNewMEMWB = REGaddr_Ra_IDEX) and (REGaddr_Ra_IDEX /= "00000")) then
            ForwardA <= "01"; -- The first Alu operand is forwarded from data memory or an earlier ALU result
        else
            ForwardA <= "00"; -- The first ALU operand comes from the register file
        end if;
    -- Forward B
        if ((REGaddr_RcNewMEMWB = REGaddr_Rb_IDEX) and (REGaddr_Rb_IDEX /= "00000")) then
            ForwardB <= "01"; -- The second Alu operand is forwarded from data memory or an earlier ALU result
        else
            ForwardB <= "00"; -- The second ALU operand comes from the register file
        end if;
    else
        ForwardA <= "00"; -- The first ALU operand comes from the register file    
        ForwardB <= "00"; -- The second ALU operand comes from the register file
    end if;
    
    -- falls EX/MEM genutzt werden knnte, wird die Zuweisung hier nochmal berschrieben!!!
        if (REGwriteEXMEM = '1') then -- falls wir ins Registerfile schreiben wollen
    -- Forward A
        if ((REGaddr_RcNewEXMEM = REGaddr_Ra_IDEX) and (REGaddr_Ra_IDEX /= "00000")) then
            ForwardA <= "10"; -- The first ALU operand is forwarded from the prior ALU result
        else
            ForwardA <= "00"; -- The first ALU operand comes from the register file
        end if;
    -- Forward B   
        if ((REGaddr_RcNewEXMEM = REGaddr_Rb_IDEX) and (REGaddr_Rb_IDEX /= "00000")) then
            ForwardB <= "10"; -- The second ALU operand is forwarded from the prior ALU result
        else
            ForwardB <= "00"; -- The second ALU operand comes from the register file
        end if;
    else 
        ForwardA <= "00"; -- The first ALU operand comes from the register file    
        ForwardB <= "00"; -- The second ALU operand comes from the register file
    end if;
    
end process;

-- Forwarding multiplexer A

with ForwardA select ForwardAMuxOut <= 
    REGdataOut_RaIDEX when "00",
    ALUdataOutEXMEM when "10",
    REGdataIn_Rc when "01",
    REGdataOut_RaIDEX when others;

-- Forwarding multiplexer B

with ForwardB select ForwardBMuxOut<= 
    REGdataOut_RbIDEX when "00",
    ALUdataOutEXMEM when "10",
    REGdataIn_Rc when "01",
    REGdataOut_RbIDEX when others;

-- Forwarding Unit Komparator

forwardComp : process(REGwriteMEMWB, REGwriteEXMEM, REGaddr_RcNewMEMWB, REGaddr_Ra, REGaddr_Rb, REGaddr_RcNewEXMEM)

begin 
    if (REGwriteMEMWB = '1') then -- falls wir ins Registerfile schreiben wollen

        if ((REGaddr_RcNewMEMWB = REGaddr_Ra) and (REGaddr_Ra /= "00000")) then
            ForwardCompA <= "01"; -- comes from further stages
        else
            ForwardCompA <= "00";
        end if;

        if ((REGaddr_RcNewMEMWB = REGaddr_Rb) and (REGaddr_Rb /= "00000")) then
            ForwardCompB <= "01";
        else
            ForwardCompB <= "00";
        end if;
    else
        ForwardCompA <= "00";    
        ForwardCompB <= "00"; -- comes from reg file
    end if;
    
    -- falls EX/MEM genutzt werden knnte, wird die Zuweisung hier nochmal berschrieben!!!
        if (REGwriteEXMEM = '1') then -- falls wir ins Registerfile schreiben wollen

        if ((REGaddr_RcNewEXMEM = REGaddr_Ra) and (REGaddr_Ra /= "00000")) then
             ForwardCompA <= "10"; -- comes from further stages
        else
            ForwardCompA <= "00";
        end if;

        if ((REGaddr_RcNewEXMEM = REGaddr_Rb) and (REGaddr_Rb /= "00000")) then
           ForwardCompB <= "10";
        else
            ForwardCompB <= "00";
        end if;
    else
        ForwardCompA <= "00";    
        ForwardCompB <= "00"; -- comes from reg file
    end if;
end process;

with ForwardCompA select REGdataOut_RaComp<= 
   ALUdataOutEXMEM when "10",
   ALUdataOutMEMWB when "01",
   REGdataOut_Ra when others;
    
with ForwardCompB select REGdataOut_RbComp<= 
   ALUdataOutEXMEM when "10",
   ALUdataOutMEMWB when "01",
   REGdataOut_Rb when others;


-- Hazard Detection unit

-- REGaddr_Rb_IDEX = RT IDEX

hazardDetektor : process(MemReadIDEX, REGaddr_Rb_IDEX, REGaddr_Ra, REGaddr_Rb, MemWriteIDEX)

begin 
    PCflush <= '0';
    IFIDenable <= '1'; -- IFID Pipelinestufe im Normalfall aktiv
    IDEXflush <= '0';
    if (MemReadIDEX = '1' and MemWriteIDEX = '0') then -- make sure its a lw ...
        if (REGaddr_Rb_IDEX = REGaddr_Ra or REGaddr_Rb_IDEX = REGaddr_Rb) then -- IDEX REgister Rt == IFID Register Rs oder IDEX Register Rt == IFID Register Rt
            IDEXflush <= '1'; -- NOP Bubbles einfgen vor IDEX in Kontrollsignale
            PCflush <= '1';   -- PC anhalten 
            IFIDenable <= '0'; -- IF/ID anhalten
        end if;
    end if;
end process;


end aufbau; 