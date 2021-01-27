library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity key is port (
    clk:            in std_logic;
    key_in:         in std_logic;
    round:          in std_logic_vector(5 downto 0);
    cycle:          in std_logic_vector(6 downto 0);
    round_key:      out std_logic
    );
end entity key;

architecture behavioural of key is

    signal key_curr:        std_logic_vector(127 downto 0);
    signal key_next:        std_logic_vector(127 downto 0);
    signal round_i:         integer range 0 to 41;
    signal cycle_i:         integer range 0 to 127;

    procedure rotate (
        variable k:         inout std_logic_vector(127 downto 0);
        variable b:         in std_logic
        ) is
    begin
        k := k(126 downto 0) & b;
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
        round_key <= '0';
        if cycle_i >= 32 and cycle_i < 96 then
            round_key <= key_curr(127);
        end if;
    end process mux;

    pipe : process(key_curr, key_next, round, cycle, round_i, cycle_i)
        variable key_tmp:   std_logic_vector(127 downto 0);
        variable key0:      std_logic;
    begin
        key_tmp := key_curr;

        if round_i > 1 then
            if (cycle_i >= 32 and cycle_i < 44) or (cycle_i >= 48 and cycle_i < 60) then
                swap(key_tmp(27), key_tmp(31));
            end if;
            if cycle_i >= 44 and cycle_i < 52 then
                swap(key_tmp(35), key_tmp(43));
            end if;
            if cycle_i >= 52 and cycle_i < 66 then
                swap(key_tmp(49), key_tmp(51));
            end if;
        end if;

        if round_i > 0 then
          if cycle_i >= 32 and cycle_i < 96 then
              swap(key_tmp(63), key_tmp(127));
          end if;
          if cycle_i >= 96 and cycle_i < 128 then
              swap(key_tmp(95), key_tmp(127));
          end if;
        end if;

        -- determine wrap-around bit.
        if round_i = 0 then
            key0 := key_in;
        else
            key0 := key_tmp(127);
        end if;

        rotate(key_tmp, key0);

        key_next <= key_tmp;
    end process pipe;

end architecture behavioural;
