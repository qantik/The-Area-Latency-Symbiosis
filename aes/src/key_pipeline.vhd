library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity key_pipeline is 
port (  roundkeybit: 		out std_logic;
        SboxIN:     out std_logic_vector(7 downto 0);
        Clk:        in std_logic;
        init:       in std_logic;
        swap_ctrl_k: in std_logic_vector(1 downto 0);
        load_sbox_key: in std_logic;
        add_rc:     in std_logic;
        kxor:       in std_logic;
        KeyBit:     in std_logic;
		SboxOUT:    in std_logic_vector(7 downto 0)
		);
end entity key_pipeline;


architecture behav of key_pipeline is
		
signal k_p, k_n: std_logic_vector(127 downto 0);
signal newbit: std_logic;

procedure rotate (
	variable s : inout std_logic_vector(127 downto 0);
	variable b:	in std_logic
	) is
	begin
		s := s(126 downto 0) & b;
	end rotate;

procedure swap (
	variable a: 	inout std_logic; 
	variable b:		inout std_logic
	) is
		variable tmp : std_logic;
	begin
		tmp := a;
		a := b;
		b := tmp;
	end swap;
	


	
begin

SboxIN <= k_p(7 downto 0);

newbit <= KeyBit when init='1' else k_p(127);
roundkeybit <= newbit;

process (Clk)
begin
	if Clk'event and Clk = '1' then
		k_p <= k_n;
	end if;
end process;

process (k_p, init, swap_ctrl_k, load_sbox_key, add_rc, kxor, newbit, SboxOUT)
	variable s : std_logic_vector(127 downto 0);
	variable nextbit:	std_logic;
begin
    s := k_p;
    
    nextbit := s(127);
    if init = '1' then
        nextbit := newbit;
    end if;
    
	
	if swap_ctrl_k(0) = '1' then
	    swap(s(127 - 96), nextbit);
	end if;
	if swap_ctrl_k(1) = '1' then
	    swap(s(127 - 72), s(127 - 40));
	end if;
	
	if load_sbox_key = '1' then
	    s(127-16 downto 127-23) := s(127-16 downto 127-23) xor SboxOUT;
	end if;
	
	-- keep a look-up table for the round constant bits	
    if add_rc = '1' then
	    s(127 - 24) := not s(127 - 24);
	end if;
	
	if kxor = '1' then
	    s(127 - 32) := s(127 - 32) xor s(127 - 0);
	end if;
	

	rotate(s, nextbit);
	
	k_n <= s;
end process;

end architecture behav;

