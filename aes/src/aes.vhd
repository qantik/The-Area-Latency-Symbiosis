library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity AES is port (
    KeyBit:      in std_logic;
    PTBit:       in std_logic;
    Clk:         in std_logic;
    Rst:         in std_logic;
    CT:          out std_logic
    );
end entity AES;


architecture behav of AES is

    signal SboxOUT:         std_logic_vector(7 downto 0);
    signal SboxIN_K:        std_logic_vector(7 downto 0);
    signal SboxIN_S:        std_logic_vector(7 downto 0);
    signal SboxIN:          std_logic_vector(7 downto 0);
    signal roundkeybit:     std_logic;
    signal notLSB:          std_logic;
    signal Poly:            std_logic;
    signal MCin0:           std_logic_vector(3 downto 0);
    signal MCin1:           std_logic_vector(3 downto 0);
    signal MCout:           std_logic_vector(3 downto 0);
    signal swap_ctrl:       std_logic_vector(2 downto 0); 
    signal load_mc:         std_logic; 
    signal load_sbox_st:    std_logic;
    signal load_sbox_key:   std_logic;
    signal init:            std_logic;
    signal add_rc:          std_logic;
    signal mctrigger:       std_logic;
    signal sbox_sel:        std_logic;
    signal swap_ctrl_k:     std_logic_vector(1 downto 0);
    signal kxor:            std_logic;

begin

    state_pipeline0:        entity state_pipeline(behav) port map(SboxIN_S, CT, MCin0, MCin1, Clk, swap_ctrl, load_mc, load_sbox_st, init, PTBit, roundkeybit, SboxOUT, MCout);
    key_pipeline0:          entity key_pipeline(behav) port map (roundkeybit, SboxIN_K, Clk, init, swap_ctrl_k, load_sbox_key, add_rc, kxor, KeyBit, SboxOUT);
    sbox0:                  entity sbox(maximov) port map (SboxIN, SboxOUT); 
    mc0:                    entity mix_col_slice(behav) port map (MCin0, MCin1, notLSB, Poly, mctrigger, Clk, MCout);
    controller0:            entity controller(behav) port map (Clk, Rst, swap_ctrl, load_mc, load_sbox_st, load_sbox_key, init, add_rc, notLSB, Poly, mctrigger, sbox_sel, swap_ctrl_k, kxor);

    SboxIN <= SboxIN_K when sbox_sel = '1' else SboxIN_S;

end architecture behav;
