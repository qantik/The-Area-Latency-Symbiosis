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

	constant quarter : time := 25ns;
	constant clkphase: time:= 50 ns;
	file infile, ansfile, outfile : TEXT;	
		
	signal PTBit, CTBit, ClkxC, Reset, Ready: std_logic;	
	signal KeyBit:  std_logic_vector(1 downto 0);
	constant total_cycles : integer := 128*49;
	
	component SKINNY 
       port ( 
       KeyBit:      in std_logic_vector(1 downto 0); 
       PTBit:       in std_logic; 
       Clk:         in std_logic; 
       Rst:         in std_logic; 
       CT:          out std_logic);
	end component SKINNY;



begin

	mut: SKINNY port map (KeyBit, PTBit, ClkxC, Reset, CTBit);

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
		file_open(infile, "PTKEY", read_mode);
		
		while not (endfile(infile)) loop
		    
			readline(infile, INLine);	hread(INLine, k0);
			readline(infile, INLine);	hread(INLine, k1);
			readline(infile, INLine);	hread(INLine, pt128);
			readline(infile, INLine);	hread(INLine, ct128);
						
			wait for 2*quarter;
			-- load 
			for i in 127 downto 0 loop
				KeyBit(0) <= k0(i);
				KeyBit(1) <= k1(i);
				PTBit <= pt128(i);
				wait for 2*clkphase;
			end loop;
			
			wait for 2*total_cycles*clkphase - 2*(256)*clkphase;
			
			for i in 127 downto 1 loop
				tmp(i) := CTBit;
				wait for 2*clkphase;
			end loop;
			
			tmp(0) := CTBit;
			wait for 2*quarter;
			
			assert tmp = ct128 report "======>>> DOES NOT MATCH <<<======" severity failure;
			report "succ + ";
		end loop;
		assert false report ">>> OK <<<" severity failure;
		wait;
	end process;
end tb;
