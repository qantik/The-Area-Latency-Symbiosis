library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;



entity testbench is
end testbench;



architecture tb of testbench is   

	constant quarter : time := 25 ns;
	constant clkphase: time:= 50 ns;
	file infile, ansfile, outfile : TEXT;	
	
	signal PTByte, CTByte : std_logic_vector(7 downto 0);	
	signal ClkxC, Reset, Ready: std_logic;	
	signal KeyByte:  std_logic_vector(23 downto 0);
	constant total_cycles : integer := 16*57;
	
	component SKINNY 
       port ( 
       KeyByte:      in std_logic_vector(23 downto 0); 
       PTByte:       in std_logic_vector(7 downto 0); 
       Clk:          in std_logic; 
       Rst:          in std_logic; 
       CT:           out std_logic_vector(7 downto 0));
	end component SKINNY;



begin

	mut: SKINNY port map (KeyByte, PTByte, ClkxC, Reset, CTByte);

	process
	begin
		ClkxC <= '1'; wait for clkphase;
		ClkxC <= '0'; wait for clkphase;
	end process;
	
	process
	begin
		Reset <= '0'; wait for quarter;
		Reset <= '1'; wait for 2*total_cycles*clkphase - quarter;
	end process;

	process
		variable INLine : line;
		variable pt128, ct128, k0, k1, k2, tmp : std_logic_vector(127 downto 0);
	begin
		file_open(infile, "../src/PTKEY", read_mode);
		
		while not (endfile(infile)) loop
		--for r in 1 to 5 loop
		    
			readline(infile, INLine);	hread(INLine, k0);
			readline(infile, INLine);	hread(INLine, k1);
			readline(infile, INLine);	hread(INLine, k2);
			readline(infile, INLine);	hread(INLine, pt128);
			readline(infile, INLine);	hread(INLine, ct128);
						
			wait for 2*quarter;
			-- load 
			for i in 0 to 15 loop
				KeyByte(23 downto 16) <= k0(127 - 8*i downto 120 - 8*i);
				KeyByte(15 downto 8) <= k1(127 - 8*i downto 120 - 8*i);
				KeyByte(7 downto 0) <= k2(127 - 8*i downto 120 - 8*i);
				PTByte <= pt128(127 - 8*i downto 120 - 8*i);
				wait for 2*clkphase;
			end loop;
			
			wait for 2*total_cycles*clkphase - 2*(32)*clkphase;
			
			for i in 0 to 14 loop
				tmp(127 - 8*i downto 120 - 8*i) := CTByte;
				wait for 2*clkphase;
			end loop;
			
			tmp(7 downto 0) := CTByte;
			wait for 2*quarter;
			
			assert tmp = ct128 report "======>>> DOES NOT MATCH <<<======" severity failure;
			report "succ + ";
		end loop;
		assert false report ">>> OK <<<" severity failure;
		wait;
	end process;
end tb;
