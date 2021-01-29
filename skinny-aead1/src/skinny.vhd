library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity SKINNY is 
port ( KeyBit:      in std_logic_vector(2 downto 0); 
       PTBit:       in std_logic; 
       Clk:         in std_logic; 
       Rst:         in std_logic; 
       CT:          out std_logic;
       rc:              in std_logic_vector(5 downto 0);
       swap_ctrl:       in std_logic_vector(2 downto 0); 
       load_mc:         in std_logic; 
       load_sbox_st:    in std_logic;
       init:            in std_logic;
       swap_ctrl_k:     in std_logic_vector(3 downto 0);
       rc_bit:          in std_logic;
       tick:            in std_logic;
       add_key:         in std_logic;
       lfsr_ctl2:       in std_logic_vector(1 downto 0);
       lfsr_ctl3:       in std_logic;
       rot:             in std_logic
       );
end entity SKINNY;


architecture behav of SKINNY is

    signal SboxOUT:         std_logic_vector(7 downto 0);
    signal SboxIN:          std_logic_vector(7 downto 0);
    signal roundkeybit:     std_logic;
    signal MCin:            std_logic_vector(3 downto 0);
    signal MCout:           std_logic_vector(3 downto 0);
    signal key0:            std_logic;  
    signal key1:            std_logic;
    signal key2:            std_logic;
 
    
begin

    state_pipeline0:	entity state_pipeline(behav) port map(SboxIN, CT, MCin, Clk, swap_ctrl, load_mc, load_sbox_st, init, PTBit, roundkeybit, SboxOUT, MCout, rc_bit, add_key);

    sbox0:	            entity sbox(behav) port map (SboxIN, SboxOUT); 
    mc0:	            entity mix_col_slice(behav) port map (MCin, MCout);
   -- lfsr0:	            entity lfsr(behav) port map (Clk, Rst, tick, rot, rc);
    
   -- controller0:	    entity controller(behav) port map (Clk, Rst, rc, swap_ctrl, load_mc, load_sbox_st, init, swap_ctrl_k,  rc_bit, tick, add_key, lfsr_ctl2, lfsr_ctl3, rot);
    
    key_pipeline_tk0:	    entity key_pipeline1(behav) port map (key0, Clk, init, swap_ctrl_k, KeyBit(0));
    key_pipeline_tk1:	    entity key_pipeline2(behav) port map (key1, Clk, init, swap_ctrl_k, lfsr_ctl2, KeyBit(1));
    key_pipeline_tk2:	    entity key_pipeline3(behav) port map (key2, Clk, init, swap_ctrl_k, lfsr_ctl3, KeyBit(2));
    
    roundkeybit <= key0 xor key1 xor key2;


end architecture behav;
