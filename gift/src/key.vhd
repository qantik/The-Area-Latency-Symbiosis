library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity key is
    port (clk   : in std_logic;
          
          key_in : in std_logic;

          round : in std_logic_vector(5 downto 0);
          cycle : in std_logic_vector(6 downto 0);

          round_key : out std_logic);
end entity key;

architecture behavioural of key is
    
    signal key_curr, key_next : std_logic_vector(127 downto 0);
    signal round_i : integer range 0 to 41;
    signal cycle_i : integer range 0 to 127;

    procedure rotate (
        variable k : inout std_logic_vector(127 downto 0);
        variable b  : in std_logic) is
    begin
        k := k(126 downto 0) & b;
    end procedure rotate;

begin
        
    round_i <= to_integer(unsigned(round));
    cycle_i <= to_integer(unsigned(cycle));

    fsm : process(clk)
    begin
        if rising_edge(clk) then
            key_curr <= key_next;
        end if;
    end process fsm;

    pipe : process(key_curr, key_in, round, cycle, round_i, cycle_i)
        variable key_tmp : std_logic_vector(127 downto 0);
        variable key0    : std_logic;
       
        variable tmp : std_logic_vector(63 downto 0);
    begin
        key_tmp := key_curr;

        if (round_i mod 4 = 2) and (cycle_i = 1) then
            for i in 0 to 15 loop tmp(15-i) := key_tmp((127-1)-(4*i)); end loop;
            for i in 0 to 15 loop key_tmp((127-1)-(4*i)) := tmp((1-i) mod 16); end loop;
            
            for i in 0 to 15 loop tmp(15-i) := key_tmp(((127-1-64)-(4*i)) mod 128); end loop;
            for i in 0 to 15 loop key_tmp(((127-1-64)-(4*i)) mod 128) := tmp((11-i) mod 16); end loop;
        elsif (round_i mod 4 = 3) and (cycle_i = 3) then
            for i in 0 to 15 loop tmp(15-i) := key_tmp((127-1)-(4*i)); end loop;
            for i in 0 to 15 loop key_tmp((127-1)-(4*i)) := tmp((1-i) mod 16); end loop;
            
            for i in 0 to 15 loop tmp(15-i) := key_tmp(((127-1-64)-(4*i)) mod 128); end loop;
            for i in 0 to 15 loop key_tmp(((127-1-64)-(4*i)) mod 128) := tmp((11-i) mod 16); end loop;
        elsif (round_i mod 4 = 0) and (cycle_i = 0) and (round_i > 0) then
            for i in 0 to 15 loop tmp(15-i) := key_tmp((127-1)-(4*i)); end loop;
            for i in 0 to 15 loop key_tmp((127-1)-(4*i)) := tmp((1-i) mod 16); end loop;
            
            for i in 0 to 15 loop tmp(15-i) := key_tmp(((127-1-64)-(4*i)) mod 128); end loop;
            for i in 0 to 15 loop key_tmp(((127-1-64)-(4*i)) mod 128) := tmp((11-i) mod 16); end loop;
        elsif (round_i mod 4 = 1) and (cycle_i = 2) and (round_i > 1) then
            for i in 0 to 15 loop tmp(15-i) := key_tmp((127-1)-(4*i)); end loop;
            for i in 0 to 15 loop key_tmp((127-1)-(4*i)) := tmp((1-i) mod 16); end loop;
            
            for i in 0 to 15 loop tmp(15-i) := key_tmp(((127-1-64)-(4*i)) mod 128); end loop;
            for i in 0 to 15 loop key_tmp(((127-1-64)-(4*i)) mod 128) := tmp((11-i) mod 16); end loop;
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
    
    mux : process(round, cycle, round_i, cycle_i, key_curr)
    begin
        round_key <= '0';
        if round_i > 0 then
            if round_i mod 4 = 1 then
                if (cycle_i mod 4 = 1) or (cycle_i mod 4 = 2) then
                    round_key <= key_curr(127);
                end if;
            elsif round_i mod 4 = 2 then
                if (cycle_i mod 4 = 1) or (cycle_i mod 4 = 2) then
                    round_key <= key_curr(125);
                end if;
            elsif round_i mod 4 = 3 then
                if cycle_i mod 4 = 1 then
                    round_key <= key_curr(126);
                elsif cycle_i mod 4 = 2 then
                    round_key <= key_curr(0);
                end if;
            elsif round_i mod 4 = 0 then
                if cycle_i mod 4 = 1 then
                    round_key <= key_curr(124);
                elsif cycle_i mod 4 = 2 then
                    round_key <= key_curr(126);
                end if;
            end if;
        end if;
    end process mux;

end architecture behavioural;
