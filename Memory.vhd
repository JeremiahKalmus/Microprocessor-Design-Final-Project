--------------------------------------------------------------------------------
--
-- LAB #5 - Memory and Register Bank
--
--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity RAM is
    Port(Reset:	  in std_logic;
	 Clock:	  in std_logic;	 
	 OE:      in std_logic;
	 WE:      in std_logic;
	 Address: in std_logic_vector(29 downto 0);
	 DataIn:  in std_logic_vector(31 downto 0);
	 DataOut: out std_logic_vector(31 downto 0));
end entity RAM;

architecture staticRAM of RAM is

   type ram_type is array (0 to 127) of std_logic_vector(31 downto 0);
   signal i_ram : ram_type;

begin

  RamProc: process(Clock, Reset, OE, WE, Address) is
  begin

    if Reset = '1' then
	for i in 0 to 127 loop
		i_ram(i) <= X"00000000";
	end loop;
    end if;

    if (falling_edge(Clock)) then
	if(WE = '1' AND Address < X"80") then
		i_ram(to_integer(unsigned(Address))) <= DataIn;
	end if;
    end if;

    if (OE = '0' AND Address < X"80") then
	DataOut <= i_ram(to_integer(unsigned(Address)));
    else 
	DataOut <= "ZZZZZZZZ"&"ZZZZZZZZ"&"ZZZZZZZZ"&"ZZZZZZZZ";
    end if;
  end process RamProc;

end staticRAM;	
--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity Registers is
    Port(ReadReg1: in std_logic_vector(4 downto 0); 
         ReadReg2: in std_logic_vector(4 downto 0); 
         WriteReg: in std_logic_vector(4 downto 0);
	 WriteData: in std_logic_vector(31 downto 0);
	 WriteCmd: in std_logic;
	 ReadData1: out std_logic_vector(31 downto 0);
	 ReadData2: out std_logic_vector(31 downto 0));
end entity Registers;

architecture remember of Registers is
	component register32
  	    port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
	end component;
	signal OutBus: std_logic_vector(287 downto 0);
	signal Writeable: std_logic_vector(8 downto 0);
begin
	Writeable(0) <= '0';
	Writeable(1) <= '1' when (WriteReg = "10000" AND WriteCmd = '1') else '0';	--s0
	Writeable(2) <= '1' when (WriteReg = "10001" AND WriteCmd = '1') else '0';
	Writeable(3) <= '1' when (WriteReg = "10010" AND WriteCmd = '1') else '0';
	Writeable(4) <= '1' when (WriteReg = "10011" AND WriteCmd = '1') else '0';
	Writeable(5) <= '1' when (WriteReg = "10100" AND WriteCmd = '1') else '0';
	Writeable(6) <= '1' when (WriteReg = "10101" AND WriteCmd = '1') else '0';
	Writeable(7) <= '1' when (WriteReg = "10110" AND WriteCmd = '1') else '0';
	Writeable(8) <= '1' when (WriteReg = "10111" AND WriteCmd = '1') else '0';	--s7

ZO: register32 PORT MAP (WriteData(31 downto 0),'0','0','0', Writeable(0),Writeable(0),Writeable(0),OutBus(31 downto 0));
S0: register32 PORT MAP (WriteData(31 downto 0),'0','0','0', Writeable(1),Writeable(1),Writeable(1),OutBus(63 downto 32));
S1: register32 PORT MAP (WriteData(31 downto 0),'0','0','0', Writeable(2),Writeable(2),Writeable(2),OutBus(95 downto 64));
S2: register32 PORT MAP (WriteData(31 downto 0),'0','0','0', Writeable(3),Writeable(3),Writeable(3),OutBus(127 downto 96));
S3: register32 PORT MAP (WriteData(31 downto 0),'0','0','0', Writeable(4),Writeable(4),Writeable(4),OutBus(159 downto 128));
S4: register32 PORT MAP (WriteData(31 downto 0),'0','0','0', Writeable(5),Writeable(5),Writeable(5),OutBus(191 downto 160));
S5: register32 PORT MAP (WriteData(31 downto 0),'0','0','0', Writeable(6),Writeable(6),Writeable(6),OutBus(223 downto 192));
S6: register32 PORT MAP (WriteData(31 downto 0),'0','0','0', Writeable(7),Writeable(7),Writeable(7),OutBus(255 downto 224));
S7: register32 PORT MAP (WriteData(31 downto 0),'0','0','0', Writeable(8),Writeable(8),Writeable(8),OutBus(287 downto 256));

with ReadReg1 select
	ReadData1 <= 	OutBus(31 downto 0) when "00000", 
			OutBus(63 downto 32) when "10000",
			OutBus(95 downto 64) when "10001",
			OutBus(127 downto 96) when "10010", 
			OutBus(159 downto 128) when "10011",
			OutBus(191 downto 160) when "10100",
			OutBus(223 downto 192) when "10101", 
			OutBus(255 downto 224) when "10110",
			OutBus(287 downto 256) when "10111",
			"ZZZZZZZZ"&"ZZZZZZZZ"&"ZZZZZZZZ"&"ZZZZZZZZ" when others;

with ReadReg2 select
	ReadData2 <= 	OutBus(31 downto 0) when "00000", 
			OutBus(63 downto 32) when "10000",
			OutBus(95 downto 64) when "10001",
			OutBus(127 downto 96) when "10010", 
			OutBus(159 downto 128) when "10011",
			OutBus(191 downto 160) when "10100",
			OutBus(223 downto 192) when "10101", 
			OutBus(255 downto 224) when "10110",
			OutBus(287 downto 256) when "10111",
			"ZZZZZZZZ"&"ZZZZZZZZ"&"ZZZZZZZZ"&"ZZZZZZZZ" when others;
			

end remember;
----------------------------------------------------------------------------------------------------------------------------------------------------------------