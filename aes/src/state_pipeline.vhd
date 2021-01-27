library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity state_pipeline is port (
    SboxIN:        out std_logic_vector(7 downto 0);
    CT:            out std_logic;
    MCin0:         out std_logic_vector(3 downto 0);
    MCin1:         out std_logic_vector(3 downto 0);
    Clk:           in std_logic;
    swap_ctrl:     in std_logic_vector(2 downto 0);
    store_mc:      in std_logic;
    store_sbox:    in std_logic;
    init:          in std_logic;
    newbit:        in std_logic;
    keybit:        in std_logic;
    SboxOUT:       in std_logic_vector(7 downto 0);
    MCout:         in std_logic_vector(3 downto 0)
    );
end entity state_pipeline;


architecture behav of state_pipeline is

    signal st_p:      std_logic_vector(127 downto 0); 
    signal st_n:      std_logic_vector(127 downto 0); 
    signal sbox_in:   std_logic;

    procedure rotate (
        variable s:     inout std_logic_vector(127 downto 0);
        variable b:     in std_logic
        ) is
    begin
        s := s(126 downto 0) & b;
    end procedure rotate;

    procedure swap (
        variable a:     inout std_logic; 
        variable b:     inout std_logic
        ) is
        variable tmp:   std_logic;
    begin
        tmp := a;
        a := b;
        b := tmp;
    end procedure swap;

begin

    SBoxIN <= st_p(6 downto 0) & sbox_in;

    process (Clk)
    begin
        if Clk'event and Clk = '1' then
            st_p <= st_n;
        end if;
    end process;

    process (st_p, newbit, keybit, SboxOUT, MCout, store_sbox, swap_ctrl, store_mc, init)
        variable s:          std_logic_vector(127 downto 0);
        variable nextbit:    std_logic;
    begin
        s := st_p;

        if store_sbox = '1' then
            s(6 downto 0) := SboxOUT(7 downto 1);
        end if;

        if swap_ctrl(0) = '1' then
            swap(s(127 - 80), s(127 - 112)); 
        end if;
        if swap_ctrl(1) = '1' then
            swap(s(127 - 56), s(127 - 120)); 
        end if;
        if swap_ctrl(2) = '1' then
            swap(s(127-121), s(127 - 25));
        end if;

        MCin0 <= s(127) & s(119) & s(111) & s(103);
        MCin1 <= s(126) & s(118) & s(110) & s(102);
        if store_mc = '1' then
            s(127) := MCout(3);
            s(127 - 8) := MCout(2);
            s(127 - 16) := MCout(1);
            s(127 - 24) := MCout(0);
        end if;

        sbox_in <= s(127) xor keybit;
        if init = '1' then 
            sbox_in <= newbit xor keybit;
            nextbit := newbit xor keybit;
            if store_sbox = '1' then
                nextbit := SboxOUT(0);
            end if;
        else
            if store_sbox = '0' then
                nextbit := s(127) xor keybit;
            else
                sbox_in <= s(127) xor keybit;
                nextbit := SboxOUT(0);
            end if;
        end if;

        CT <= s(127) xor keybit;

        rotate(s, nextbit);

        st_n <= s;
    end process;

end architecture behav;

