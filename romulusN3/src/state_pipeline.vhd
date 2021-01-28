library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity state_pipeline is port (
    SboxIN:         out std_logic_vector(7 downto 0);
    CT:             out std_logic;
    MCin:           out std_logic_vector(3 downto 0);
    Clk:            in std_logic;
    swap_ctrl:      in std_logic_vector(2 downto 0);
    store_mc:       in std_logic;
    store_sbox:     in std_logic;
    init:           in std_logic;
    newbit:         in std_logic;
    keybit:         in std_logic;
    SboxOUT:        in std_logic_vector(7 downto 0);
    MCout:          in std_logic_vector(3 downto 0);
    rc_bit:         in std_logic;
    add_key:        in std_logic;
    en_xor_data:    in std_logic;
    tag:            out std_logic
    );
end entity state_pipeline;


architecture behav of state_pipeline is

    signal st_p:         std_logic_vector(127 downto 0);
    signal st_n:         std_logic_vector(127 downto 0);

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

    SBoxIN <= st_p(7 downto 0);

    process (Clk)
    begin
        if Clk'event and Clk = '1' then
            st_p <= st_n;
        end if;
    end process;

    process (st_p, newbit, keybit, SboxOUT, MCout, store_sbox, swap_ctrl, store_mc, init, rc_bit, add_key, en_xor_data)
        variable s:         std_logic_vector(127 downto 0);
        variable nextbit:   std_logic;
    begin
        s := st_p;

        if store_sbox = '1' then
            s(7 downto 0) := SboxOUT;
        end if;

        s(7) := s(7) xor rc_bit;


        if add_key = '1' then
            s(7) := s(7) xor keybit;
        end if;

        if swap_ctrl(2) = '1' then
            swap(s(127 - 96), s(127 - 120));
        end if;
        if swap_ctrl(1) = '1' then
            swap(s(127 - 104), s(127 - 120));
        end if;
        if swap_ctrl(0) = '1' then
            swap(s(127 - 112), s(127 - 120));
        end if;

        MCin <= s(127) & s(95) & s(63) & s(31);
        if store_mc = '1' then
            s(127) := MCout(3);
            s(95) := MCout(2);
            s(63) := MCout(1);
            s(31) := MCout(0);
        end if;

        CT <= s(127);

        if init = '1' then
            nextbit := '0';
        else
            nextbit := s(127);
        end if;

        if en_xor_data = '1' then
            nextbit := nextbit xor newbit;
        end if;

        tag <= nextbit;
        rotate(s, nextbit);

        st_n <= s;
    end process;

end architecture behav;
