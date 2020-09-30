library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity controller is 
port ( Clk:             in std_logic; 
       Rst:             in std_logic; 
       rc:              in std_logic_vector(5 downto 0);
       swap_ctrl:       out std_logic_vector(2 downto 0); 
       load_mc:         out std_logic; 
       load_sbox_st:    out std_logic;
       swap_ctrl_k:     out std_logic_vector(3 downto 0);
       rc_bit:          out std_logic;
       tick:            out std_logic;
       add_key:         out std_logic;
       lfsr_ctl2:       out std_logic_vector(1 downto 0);
       rot:             out std_logic;
       round_out:       out std_logic_vector(5 downto 0);
       count_out:       out std_logic_vector(6 downto 0)
       );
end entity controller;


architecture behav of controller is
 

    signal count:       std_logic_vector(6 downto 0); 
    signal round:       std_logic_vector(5 downto 0);
    signal ctr:         std_logic_vector(12 downto 0);
    
    signal ctr_i:       integer range 0 to 8191;

    

begin

    count_out <= count;
    round_out <= round;

    count <= ctr(6 downto 0);
    round <= ctr(12 downto 7);
    ctr   <= std_logic_vector(to_unsigned(ctr_i, 13));

    process (Clk)
    begin
        if rising_edge(Clk) then
            ctr_i <= (ctr_i + 1) mod 8192;
            if Rst = '0' then
                ctr_i <= 0;
            end if;
        end if;
    end process;

    --sbox_sel <= '1' when count(2 downto 0) = "000" else '0';

    -- control logic for MixColumn 
    --notLSB <= '0' when ctr(2 downto 0) = "111" else '1';
    --Poly <= '0' when (ctr(2 downto 1) = "00" or ctr(2 downto 0) = "010" or ctr(2 downto 0) = "101") else '1';
    --mctrigger <= '1' when ctr(2 downto 0) = "000" else '0';

process (round, count, rc)
	variable round_i : integer range 0 to 63;
	variable count_i : integer range 0 to 127;
begin
    round_i := to_integer(unsigned(round));
    count_i := to_integer(unsigned(count));

    load_sbox_st <= '0';
    swap_ctrl <= "000";
    load_mc <= '0';      
    swap_ctrl_k <= "0000";
    tick <= '0';
    add_key <= '0';
    lfsr_ctl2 <= "00";
    rc_bit <= '0';
    rot <= '0';
    
    if count_i mod 8 = 0 then
        load_sbox_st <= '1';
    end if;
    
    if (count_i >= 112 or count_i < 8) or
       (count_i >= 64 and count_i < 72) then
           swap_ctrl(0) <= '1'; 
    end if;
    if (count_i >= 88 and count_i < 104) or (count_i >= 64 and count_i < 72) then
           swap_ctrl(1) <= '1'; 
    end if;
    if (count_i >= 64 and count_i < 72) then
           swap_ctrl(2) <= '1'; 
    end if;
    
    if count_i < 32 then
        load_mc <= '1';
    end if;
    
    
    if count_i = 78 then
        rc_bit <= '1';
        tick <= '1';
    elsif count_i = 12 or count_i = 13 or count_i = 14 or count_i = 15 or count_i =46 or count_i = 47 then
        rot <= '1';
        rc_bit <= rc(3);
    end if;
    
    
    if (count_i >= 72 or count_i < 8) then
           swap_ctrl_k(0) <= '1'; 
    end if;
    if count_i >= 120  then
           swap_ctrl_k(1) <= '1'; 
    end if;
    if (count_i >= 112 or count_i < 8) then
           swap_ctrl_k(2) <= '1'; 
    end if;
    if (count_i >= 120 or count_i < 8) or (count_i >= 24 and count_i <32) then
           swap_ctrl_k(3) <= '1'; 
    end if;
    
    if count_i >= 8 and count_i < 72 then
        add_key <= '1';
    end if;
    
    if count_i < 7 or
        (count_i >= 8 and count_i < 15) or
        (count_i >= 16 and count_i < 23) or
        (count_i >= 24 and count_i < 31) or
        (count_i >= 32 and count_i < 39) or
        (count_i >= 40 and count_i < 47) or
        (count_i >= 48 and count_i < 55) or
        (count_i >= 56 and count_i < 63) then
        lfsr_ctl2(1) <= '1';
    end if;
    
    if count_i = 0 or count_i = 8 or count_i = 16 or count_i = 24 or
    count_i = 32 or count_i = 40 or count_i = 48 or count_i = 56 then
        lfsr_ctl2(0) <= '1';
    end if;
         
        
end process;



end architecture;

