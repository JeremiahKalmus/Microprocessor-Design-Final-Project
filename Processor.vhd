--------------------------------------------------------------------------------
--
-- LAB #6 - Processor 
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( reset : in  std_logic;
	   clock : in  std_logic);
end Processor;

architecture holistic of Processor is
	component Control
   	     Port(clk : in  STD_LOGIC;
                   opcode : in  STD_LOGIC_VECTOR (5 downto 0);
		   funct  : in  STD_LOGIC_VECTOR (5 downto 0);
	           RegSrc : out  STD_LOGIC;
	           RegDst : out  STD_LOGIC;
	           Branch : out  STD_LOGIC_VECTOR(1 downto 0);
	           MemRead : out  STD_LOGIC;
	           MemtoReg : out  STD_LOGIC;
	           ALUOp : out  STD_LOGIC_VECTOR(4 downto 0);
	           MemWrite : out  STD_LOGIC;
	           ALUSrc : out  STD_LOGIC;
	           RegWrite : out  STD_LOGIC);
	end component;

	component ALU
		Port(DataIn1: in std_logic_vector(31 downto 0);
		     DataIn2: in std_logic_vector(31 downto 0);
		     Control: in std_logic_vector(4 downto 0);
		     Zero: out std_logic;
		     ALUResult: out std_logic_vector(31 downto 0) );
	end component;
	
	component Registers
	    Port(ReadReg1: in std_logic_vector(4 downto 0); 
                 ReadReg2: in std_logic_vector(4 downto 0); 
                 WriteReg: in std_logic_vector(4 downto 0);
		 WriteData: in std_logic_vector(31 downto 0);
		 WriteCmd: in std_logic;
		 ReadData1: out std_logic_vector(31 downto 0);
		 ReadData2: out std_logic_vector(31 downto 0));
	end component;

	component InstructionRAM
    	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;

	component RAM 
	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;	 
		 OE:      in std_logic;
		 WE:      in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataIn:  in std_logic_vector(31 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;
	
	component BusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(31 downto 0);
		     Result: out std_logic_vector(31 downto 0) );
	end component;
	
	component SmallBusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(4 downto 0);
		     Result: out std_logic_vector(4 downto 0) );
	end component;

	component ProgramCounter
	    Port(Reset: in std_logic;
		 Clock: in std_logic;
		 PCin: in std_logic_vector(31 downto 0);
		 PCout: out std_logic_vector(31 downto 0));
	end component;

	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;

------------Signals-------------------

signal PCinSig, PCoutSig, InstructionSig, WriteDataSig, ReadData1Sig, ReadData2Sig, ADD1Sig, ADD2Sig, ShiftLeftSig, SignExtSig,
       ALUIn2Sig, ALUResultSig, ReadMemSig: std_logic_vector(31 downto 0);
signal ALUOpSig, ReadReg1Sig, WriteRegSig: std_logic_vector(4 downto 0);
signal BranchSig: std_logic_vector(1 downto 0);
signal RegSrcSig, RegDstSig, MemReadSig, MemtoRegSig, ALUSrcSig, MemWriteSig, RegWriteSig, CarrySig, BranchMuxSig, ZeroSig: std_logic;
---------------------------------------
begin
PC: 	ProgramCounter PORT MAP (reset, clock, PCinSig(31 downto 0), PCoutSig(31 downto 0));
IM: 	InstructionRAM PORT MAP (reset, clock, PCoutSig(31 downto 2), InstructionSig(31 downto 0));
CTRL:	Control PORT MAP(clock, InstructionSig(31 downto 26), InstructionSig(5 downto 0), RegSrcSig, RegDstSig,
	BranchSig(1 downto 0), MemReadSig, MemtoRegSig, ALUOpSig(4 downto 0), MemWriteSig, ALUSrcSig, RegWriteSig);

SMRR1:	SmallBusMux2to1 PORT MAP(RegSrcSig, InstructionSig(25 downto 21), InstructionSig(20 downto 16), ReadReg1Sig(4 downto 0));
SMWR:	SmallBusMux2to1 PORT MAP(RegDstSig, InstructionSig(20 downto 16), InstructionSig(15 downto 11), WriteRegSig(4 downto 0));
REG:	Registers PORT MAP(ReadReg1Sig(4 downto 0), InstructionSig(20 downto 16), WriteRegSig(4 downto 0), WriteDataSig(31 downto 0),
	RegWriteSig, ReadData1Sig(31 downto 0), ReadData2Sig(31 downto 0));

ADD1:	adder_subtracter PORT MAP(PCoutSig, X"00000004", '0', ADD1Sig(31 downto 0), CarrySig);
ADD2:	adder_subtracter PORT MAP(ADD1Sig(31 downto 0), ShiftLeftSig(31 downto 0), '0', ADD2Sig(31 downto 0), CarrySig);

BMPC:	BusMux2to1 PORT MAP(BranchMuxSig, ADD1Sig(31 downto 0), ADD2Sig(31 downto 0), PCinSig);
BMALU:	BusMux2to1 PORT MAP(ALUSrcSig, ReadData2Sig(31 downto 0), SignExtSig(31 downto 0), ALUIn2Sig);
BMWD:	BusMux2to1 PORT MAP(MemtoRegSig, ALUResultSig(31 downto 0), ReadMemSig(31 downto 0), WriteDataSig(31 downto 0));

ALU1:	ALU PORT MAP(ReadData1Sig(31 downto 0), ALUIn2Sig(31 downto 0), ALUOpSig(4 downto 0), ZeroSig, ALUResultSig(31 downto 0));
DM:	RAM PORT MAP(reset, clock, MemReadSig, MemWriteSig, ALUResultSig(31 downto 2), ReadData2Sig(31 downto 0), ReadMemSig(31 downto 0));

SignExtSig <= InstructionSig(15)&InstructionSig(15)&InstructionSig(15)&InstructionSig(15)&	InstructionSig(15)&InstructionSig(15)&InstructionSig(15)&InstructionSig(15)&
	      InstructionSig(15)&InstructionSig(15)&InstructionSig(15)&InstructionSig(15)&	InstructionSig(15)&InstructionSig(15)&InstructionSig(15)&InstructionSig(15)&
	      InstructionSig(15 downto 0);
ShiftLeftSig <= SignExtSig(29 downto 0)&"00";

BranchMuxSig <= (NOT ZeroSig AND NOT BranchSig(1) AND BranchSig(0)) OR (ZeroSig AND NOT BranchSig(1) AND NOT BranchSig(0));
end holistic;