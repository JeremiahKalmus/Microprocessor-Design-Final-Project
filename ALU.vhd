--
--Kalmus and Burgi Lab4--
--
-------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity ALU is
	Port(	DataIn1:   in std_logic_vector(31 downto 0);
		DataIn2:   in std_logic_vector(31 downto 0);
		Control:   in std_logic_vector(4 downto 0);
		Zero:      out std_logic;
		ALUResult: out std_logic_vector(31 downto 0));
end entity ALU;

architecture ALU_Arch of ALU is

	component adder_subtracter is
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;
	component shift_register is
		port(	datain: in std_logic_vector(31 downto 0);
		   	dir: in std_logic;
			shamt:	in std_logic_vector(4 downto 0);
			dataout: out std_logic_vector(31 downto 0));
	end component shift_register;

	signal adderout, shiftout, andout, orout: std_logic_vector(31 downto 0);
	signal addorsub, carryout, dir: std_logic;
begin
--control--
with Control select
	addorsub <=	'0' when "00000",
			'1' when "00001",
			'0' when "00010",
			'Z' when others;
with Control select
	dir <=		'0' when "10000",
			'1' when "10001",
			'Z' when others;
--adder--
ADDER: adder_subtracter PORT MAP (DataIn1(31 downto 0), DataIn2(31 downto 0), addorsub, adderout(31 downto 0), carryout);
--shift--
SHIFTER: shift_register PORT MAP(DataIn1(31 downto 0), dir, DataIn2(10 downto 6), shiftout(31 downto 0));
--and--
andout <= DataIn1 AND DataIn2;
--or--
orout <= DataIn1 OR DataIn2;
--mux--
with Control select
	ALUResult <=	adderout when "00000" | "00001" | "00010",
			andout when "00100",
			orout when "01000" | "01001",
			shiftout when "10000" | "10001",
			"ZZZZZZZZ"&"ZZZZZZZZ"&"ZZZZZZZZ"&"ZZZZZZZZ" when others;
with ALUResult select
	Zero <= '1' when "00000000"&"00000000"&"00000000"&"00000000",
		'0' when others;

end architecture ALU_Arch;