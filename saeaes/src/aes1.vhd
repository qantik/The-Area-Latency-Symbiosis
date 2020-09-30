library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity AES is 
port ( KeyBit:      in std_logic; 
       PTBit:       in std_logic; 
       Clk:         in std_logic; 
       Rst:         in std_logic;
       swap_ctrl:       in std_logic_vector(2 downto 0); 
       load_mc:         in std_logic; 
       load_sbox_st:    in std_logic;
       load_sbox_key:   in std_logic;
       init:            in std_logic;
       add_rc:          in std_logic;
       notLSB:          in std_logic;
       Poly:            in std_logic;
       mctrigger:       in std_logic;
       sbox_sel:        in std_logic;
       swap_ctrl_k:     in std_logic_vector(1 downto 0);
       kxor:            in std_logic; 
       CT:              out std_logic);
end entity AES;


architecture behav of AES is
 
    
    signal SboxOUT:     std_logic_vector(7 downto 0);
    signal SboxIN_K, SboxIN_S, SboxIN:      std_logic_vector(7 downto 0);
    signal roundkeybit,fkeybit: std_logic;
    
   -- signal notLSB, Poly : std_logic;
    signal MCin0, MCin1, MCout: std_logic_vector(3 downto 0);
    
 
begin

    state_pipeline0:	entity state_pipeline(behav) port map(SboxIN_S, CT, MCin0, MCin1, Clk, swap_ctrl, load_mc, load_sbox_st, init, PTBit, roundkeybit,KeyBit,fkeybit, SboxOUT, MCout);
    key_pipeline0:	    entity key_pipeline(behav) port map (roundkeybit,fkeybit, SboxIN_K, Clk, init, swap_ctrl_k, load_sbox_key, add_rc, kxor, KeyBit, SboxOUT);
    sbox0:	            entity sbox(maximov) port map (SboxIN, SboxOUT); 
    mc0:	            entity mix_col_slice(behav) port map (MCin0, MCin1, notLSB, Poly, mctrigger, Clk, MCout);
    
    --controller0:	    entity controller(behav) port map (Clk, Rst, swap_ctrl, load_mc, load_sbox_st, load_sbox_key, init, add_rc, notLSB, Poly, mctrigger, sbox_sel, swap_ctrl_k, kxor);

    SboxIN <= SboxIN_K when sbox_sel = '1' else SboxIN_S;

    
  



end architecture behav;

