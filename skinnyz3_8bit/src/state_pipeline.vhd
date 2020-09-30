library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity state_pipeline is 
port (  SboxIN:     out std_logic_vector(7 downto 0);
        CT:         out std_logic_vector(7 downto 0);
        MCin:       out std_logic_vector(31 downto 0);
        Clk:        in std_logic;
        swap_ctrl:  in std_logic_vector(2 downto 0);
        store_mc:   in std_logic;
        init:       in std_logic;
		newbyte:	in std_logic_vector(7 downto 0);
		keybyte:    in std_logic_vector(7 downto 0);
		SboxOUT:    in std_logic_vector(7 downto 0);
		MCout:      in std_logic_vector(31 downto 0);
		rc_nibble:  in std_logic_vector(3 downto 0);
		add_key:    in std_logic
		);
end entity state_pipeline;


architecture comb of state_pipeline is

signal st_p, st_n: std_logic_vector(127 downto 0); 
signal sbox_in : std_logic;




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

SBoxIN <= st_p(7 downto 0);

process (Clk)
begin
	if Clk'event and Clk = '1' then
		st_p <= st_n;
	end if;
end process;



process (st_p, newbyte, keybyte, SboxOUT, MCout, swap_ctrl, store_mc, init, rc_nibble, add_key)
	variable s : std_logic_vector(127 downto 0);
	variable nextbyte:	std_logic_vector(7 downto 0);
begin
    s := st_p;
        
    -- subbyte (expect the last bit)
    s(7 downto 0) := SboxOUT;
    
    -- add round const
    s(3 downto 0) := s(3 downto 0) xor rc_nibble;
    
    
    -- add key
    if add_key = '1' then
        s(7 downto 0) := s(7 downto 0) xor keybyte;
    end if;
    
    -- shiftRow
    if swap_ctrl(2) = '1' then
        swap(s(127 - 96 downto 127 - 103), s(127 - 120 downto 127 - 127));
    end if;
    if swap_ctrl(1) = '1' then
        swap(s(127 - 104 downto 127 - 111), s(127 - 120 downto 127 - 127)); 
    end if;
    if swap_ctrl(0) = '1' then
        swap(s(127 - 112 downto 127 - 119), s(127 - 120 downto 127 - 127)); 
    end if;
    
    -- mixColumn 
    MCin <= s(127 downto 120) & s(95 downto 88) & s(63 downto 56) & s(31 downto 24);
    if store_mc = '1' then
        s(127 downto 120) := MCout(31 downto 24);
        s(95 downto 88)   := MCout(23 downto 16);
        s(63 downto 56)   := MCout(15 downto 8);
        s(31 downto 24)   := MCout(7 downto 0);
    end if;
    
    
        
    CT <= s(127 downto 120);
    
    if init = '1' then
        nextbyte := newbyte;
    else
        nextbyte := s(127 downto 120);
    end if;
	rotate(s, nextbyte);
	
	st_n <= s;
end process;

end architecture;

