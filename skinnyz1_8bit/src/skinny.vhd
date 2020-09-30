library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity SKINNY is 
port ( KeyByte:      in std_logic_vector(7 downto 0); 
       PTByte:       in std_logic_vector(7 downto 0); 
       Clk:         in std_logic; 
       Rst:         in std_logic; 
       CT:          out std_logic_vector(7 downto 0));
end entity SKINNY;


architecture comb of SKINNY is
 
    
    signal SboxOUT:         std_logic_vector(7 downto 0);
    signal SboxIN:          std_logic_vector(7 downto 0);
    signal roundkeybyte:    std_logic_vector(7 downto 0);
    
    signal MCin:            std_logic_vector(31 downto 0);
    signal MCout:           std_logic_vector(31 downto 0);
    
    signal swap_ctrl:       std_logic_vector(2 downto 0); 
    signal load_mc:         std_logic; 
    signal load_sbox_st:    std_logic;
    signal init:            std_logic;
    signal swap_ctrl_k:     std_logic_vector(3 downto 0);
    signal rc_nibble:       std_logic_vector(3 downto 0);
    signal tick:            std_logic;
    signal rc:              std_logic_vector(5 downto 0);
    signal add_key:         std_logic;
    
    signal lfsr_ctl2:       std_logic_vector(1 downto 0);
    signal lfsr_ctl3:       std_logic;    
    
    signal key0:            std_logic_vector(7 downto 0);  
    signal key1:            std_logic_vector(7 downto 0);
    signal key2:            std_logic_vector(7 downto 0);
    
    
begin

    state_pipeline0:	entity state_pipeline(comb) port map(SboxIN, CT, MCin, Clk, swap_ctrl, load_mc, init, PTByte, roundkeybyte, SboxOUT, MCout, rc_nibble, add_key);

    sbox0:	            entity sbox(comb) port map (SboxIN, SboxOUT); 
    mc0:	            entity mix_col(comb) port map (MCin, MCout);
    lfsr0:	            entity lfsr(comb) port map (Clk, Rst, tick, rc);
    
    controller0:	    entity controller(comb) port map (Clk, Rst, rc, swap_ctrl, load_mc, init, swap_ctrl_k,  rc_nibble, tick, add_key);
    
    key_pipeline_tk0:	    entity key_pipeline1(comb) port map (key0, Clk, init, swap_ctrl_k, KeyByte);
    
    roundkeybyte <= key0;



end architecture comb;

