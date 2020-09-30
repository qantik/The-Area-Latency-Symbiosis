library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity key_pipeline1 is 
port (  roundkeybyte: 		out std_logic_vector(7 downto 0);
        Clk:        		in std_logic;
        init:       		in std_logic;
        swap_ctrl_k: 		in std_logic_vector(3 downto 0);
        KeyByte:     		in std_logic_vector(7 downto 0)
		);
end entity key_pipeline1;


architecture comb of key_pipeline1 is
		
signal k_p, k_n: std_logic_vector(127 downto 0);

procedure rotate (
	variable s : inout std_logic_vector(127 downto 0);
	variable b:	in std_logic_vector(7 downto 0)
	) is
	begin
		--s := s(126 downto 0) & b;
		s := s(119 downto 0) & b;
	end rotate;

procedure swap (
	variable a: 	inout std_logic_vector(7 downto 0); 
	variable b:		inout std_logic_vector(7 downto 0)
	) is
		variable tmp : std_logic_vector(7 downto 0);
	begin
		tmp := a;
		a := b;
		b := tmp;
	end swap;
	
begin


process (Clk)
begin
	if Clk'event and Clk = '1' then
		k_p <= k_n;
	end if;
end process;

process (k_p, init, swap_ctrl_k, KeyByte)
	variable s : std_logic_vector(127 downto 0);
	variable nextbyte:	std_logic_vector(7 downto 0);
begin
    s := k_p;
    
    nextbyte := s(127 downto 120);
    if init = '1' then
        nextbyte := KeyByte;
    end if;
    
	
	if swap_ctrl_k(0) = '1' then
	    swap(s(127 - 56 downto 127 - 63), s(127 - 120 downto 127 - 127));
	end if;
	if swap_ctrl_k(1) = '1' then
	    swap(s(127 - 48 downto 127 - 55), s(127 - 56 downto 127 - 63));
	end if;
	if swap_ctrl_k(2) = '1' then
	    swap(s(127 - 24 downto 127 - 31), s(127 - 56 downto 127 - 63));
	end if;
	if swap_ctrl_k(3) = '1' then
	    swap(s(127 - 24 downto 127 - 31), s(127 - 8 downto 127 - 15));
	end if;

    
	rotate(s, nextbyte);
	
	
	
	roundkeybyte <= s(15 downto 8);
	k_n <= s;
end process;

end architecture;
