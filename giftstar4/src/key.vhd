library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity key is port (
    clk:            in std_logic;
    key_in:         in std_logic_vector(3 downto 0);
    round:          in std_logic_vector(5 downto 0);
    cycle:          in std_logic_vector(4 downto 0);
    round_key:      out std_logic_vector(3 downto 0)
    );
end entity key;

architecture behavioural of key is

    signal key_curr:        std_logic_vector(127 downto 0);
    signal key_next:        std_logic_vector(127 downto 0);
    signal round_i:         integer range 0 to 41;
    signal cycle_i:         integer range 0 to 31;

    procedure rotate (
        variable k:         inout std_logic_vector(127 downto 0);
        variable b:         in std_logic_vector(3 downto 0)
        ) is
    begin
        k := k(123 downto 0) & b;
    end procedure rotate;

    procedure swap (
        variable a:         inout std_logic;
        variable b:         inout std_logic
        ) is
        variable tmp:       std_logic;
    begin
        tmp := a;
        a   := b;
        b   := tmp;
    end procedure swap;

begin

    round_i <= to_integer(unsigned(round));
    cycle_i <= to_integer(unsigned(cycle));

    fsm : process(clk)
    begin
        if rising_edge(clk) then
            key_curr <= key_next;
        end if;
    end process fsm;

    mux : process(round_i, cycle_i, key_curr)
    begin
        round_key <= "0000";
        if cycle_i >= 8 and cycle_i < 24 then
            round_key <= key_curr(127 downto 124);
        end if;
    end process mux;

    pipe : process(key_curr, round, cycle, round_i, cycle_i)
        variable key_tmp : std_logic_vector(127 downto 0);
        variable key0    : std_logic_vector(3 downto 0);

    begin
        key_tmp := key_curr;

    if round_i > 0 then
        if cycle_i >= 8 and cycle_i <= 23 then
                swap(key_tmp(127), key_tmp(63));
                swap(key_tmp(126), key_tmp(62));
                swap(key_tmp(125), key_tmp(61));
                swap(key_tmp(124), key_tmp(60));
        end if;

        if cycle_i >= 24 and cycle_i < 32 then
                swap(key_tmp(127), key_tmp(95));
                swap(key_tmp(126), key_tmp(94));
                swap(key_tmp(125), key_tmp(93));
                swap(key_tmp(124), key_tmp(92));
        end if;
    end if;

    if round_i > 1 then
        if cycle_i >= 8 and cycle_i < 11 then
                swap(key_tmp(31), key_tmp(27));
                swap(key_tmp(30), key_tmp(26));
                swap(key_tmp(29), key_tmp(25));
                swap(key_tmp(28), key_tmp(24));
        end if;
        if cycle_i >= 11 and cycle_i < 13 then
                swap(key_tmp(43), key_tmp(35));
                swap(key_tmp(42), key_tmp(34));
                swap(key_tmp(41), key_tmp(33));
                swap(key_tmp(40), key_tmp(32));
        end if;
        if cycle_i >= 13 and cycle_i < 17 then
                swap(key_tmp(51), key_tmp(49));
                swap(key_tmp(50), key_tmp(48));
                swap(key_tmp(49), key_tmp(47));
                swap(key_tmp(48), key_tmp(46));
        end if;
        if cycle_i = 17 then
                swap(key_tmp(53), key_tmp(51));
                swap(key_tmp(52), key_tmp(50));
        end if;
        if cycle_i >= 12 and cycle_i < 15 then
                swap(key_tmp(31), key_tmp(27));
                swap(key_tmp(30), key_tmp(26));
                swap(key_tmp(29), key_tmp(25));
                swap(key_tmp(28), key_tmp(24));
        end if;
    end if;

        -- determine wrap-around bit.
        if round_i = 0 then
            key0 := key_in;
        else
            key0 := key_tmp(127 downto 124);
        end if;

        rotate(key_tmp, key0);
        key_next <= key_tmp;
    end process pipe;

end architecture behavioural;
