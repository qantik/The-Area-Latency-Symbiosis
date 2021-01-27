library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity AES is port (
    KeyBit:      in std_logic_vector(7 downto 0);
    PTBit:       in std_logic_vector(7 downto 0);
    Clk:         in std_logic; 
    Rst:         in std_logic; 
    CT:          out std_logic_vector(7 downto 0)
    );
end entity AES;


architecture behav of AES is

    signal SboxOUT_S:       std_logic_vector(7 downto 0);
    signal SboxOUT_K:       std_logic_vector(7 downto 0);
    signal SboxIN_K:        std_logic_vector(7 downto 0);
    signal SboxIN_S:        std_logic_vector(7 downto 0);
    signal m0:              std_logic_vector(7 downto 0);
    signal m1:              std_logic_vector(7 downto 0);
    signal m2:              std_logic_vector(7 downto 0);
    signal m3:              std_logic_vector(7 downto 0);
    signal roundkeybyte:    std_logic_vector(7 downto 0);
    signal notLSB:          std_logic;
    signal Poly:            std_logic;
    signal MCout:           std_logic_vector(31 downto 0);
    signal rcout:           std_logic_vector(7 downto 0);
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
    signal mcx1:            std_logic;

begin

    state_pipeline0:   entity state_pipeline(behav) port map(SboxIN_S, CT, m0,m1,m2,m3, Clk, swap_ctrl, load_mc, load_sbox_st, init,mcx1, PTBit, roundkeybyte, SboxOUT_S, MCout);
    key_pipeline0:     entity key_pipeline(behav) port map (roundkeybyte, SboxIN_K, Clk, init, swap_ctrl_k, load_sbox_key, add_rc, kxor, KeyBit, SboxOUT_K,rcout);
    sbox0:             entity sbox(maximov) port map (SboxIN_S, SboxOUT_S);
    sbox1:             entity sbox(maximov) port map (SboxIN_K, SboxOUT_K);
    mc:                entity mixcol(maximov) port map (m0,m1,m2,m3,MCout);
    controller0:       entity controller(behav) port map (Clk, Rst, swap_ctrl, load_mc, load_sbox_st, load_sbox_key, init, add_rc,   swap_ctrl_k, kxor,mcx1,rcout);

end architecture behav;

