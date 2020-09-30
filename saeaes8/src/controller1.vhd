library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity controller is 
port ( Clk:             in std_logic; 
       Rst:             in std_logic; 
       SRst:            in std_logic; 
       swap_ctrl:       out std_logic_vector(2 downto 0); 
       load_mc:         out std_logic; 
       load_sbox_st:    out std_logic;
       load_sbox_key:   out std_logic;
       init:            out std_logic;
       add_rc:          out std_logic;
       notLSB:          out std_logic;
       Poly:            out std_logic;
       mctrigger:       out std_logic;
       sbox_sel:        out std_logic;
       swap_ctrl_k:     out std_logic_vector(1 downto 0);
       kxor:            out std_logic;
       ctr:             in std_logic_vector(10 downto 0) 
       );
end entity controller;


architecture behav of controller is
 

    signal count:       std_logic_vector(6 downto 0); 
    signal round:       std_logic_vector(3 downto 0);
 
   -- signal ctr:         std_logic_vector(10 downto 0);
   -- signal ctr_i,ctr_in:       integer range 0 to 2047;

    

begin


    count <= ctr(6 downto 0);
    round <= ctr(10 downto 7);


 

process (round, count)
	variable round_i : integer range 0 to 15;
	variable count_i : integer range 0 to 127;
begin
    round_i := to_integer(unsigned(round));
    count_i := to_integer(unsigned(count));

    sbox_sel <= '0';
    notLSB <= '1';
    mctrigger <= '0';
    Poly <= '1';
    
    if count_i mod 8 = 0 then
        sbox_sel <= '1';
        mctrigger <= '1';
    end if;
    
    if count_i mod 8 = 7 then
        notLSB <= '0';
    end if;
    
    if count_i mod 8 = 0 or count_i mod 8 = 1 or count_i mod 8 = 2 or count_i mod 8 = 5 then   
        Poly <= '0';
    end if;
    
    load_sbox_st <= '0';
    swap_ctrl <= "000";
    load_mc <= '0';      
    init <= '0';
    load_sbox_key <= '0';
    add_rc <= '0';
    swap_ctrl_k <= "00";
    kxor <= '0';
    
    if count_i mod 8 = 7 then
        load_sbox_st <= '1';
    end if;
    
    if (count_i >= 56 and count_i < 64) or
       (count_i >= 88 and count_i < 96) or
       (count_i >= 120) or 
       (count_i >= 8 and count_i < 16) then
           swap_ctrl(0) <= '1'; 
    end if;
    if (count_i >= 88 and count_i < 96) or
       (count_i >= 120) or
       count_i < 8 then
           swap_ctrl(1) <= '1'; 
    end if;
    if (count_i = 127 or count_i < 7) then
           swap_ctrl(2) <= '1'; 
    end if;
    
    if round_i < 10 and (count_i mod 32 >= 0) and (count_i mod 32 < 8) then
        load_mc <= '1';
    end if;
    
    if round_i = 0 or round_i=10 then 
        init <= '1';
    end if;
    
    
    
    
	if count_i < 8 then
	    swap_ctrl_k(0) <= '1';
	end if;
	if count_i >= 56 and count_i < 64 then
	    swap_ctrl_k(1) <= '1';
	end if;
	
	if count_i = 112 or count_i = 120 or count_i = 0 or count_i = 8 then
	    load_sbox_key <= '1';
	end if;
	
	-- keep a look-up table for the round constant bits	
    if 
	        (round_i=0 and count_i=111) or
	        (round_i=1 and count_i=110) or
	        (round_i=2 and count_i=109) or
	        (round_i=3 and count_i=108) or
	        (round_i=4 and count_i=107) or
	        (round_i=5 and count_i=106) or
	        (round_i=6 and count_i=105) or
	        (round_i=7 and count_i=104) or
	        (round_i=8 and count_i=111) or
	        (round_i=8 and count_i=110) or
	        (round_i=8 and count_i=108) or
	        (round_i=8 and count_i=107) or
	        (round_i=9 and count_i=110) or
	        (round_i=9 and count_i=109) or
	        (round_i=9 and count_i=107) or
	        (round_i=9 and count_i=106) or
                (round_i=10 and count_i=111)  then
	        
	    add_rc <= '1';
	end if;
	
	if count_i < 96 then
	    kxor <= '1';
	end if;
        
end process;

 

end architecture;

