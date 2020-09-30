library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity aead is
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic;
          nonce : in std_logic;

          -- A data block is either associated data or plaintext.
          -- last_block indicates whether the current ad or plaintext
          -- block is the last one with last_partial indicating whether
          -- said block is only partially filled.
          data         : in std_logic;
          last_block   : in std_logic;
          last_partial : in std_logic;

          empty_ad     : in std_logic; -- Constant, set at the beginning.
          odd_ad_blocks: in std_logic; -- Constant, set at the beginning.
          empty_msg    : in std_logic; -- Constant, set at the beginning.


          ready_key    : out std_logic; -- Expecting key to be loaded in the following cycle.
          
          ready_block  : out std_logic; -- Expecting new block at next rising edge.
          ready_full   : out std_logic; -- AEAD finished.

          -- Indication signals that tell whether current value on either
          -- the ciphertext or tag output pins is valid.
          cipher_ready : out std_logic;
          tag_ready    : out std_logic;

          ciphertext   : out std_logic;
          tag          : out std_logic;
          
          statebit:         out std_logic;
          ct_bit:          out std_logic;
          k1_bit          : out std_logic;
          k2_bit          : out std_logic;
          k3_bit          : out std_logic
          );
end;

architecture behav of aead is
 
    signal KeyBit:          std_logic_vector(2 downto 0); 
    signal CT:              std_logic;
    
    signal SboxOUT:         std_logic_vector(7 downto 0);
    signal SboxIN:          std_logic_vector(7 downto 0);
    signal roundkeybit:     std_logic;
    
    signal MCin:            std_logic_vector(3 downto 0);
    signal MCout:           std_logic_vector(3 downto 0);
    
    signal swap_ctrl:       std_logic_vector(2 downto 0); 
    signal load_mc:         std_logic; 
    signal load_sbox_st:    std_logic;
    signal init:            std_logic;
    signal key_init:        std_logic;
    signal swap_ctrl_k:     std_logic_vector(3 downto 0);
    signal rc_bit:          std_logic;
    signal tick:            std_logic;
    signal rc:              std_logic_vector(5 downto 0);
    signal add_key:         std_logic;
    
    signal lfsr_ctl2:       std_logic_vector(1 downto 0);
    signal lfsr_ctl3:       std_logic;    
    
    signal key0:            std_logic;  
    signal key1:            std_logic;
    signal key2:            std_logic;
    
    signal domain:          std_logic_vector(4 downto 0);
    
    signal rot:             std_logic;
    
    
    signal coreRound:       std_logic_vector(5 downto 0);
    signal coreCount:       std_logic_vector(6 downto 0);
    
    signal lfsr_rot:        std_logic;
    signal lfsr_tick:       std_logic;
    signal lfsr_one:        std_logic;
    signal lfsr_bit:        std_logic;
    signal en_xor_data:     std_logic;
    
    signal rho_overwrite_zero:  std_logic;
    
    signal core_reset:      std_logic;
    
    signal stateexit    : std_logic;
    
begin

    process (coreCount, lfsr_bit, domain, nonce)
        variable x : integer range 0 to 127;
    begin
        x := to_integer(unsigned(coreCount));
        if x < 56 then
            KeyBit(0) <= lfsr_bit;
        elsif x = 59 then
            KeyBit(0) <= domain(4);
        elsif x = 60 then
            KeyBit(0) <= domain(3);            
        elsif x = 61 then
            KeyBit(0) <= domain(2);        
        elsif x = 62 then
            KeyBit(0) <= domain(1);
        elsif x = 63 then
            KeyBit(0) <= domain(0);
        else
            KeyBit(0) <= '0';
        end if;
    end process;
    
    KeyBit(1) <= nonce;    
    KeyBit(2) <= key;

    state_pipeline0:	entity state_pipeline(behav) port map(SboxIN, stateexit, MCin, clk, swap_ctrl, load_mc, load_sbox_st, init, data, roundkeybit, SboxOUT, MCout, rc_bit, add_key, en_xor_data, statebit);

    sbox0:	            entity sbox(behav) port map (SboxIN, SboxOUT); 
    mc0:	            entity mix_col_slice(behav) port map (MCin, MCout);
    lfsr0:	            entity lfsr(behav) port map (clk, core_reset, tick, rot, rc);
    rho0:               entity rho(behav) port map (clk, coreCount, data, stateexit, rho_overwrite_zero, CT);
    
    
    controller0:	    entity controller(behav) port map (clk, core_reset, rc, swap_ctrl, load_mc, load_sbox_st, swap_ctrl_k,  rc_bit, tick, add_key, lfsr_ctl2, lfsr_ctl3, rot, coreRound, coreCount);
    
    controller1:        entity aead_controller(behav) port map (clk, reset, last_block, empty_ad, odd_ad_blocks, empty_msg, last_partial, coreRound, coreCount,
    domain, core_reset, 
    lfsr_rot, lfsr_tick, lfsr_one, en_xor_data, init, key_init, rho_overwrite_zero,
    ready_block, ready_key, cipher_ready, tag_ready, ready_full);
    
    lfsr56_0:           entity lfsr56(behav) port map (clk, lfsr_one, lfsr_tick, coreCount, lfsr_bit);
    
    key_pipeline_tk0:	    entity key_pipeline1(behav) port map (key0, clk, key_init, swap_ctrl_k, KeyBit(0));
    key_pipeline_tk1:	    entity key_pipeline2(behav) port map (key1, clk, key_init, swap_ctrl_k, lfsr_ctl2, KeyBit(1));
    key_pipeline_tk2:	    entity key_pipeline3(behav) port map (key2, clk, key_init, swap_ctrl_k, lfsr_ctl3, KeyBit(2));
    
    
    k1_bit <= KeyBit(0);
    k2_bit <= KeyBit(1);
    k3_bit <= KeyBit(2);
    ct_bit <= stateexit;
    tag <= CT;
    ciphertext <= CT;
    roundkeybit <= key0 xor key1 xor key2;


end architecture behav;

