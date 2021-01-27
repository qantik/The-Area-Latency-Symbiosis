library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr is port (
    clk:        in std_logic;
    reset_n:    in std_logic;
    round:      in std_logic_vector(5 downto 0);
    cycle:      in std_logic_vector(4 downto 0);
    rc:         out std_logic_vector(5 downto 0)
    );
end entity lfsr;

architecture behavioural of lfsr is

    signal st_curr:     std_logic_vector(5 downto 0);
    signal st_next:     std_logic_vector(5 downto 0);

    procedure rotate (
        variable st:    inout std_logic_vector(5 downto 0);
        variable b:     in std_logic
        ) is
    begin
        st := st(4 downto 0) & b;
    end procedure rotate;

begin

    fsm : process(clk, reset_n)
    begin
        if reset_n = '0' then
            st_curr <= "000000";
        elsif rising_edge(clk) then
            st_curr <= st_next;
        end if;
    end process fsm;

    pipe : process(st_curr, round, cycle)
        variable st_tmp:    std_logic_vector(5 downto 0);
        variable s0:        std_logic;
        variable round_i:   integer range 0 to 41;
        variable cycle_i:   integer range 0 to 31;
    begin
        st_tmp := st_curr;

        round_i := to_integer(unsigned(round));
        cycle_i := to_integer(unsigned(cycle));

        rc <= st_curr;
        s0 := '0';

        if round_i >= 0 then
            if cycle_i = 8 then
                s0 := st_tmp(5) xnor st_tmp(4);
                rotate(st_tmp, s0);
            end if;
        end if;

        st_next <= st_tmp;
    end process pipe;

end architecture behavioural;
