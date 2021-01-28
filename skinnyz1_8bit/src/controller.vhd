library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity controller is port (
    Clk:             in std_logic;
    Rst:             in std_logic;
    rc:              in std_logic_vector(5 downto 0);
    swap_ctrl:       out std_logic_vector(2 downto 0);
    load_mc:         out std_logic;
    init:            out std_logic;
    swap_ctrl_k:     out std_logic_vector(3 downto 0);
    rc_nibble:       out std_logic_vector(3 downto 0);
    tick:            out std_logic;
    add_key:         out std_logic
    );
end entity controller;


architecture comb of controller is

    signal count:       std_logic_vector(3 downto 0);
    signal round:       std_logic_vector(5 downto 0);
    signal ctr:         std_logic_vector(9 downto 0);
    signal ctr_i:       integer range 0 to 1023;

begin

    count <= ctr(3 downto 0);
    round <= ctr(9 downto 4);
    ctr   <= std_logic_vector(to_unsigned(ctr_i, 10));

    process (Rst, Clk)
    begin
        if Rst='0' then
            ctr_i <= 0;
        elsif Clk'event and Clk ='1' then
            ctr_i <= (ctr_i + 1) mod 1024;
        end if;
    end process;

    process (round, count, rc)
        variable round_i : integer range 0 to 63;
        variable count_i : integer range 0 to 15;
    begin
        round_i := to_integer(unsigned(round));
        count_i := to_integer(unsigned(count));

        swap_ctrl <= "000";
        load_mc <= '0';
        init <= '0';
        swap_ctrl_k <= "0000";
        tick <= '0';
        add_key <= '0';
        rc_nibble <= "0000";

        if round_i = 0 then
            init <= '1';
        end if;

        if count_i = 0 or count_i = 14 or count_i = 15 or count_i = 8 then
            swap_ctrl(0) <= '1';
        end if;

        if count_i = 11 or count_i = 12 or count_i = 8 then
            swap_ctrl(1) <= '1';
        end if;

        if count_i = 8 then
            swap_ctrl(2) <= '1';
        end if;

        if count_i < 4 then
            load_mc <= '1';
        end if;

        if count_i = 9 then
            rc_nibble <= "0010";
            tick <= '1';
        elsif count_i = 5 then
            rc_nibble <= "00" & rc(5 downto 4);
        elsif count_i = 1 then
            rc_nibble <= rc(3 downto 0);
        end if;

        if (count_i >= 9 or count_i < 1) then
            swap_ctrl_k(0) <= '1';
        end if;
        if count_i = 15  then
            swap_ctrl_k(1) <= '1';
        end if;
        if count_i = 14 or count_i = 15 or count_i  = 0 then
            swap_ctrl_k(2) <= '1';
        end if;
        if count_i = 15 or count_i  = 0 or count_i = 3 then
            swap_ctrl_k(3) <= '1';
        end if;

        if count_i >= 1 and count_i < 9 then
            add_key <= '1';
        end if;
    end process;

end architecture;
