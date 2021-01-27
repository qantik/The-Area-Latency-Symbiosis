library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state is port (
    clk:            in std_logic;
    pt:             in std_logic;
    round_key:      in std_logic;
    round_constant: in std_logic;
    round:          in std_logic_vector(5 downto 0);
    cycle:          in std_logic_vector(6 downto 0);
    ready:          out std_logic;
    ct:             out std_logic
    );
end entity state;

architecture behavioural of state is
    signal st_curr:         std_logic_vector(127 downto 0);
    signal st_next:         std_logic_vector(127 downto 0);

    signal sbox0:           std_logic;
    signal sbox_in:         std_logic_vector(3 downto 0);
    signal sbox_out:        std_logic_vector(3 downto 0);

    procedure rotate (
        variable st:        inout std_logic_vector(127 downto 0);
        variable b:         in std_logic
        ) is
    begin
        st := st(126 downto 0) & b;
    end procedure rotate;

    procedure swap (
        variable a:         inout std_logic;
        variable b:         inout std_logic
        ) is
        variable tmp : std_logic;
    begin
        tmp := a;
        a   := b;
        b   := tmp;
    end procedure swap;

begin

    sbox_in <= st_curr(2 downto 0) & sbox0;
    sbox : entity work.sbox port map (sbox_in, sbox_out);

    fsm : process(clk)
    begin
        if rising_edge(clk) then
            st_curr <= st_next;
        end if;
    end process fsm;

    pipe : process(st_curr, round, cycle, sbox_out, round_key, round_constant, pt)
        variable st_tmp:        std_logic_vector(127 downto 0);
        variable s0:            std_logic;
        variable round_i:       integer range 0 to 41;
        variable cycle_i:       integer range 0 to 127;
    begin
        st_tmp := st_curr;

        round_i := to_integer(unsigned(round));
        cycle_i := to_integer(unsigned(cycle));

        -- substitution
        if cycle_i mod 4 = 3 then
            st_tmp(2 downto 0) := sbox_out(3 downto 1);
        end if;

        if (cycle_i >= 0 and cycle_i <= 24) or
           (cycle_i >= 121 and cycle_i <= 127) then
            swap(st_tmp(56), st_tmp(88));
        end if;
        if (cycle_i >= 0 and cycle_i <= 9) or
           (cycle_i >= 58 and cycle_i <= 73) or
           (cycle_i >= 122 and cycle_i <= 127) then
            swap(st_tmp(89), st_tmp(105));
        end if;

        if (cycle_i >= 10 and cycle_i <= 13) or
           (cycle_i >= 34 and cycle_i <= 37) or
           (cycle_i >= 54 and cycle_i <= 57) or
           (cycle_i >= 74 and cycle_i <= 77) or
           (cycle_i >= 98 and cycle_i <= 101) or
           (cycle_i >= 118 and cycle_i <= 121) then
            swap(st_tmp(17), st_tmp(29));
        end if;
        if (cycle_i >= 7 and cycle_i <= 10) or
           (cycle_i >= 51 and cycle_i <= 54) or
           (cycle_i >= 71 and cycle_i <= 74) or
           (cycle_i >= 115 and cycle_i <= 118) then
            swap(st_tmp(18), st_tmp(42));
        end if;
        if (cycle_i >= 4 and cycle_i <= 7) or
           (cycle_i >= 68 and cycle_i <= 71) then
            swap(st_tmp(19), st_tmp(55));
        end if;

        if (cycle_i mod 16 = 5) or
           (cycle_i mod 16 = 13) or
           (cycle_i mod 16 = 15) then
            swap(st_tmp(6), st_tmp(10));
        end if;
        if (cycle_i mod 16 = 1) or
           (cycle_i mod 16 = 3) then
            swap(st_tmp(5), st_tmp(13));
        end if;
        if (cycle_i mod 16 = 1) then
            swap(st_tmp(4), st_tmp(16));
        end if;

       -- determine wrap-around bit.
       if round_i = 0 then
           sbox0 <= pt;
           s0    := pt;
           if cycle_i mod 4 = 3 then
              s0 := sbox_out(0);
           end if;
       else
           sbox0 <= st_tmp(127) xor round_key xor round_constant;
           s0    := st_tmp(127) xor round_key xor round_constant;
           if cycle_i mod 4 = 3 then
              s0 := sbox_out(0);
           end if;
       end if;

       ready <= '0';
       if round_i = 40 then
           ready <= '1';
       end if;
       ct <= st_tmp(127) xor round_key xor round_constant;

       rotate(st_tmp, s0);

       st_next <= st_tmp;
    end process pipe;

end architecture behavioural;
