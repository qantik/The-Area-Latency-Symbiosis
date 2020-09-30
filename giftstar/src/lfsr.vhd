library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr is
    port (clk     : in std_logic;
          reset_n : in std_logic;
    
          round : in std_logic_vector(5 downto 0);
          cycle : in std_logic_vector(6 downto 0);
              
          rc    : out std_logic);
end entity lfsr;

architecture behavioural of lfsr is

    signal st_curr, st_next : std_logic_vector(5 downto 0);

    procedure rotate (
        variable st : inout std_logic_vector(5 downto 0);
        variable b  : in std_logic) is
    begin
        st := st(4 downto 0) & b;
        -- st := st(127*8-1 downto 0) & b;
    end procedure rotate;

    procedure swap (variable a, b : inout std_logic) is
        variable tmp : std_logic;
    begin
        tmp := a;
        a   := b;
        b   := tmp;
    end procedure swap;

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
        variable st_tmp : std_logic_vector(5 downto 0);
        variable s0     : std_logic;
        
        variable round_i : integer range 0 to 41;
        variable cycle_i : integer range 0 to 127;
    begin
        st_tmp := st_curr;

        round_i := to_integer(unsigned(round));
        cycle_i := to_integer(unsigned(cycle));

        rc <= '0';
        s0 := '0';

        if round_i > 0 then
            if cycle_i = 96 then
                s0 := st_tmp(5) xnor st_tmp(4);
                rotate(st_tmp, s0);
                rc <= '1';
            --elsif cycle_i >= 26 and cycle_i < 32 then
            elsif cycle_i >= 122 and cycle_i < 128 then
                s0 := st_tmp(5);
                rc <= s0;
                rotate(st_tmp, s0);
            end if;
        end if;

        st_next <= st_tmp;

    end process pipe;

end architecture behavioural;
