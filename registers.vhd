--------------------------------------------------------------------------------
--
-- LAB #3
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity bitstorage is
	port(bitin: in std_logic;
		 enout: in std_logic;
		 writein: in std_logic;
		 bitout: out std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
	signal q: std_logic := '0';
begin
	process(writein) is
	begin
		if (rising_edge(writein)) then
			q <= bitin;
		end if;
	end process;
	
	-- Note that data is output only when enout = 0	
	bitout <= q when enout = '0' else 'Z';
end architecture memlike;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity fulladder is
    port (a : in std_logic;
          b : in std_logic;
          cin : in std_logic;
          sum : out std_logic;
          carry : out std_logic
         );
end fulladder;

architecture addlike of fulladder is
begin
  sum   <= a xor b xor cin; 
  carry <= (a and b) or (a and cin) or (b and cin); 
end architecture addlike;


--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
end entity register8;

architecture memmy of register8 is
	component bitstorage
		port(bitin: in std_logic;
		     enout: in std_logic;
		     writein: in std_logic;
		     bitout: out std_logic);
	end component;
begin
	BR0: bitstorage PORT MAP (datain(0), enout, writein, dataout(0));
	BR1: bitstorage PORT MAP (datain(1), enout, writein, dataout(1));
	BR2: bitstorage PORT MAP (datain(2), enout, writein, dataout(2));
	BR3: bitstorage PORT MAP (datain(3), enout, writein, dataout(3));
	BR4: bitstorage PORT MAP (datain(4), enout, writein, dataout(4));
	BR5: bitstorage PORT MAP (datain(5), enout, writein, dataout(5));
	BR6: bitstorage PORT MAP (datain(6), enout, writein, dataout(6));
	BR7: bitstorage PORT MAP (datain(7), enout, writein, dataout(7));
	
end architecture memmy;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register32 is
	port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
end entity register32;

architecture biggermem of register32 is
	component register8
		port(datain: in std_logic_vector(7 downto 0);
	    	     enout:  in std_logic;
	   	     writein: in std_logic;
	    	     dataout: out std_logic_vector(7 downto 0));
	end component;
	signal enoutsig, writesig: std_logic_vector(2 downto 0);
begin
	enoutsig(0) <= (enout32 AND enout16 AND enout8);
	enoutsig(1) <= (enout32 AND enout16);
	enoutsig(2) <= enout32;
	writesig(0) <= (writein32 OR writein16 OR writein8);
	writesig(1) <= (writein32 OR writein16);
	writesig(2) <= writein32;

	BY0: register8 PORT MAP (datain(7 downto 0), enoutsig(0), writesig(0), dataout(7 downto 0));
	BY1: register8 PORT MAP (datain(15 downto 8), enoutsig(1), writesig(1), dataout(15 downto 8));
	BY2: register8 PORT MAP (datain(23 downto 16), enoutsig(2), writesig(2), dataout(23 downto 16));
	BY3: register8 PORT MAP (datain(31 downto 24), enoutsig(2), writesig(2), dataout(31 downto 24));
	
end architecture biggermem;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
	port(	datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic);
end entity adder_subtracter;

architecture calc of adder_subtracter is
	signal data_a_extend, data_b_extend, dout: std_logic_vector(32 downto 0);
begin
	data_a_extend <= datain_a(31)&datain_a(31 downto 0);
	data_b_extend <= datain_b(31)&datain_b(31 downto 0);
with add_sub select
	dout	<= data_a_extend + data_b_extend when '0',
		   data_a_extend - data_b_extend when others;
	co <= dout(32);
	dataout <= dout(31 downto 0);
end architecture calc;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
	port(	datain: in std_logic_vector(31 downto 0);
	   	dir: in std_logic;
		shamt:	in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
end entity shift_register;

architecture shifter of shift_register is
	signal shift: std_logic_vector(2 downto 0);
begin
	shift <= shamt(1 downto 0)&dir;
with shift select 
	dataout <= 	datain(28 downto 0)&"000" when "111",
			datain(29 downto 0)&"00" when "101",
			datain(30 downto 0)&'0' when "011",
			datain(31)&datain(31 downto 1) when "010",
			datain(31)&datain(31)&datain(31 downto 2) when "100",
			datain(31)&datain(31)&datain(31)&datain(31 downto 3) when "110",
			datain when others;
end architecture shifter;