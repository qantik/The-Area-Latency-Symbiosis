library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity state_pipeline is 
port (  SboxIN:     out std_logic_vector(7 downto 0);
        CT:         out std_logic_vector(7 downto 0);
        MCin0:      out std_logic_vector(7 downto 0);
        MCin1:      out std_logic_vector(7 downto 0);
        MCin2:      out std_logic_vector(7 downto 0);
        MCin3:      out std_logic_vector(7 downto 0);

        Clk:        in std_logic;
        swap_ctrl:  in std_logic_vector(2 downto 0);

        store_mc:   in std_logic;
        store_sbox: in std_logic;
        init:       in std_logic;
        mcx1:       in std_logic;
		newbyte:    in std_logic_vector(7 downto 0);
		keybyte:    in std_logic_vector(7 downto 0);
                skeybyte:    in std_logic_vector(7 downto 0);
                fkeybyte:    in std_logic_vector(7 downto 0);
		SboxOUT:    in std_logic_vector(7 downto 0);
		MCout:      in std_logic_vector(31 downto 0)
		);
end entity state_pipeline;


architecture behav of state_pipeline is

signal st_p, st_n: std_logic_vector(127 downto 0); 
signal sbox_in : std_logic_vector(7 downto 0);

--signal MCin0, MCin1, MCin2, MCin3: std_logic_vector(7 downto 0);


procedure rotate (
	variable s : inout std_logic_vector(127 downto 0);
	variable b:	in std_logic_vector(7 downto 0) 
	) is
	begin
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

 SBoxIN <=   sbox_in;

process (Clk)
begin
	if Clk'event and Clk = '1' then
		st_p <= st_n;
	end if;
end process;



process (st_p, newbyte, keybyte, SboxOUT, MCout, store_sbox, swap_ctrl, store_mc, init,mcx1)
	variable s : std_logic_vector(127 downto 0);
	variable nextbyte,sb,u:	std_logic_vector(7 downto 0);
begin
    s := st_p;
        
    u:=s(127 - 120 downto 120 - 120);
    
    if swap_ctrl(0) = '1' then
        swap(s(127 - 80 downto 120 - 80), s(127 - 112 downto 120 - 112)); 
    end if;

    if swap_ctrl(2) = '1' then
        swap(s(127-120 downto 120 - 120), s(127 - 24 downto 120 - 24));
    end if;
    
    if swap_ctrl(1) = '1' then
        swap(s(127 - 56 downto 120 - 56), s(127 - 120 downto 120 - 120)); 
    end if;

    -- mixColumn 
   MCin0<= s(127 downto 120);
   MCin1<= s(119 downto 112); 
   MCin2<= s(111 downto 104);  
   --MCin3<= s(103 downto 96); 
   if mcx1='1' then
     MCin3<= u;--s(127 - 56 downto 120 - 56);
   else
     MCin3<= s(103 downto 96);      
   end if;

    if store_mc = '1' then
        s(127 downto 120) := MCout(31 downto 24);
        s(119 downto 112) := MCout(23 downto 16);
        s(111 downto 104) := MCout(15 downto 8);
        s(103 downto 96) := MCout(7 downto 0);
 
    end if;
    


    if init = '1' then 
        sbox_in <= newbyte xor skeybyte;
        
    else
        sbox_in <=  s(127 downto 120) xor keybyte;
    end if;
        
    CT <= s(127 downto 120) xor fkeybyte;

    sb:= SboxOUT;
	rotate(s, sb);
	
	st_n <= s;
end process;

end architecture behav;

