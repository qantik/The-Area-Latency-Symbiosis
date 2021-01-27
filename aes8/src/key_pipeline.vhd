library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity key_pipeline is port (
    roundkeybyte:       out std_logic_vector(7 downto 0);
    SboxIN:             out std_logic_vector(7 downto 0);
    Clk:                in std_logic;
    init:               in std_logic;
    swap_ctrl_k:        in std_logic_vector(1 downto 0);
    load_sbox_key:      in std_logic;
    add_rc:             in std_logic;
    kxor:               in std_logic;
    KeyBit:             in std_logic_vector(7 downto 0);
    SboxOUT:            in std_logic_vector(7 downto 0);
    rc:                 in std_logic_vector(7 downto 0)
    );
end entity key_pipeline;


architecture behav of key_pipeline is

    signal k_p:         std_logic_vector(127 downto 0);
    signal k_n:         std_logic_vector(127 downto 0);
    signal newbyte:     std_logic_vector(7 downto 0);

    procedure rotate (
        variable s:     inout std_logic_vector(127 downto 0);
        variable b:     in std_logic_vector(7 downto 0)
        ) is
    begin
            s := s(119 downto 0) & b;
    end procedure  rotate;

    procedure swap (
        variable a:     inout std_logic_vector(7 downto 0);
        variable b:     inout std_logic_vector(7 downto 0)
        ) is
        variable tmp :  std_logic_vector(7 downto 0);
    begin
        tmp := a;
        a := b;
        b := tmp;
    end procedure swap;

begin

    SboxIN <= k_p(7 downto 0);

    newbyte <= KeyBit when init='1' else k_p(127 downto 120);
    roundkeybyte <= newbyte;

    process (Clk)
    begin
        if Clk'event and Clk = '1' then
            k_p <= k_n;
        end if;
    end process;

    process (k_p, init, swap_ctrl_k, load_sbox_key, add_rc, kxor, newbyte, SboxOUT)
        variable s:          std_logic_vector(127 downto 0);
        variable nextbyte:   std_logic_vector(7 downto 0);
    begin
        s := k_p;

        nextbyte := s(127 downto 120);
        if init = '1' then
            nextbyte := newbyte;
        end if;


        if swap_ctrl_k(0) = '1' then
            swap(s(127 - 96 downto 120 - 96), nextbyte);
        end if;
        if swap_ctrl_k(1) = '1' then
            swap(s(127 - 72 downto 120 -72), s(127 - 40 downto 120-40));
        end if;

        if load_sbox_key = '1' then
            s(127-16 downto 120-16) := s(127-16 downto 120-16) xor SboxOUT;
        end if;

        -- keep a look-up table for the round constant bits
        if add_rc = '1' then
            s(127-16 downto 120-16) :=  s(127-16 downto 120-16) xor rc;
        end if;

        if kxor = '1' then
            s(127 - 32 downto 120-32) := s(127 - 32 downto 120-32) xor s(127 downto 120);
        end if;

        rotate(s, nextbyte);

        k_n <= s;

    end process;

end architecture behav;

