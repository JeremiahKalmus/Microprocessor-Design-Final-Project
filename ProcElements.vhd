--------------------------------------------------------------------------------
--
-- LAB #6 - Processor Elements
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SmallBusMux2to1 is
	Port(selector: in std_logic;
	     In0, In1: in std_logic_vector(4 downto 0);
	     Result:   out std_logic_vector(4 downto 0) );
end entity SmallBusMux2to1;

architecture switching of SmallBusMux2to1 is
begin
    with selector select
	Result <= In0 when '0',
		  In1 when others;
end architecture switching;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BusMux2to1 is
	Port(	selector: in std_logic;
			In0, In1: in std_logic_vector(31 downto 0);
			Result: out std_logic_vector(31 downto 0) );
end entity BusMux2to1;

architecture selection of BusMux2to1 is
begin
    with selector select
	Result <= In1 when '1',
		  In0 when others;
end architecture selection;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
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
end Control;

architecture Boss of Control is
begin
RegSrc <= 	'1' when funct = "000000" AND opcode = "000000" else
		'1' when funct = "000010" AND opcode = "000000" else
		'0';

RegDst <=	'0' when opcode = "001000" else
		'0' when opcode = "001101" else
		'0' when opcode = "100011" else
		'1';

Branch <=	"00" when opcode = "000100" else
		"01" when opcode = "000101" else
		"10";

MemRead <=	'0' when opcode = "100011" else --active low lw
		'1';

MemtoReg <=	'1' when opcode = "100011" else --lw
		'0';

ALUOp <=	"00000" when opcode = "000000" AND funct = "100000" else --add
		"00001" when opcode = "000000" AND funct = "100010" else --sub
		"00100" when opcode = "000000" AND funct = "100100" else --and
		"01000" when opcode = "000000" AND funct = "100101" else --or
		"10000" when opcode = "000000" AND funct = "000010" else --srl
		"10001" when opcode = "000000" AND funct = "000000" else --sll
		"00010" when opcode = "001000" else --addi
		"01001" when opcode = "001101" else --ori
		"00010" when opcode = "101011" else --sw
		"00010" when opcode = "100011" else --lw
		"00001" when opcode = "000100" else --beq
		"00001" when opcode = "000101" else --bne
		"ZZZZZ";

MemWrite <= 	'1' when opcode = "101011" else --sw
		'0';

ALUSrc <= 	'1' when opcode = "001000" else
		'1' when opcode = "001101" else
		'1' when opcode = "100011" else
		'1' when opcode = "101011" else
		'1' when opcode = "000000" AND funct = "000000" else
		'1' when opcode = "000000" AND funct = "000010" else
		'0';

RegWrite <= 	clk when opcode = "000000" else
		clk when opcode = "001000" else
		clk when opcode = "001101" else
		clk when opcode = "100011" else
		'Z';
end Boss;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port(Reset: in std_logic;
	 Clock: in std_logic;
	 PCin: in std_logic_vector(31 downto 0);
	 PCout: out std_logic_vector(31 downto 0));
end entity ProgramCounter;

architecture executive of ProgramCounter is
begin
CountProc: process(Clock, Reset) is
begin
   if (Reset = '1') then
	PCout <= X"00400000";
   elsif(falling_edge(Clock)) then
	PCout <= Pcin;
   end if;
end process CountProc;
end executive;
--------------------------------------------------------------------------------