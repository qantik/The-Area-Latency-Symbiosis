library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity AES is 
port ( KeyBit:      in std_logic_vector(7 downto 0); 
       PTBit:       in std_logic_vector(7 downto 0); 
       Clk:         in std_logic; 
       Rst:         in std_logic; 
       swap_ctrl:       in std_logic_vector(2 downto 0); 
       load_mc:         in std_logic; 
       load_sbox_st:    in std_logic;
       load_sbox_key:   in std_logic;
       init:            in std_logic;
       add_rc:          in std_logic;
 
       swap_ctrl_k:     in std_logic_vector(1 downto 0);
       kxor:            in std_logic;
       mcx1:            in std_logic;
       rcout:           in std_logic_vector(7 downto 0)  ;
       CT:          out std_logic_vector(7 downto 0));
end entity AES;

architecture behav of AES is
 
    
    signal SboxOUT_S,SboxOUT_K:     std_logic_vector(7 downto 0);
    signal SboxIN_K, SboxIN_S, m0,m1,m2,m3:      std_logic_vector(7 downto 0);
    signal roundkeybyte,fkeybyte: std_logic_vector(7 downto 0);
    
   -- signal notLSB, Poly : std_logic;
    signal MCout: std_logic_vector(31 downto 0);
 
   
begin

    state_pipeline0:	    entity state_pipeline(behav) port map(SboxIN_S, CT, m0,m1,m2,m3, Clk, swap_ctrl, load_mc, load_sbox_st, init,mcx1, PTBit, roundkeybyte,KeyBit,fkeybyte, SboxOUT_S, MCout);
    key_pipeline0:	    entity key_pipeline(behav) port map (roundkeybyte,fkeybyte, SboxIN_K, Clk, init, swap_ctrl_k, load_sbox_key, add_rc, kxor, KeyBit, SboxOUT_K,rcout);
    sbox0:	            entity sbox(maximov) port map (SboxIN_S, SboxOUT_S); 
    sbox1:	            entity sbox(maximov) port map (SboxIN_K, SboxOUT_K); 
    
    mc:	                    entity mixcol(bal) port map (m0,m1,m2,m3,MCout);  
--    controller0:	    entity controller(behav) port map (Clk, Rst, swap_ctrl, load_mc, load_sbox_st, load_sbox_key, init, add_rc,   swap_ctrl_k, kxor,mcx1,rcout);

   -- SboxIN <= SboxIN_K when sbox_sel = '1' else SboxIN_S;

    




end architecture behav;

