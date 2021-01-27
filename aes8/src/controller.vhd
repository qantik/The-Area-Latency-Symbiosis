library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity controller is port (
    Clk:             in std_logic;
    Rst:             in std_logic;
    swap_ctrl:       out std_logic_vector(2 downto 0);
    load_mc:         out std_logic;
    load_sbox_st:    out std_logic;
    load_sbox_key:   out std_logic;
    init:            out std_logic;
    add_rc:          out std_logic;
    swap_ctrl_k:     out std_logic_vector(1 downto 0);
    kxor:            out std_logic;
    mcx1:            out std_logic;
    rcout:           out std_logic_vector(7 downto 0)
    );
end entity controller;


architecture behav of controller is

    signal count:       std_logic_vector(3 downto 0);
    signal round:       std_logic_vector(3 downto 0);
    signal ctr:         std_logic_vector(7 downto 0);
    signal ctr_i:       integer range 0 to 255;

    subtype Rctype is   std_logic_vector(7 downto 0);
    type RconType is    array (0 to 10) of Rctype;
    constant Rcon:      RconType := (x"01",x"02",x"04",x"08",x"10",x"20",x"40",x"80",x"1b",x"36",x"6c");

begin

    count <= ctr(3 downto 0);
    round <= ctr(7 downto 4);
    ctr   <= std_logic_vector(to_unsigned(ctr_i, 8));

    process (Rst, Clk)
    begin
        if Rst='0' then
            ctr_i <= 0;
        elsif Clk'event and Clk ='1' then
            ctr_i <= (ctr_i + 1) mod 256;
        end if;
    end process;

    process (round, count)
        variable round_i : integer range 0 to 15;
        variable count_i : integer range 0 to 15;
    begin
        round_i := to_integer(unsigned(round));
        count_i := to_integer(unsigned(count));

        load_sbox_st <= '0';
        swap_ctrl <= "000";
        load_mc <= '0';
        init <= '0';
        load_sbox_key <= '0';
        add_rc <= '0';
        swap_ctrl_k <= "00";
        kxor <= '0';
        mcx1<='0';

        if (count_i = 7) or
            (count_i = 11) or
            (count_i = 15) or
            (count_i = 1) then
            swap_ctrl(0) <= '1';
        end if;
        if (count_i = 11) or
            (count_i = 15) or
            count_i = 0 then
            swap_ctrl(1) <= '1';
        end if;
        if (count_i = 0) then
            swap_ctrl(2) <= '1';
        end if;

        if round_i < 10 and (count_i mod 4 = 0) then
            load_mc <= '1';
        end if;
        if round_i < 10 and (count_i=0) then
            mcx1 <= '1';
        end if;

        if round_i = 0 then
            init <= '1';
        end if;

        if count_i=14 then
            add_rc<='1';
        end if;

        if count_i =0 then
            swap_ctrl_k(0) <= '1';
        end if;
        if count_i =7 then
            swap_ctrl_k(1) <= '1';
        end if;

        if count_i = 14 or count_i = 15 or count_i = 0 or count_i = 1 then
            load_sbox_key <= '1';
        end if;

        -- keep a look-up table for the round constant bits
        rcout<= Rcon(round_i);

        if count_i < 12 then
            kxor <= '1';
        end if;

    end process;

end architecture;

