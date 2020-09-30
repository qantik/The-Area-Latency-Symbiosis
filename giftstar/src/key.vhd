library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity key is
    port (clk   : in std_logic;
          
          -- key : in std_logic_vector(7 downto 0);
          key : in std_logic;

          round : in std_logic_vector(5 downto 0);
          cycle : in std_logic_vector(6 downto 0);

          round_key : out std_logic);
end entity key;

architecture behavioural of key is
    
    -- signal key_curr, key_next : std_logic_vector(128*8-1 downto 0);
    signal key_curr, key_next : std_logic_vector(127 downto 0);
    signal round_i : integer range 0 to 41;
    signal cycle_i : integer range 0 to 127;

    procedure rotate (
        -- variable k : inout std_logic_vector(128*8-1 downto 0);
        -- variable b  : in std_logic_vector(7 downto 0)) is
        variable k : inout std_logic_vector(127 downto 0);
        variable b  : in std_logic) is
    begin
        k := k(126 downto 0) & b;
        -- k := k(127*8-1 downto 0) & b;
    end procedure rotate;

    -- procedure swap (variable a, b : inout std_logic_vector(7 downto 0)) is
    procedure swap (variable a, b : inout std_logic) is
        -- variable tmp : std_logic_vector(7 downto 0);
        variable tmp : std_logic;
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
        -- if cycle_i >= 0 and cycle_i < 64 then
        if cycle_i >= 32 and cycle_i < 96 then
            round_key <= key_curr(127);
        end if;
        --if round_i > 0 then
        --    if cycle_i mod 4 = 1 then
        --        round_key <= key_curr(127);
        --    elsif cycle_i mod 4 = 2 then
        --        round_key <= key_curr(125);
        --    end if;
        --end if;
    end process mux;

    pipe : process(key_curr, round, cycle)
        -- variable key_tmp : std_logic_vector(128*8-1 downto 0);
        -- variable key0    : std_logic_vector(7 downto 0);
        variable key_tmp : std_logic_vector(127 downto 0);
        variable key0    : std_logic;
        
        -- variable round_i : integer range 0 to 39;
        -- variable cycle_i : integer range 0 to 127;
    begin
        key_tmp := key_curr;

        -- round_i := to_integer(unsigned(round));
        -- cycle_i := to_integer(unsigned(cycle));

        -- swap 1
        -- (k1 << 2), (k7 << 12), (k6 << 4)
        --if round_i mod 4 = 1 then
        --    if cycle_i = 0 then
        --        swap(key_tmp(0), key_tmp(127)); -- reversal (part 2)
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(128*8-1 downto 127*8)); -- reversal (part 2)
        --    end if;

        --    if cycle_i >= 11 and cycle_i <= 63 and cycle_i mod 4 = 3 then
        --        swap(key_tmp(0), key_tmp(8)); -- k1 << 2
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(9*8-1 downto 8*8)); -- k1 << 2
        --    end if;

        --    if round_i > 1 then
        --        if cycle_i >= 3 and cycle_i <= 31 and cycle_i mod 4 = 3 then
        --            swap(key_tmp(95), key_tmp(127)); -- k7 << 8
        --            -- swap(key_tmp(96*8-1 downto 95*8), key_tmp(128*8-1 downto 127*8)); -- k7 << 8
        --        end if;
        --        if cycle_i >= 20 and cycle_i <= 64 and cycle_i mod 4 = 0 then
        --            swap(key_tmp(0), key_tmp(16)); -- k7 << 4
        --            -- swap(key_tmp(1*8-1 downto 0), key_tmp(17*8-1 downto 16*8)); -- k7 << 4
        --        end if;
        --        if cycle_i >= 84 and cycle_i <= 127 and cycle_i mod 4 = 0 then
        --            swap(key_tmp(0), key_tmp(16)); -- k6 << 4 (part 1)
        --            -- swap(key_tmp(1*8-1 downto 0), key_tmp(17*8-1 downto 16*8)); -- k6 << 4 (part 1)
        --        end if;
        --    end if;
        --end if;

        ---- swap 2
        ---- (k3 << 2), (k1 << 12), (k0 << 4)
        --if round_i mod 4 = 2 then
        --    if round_i > 2 then
        --        if cycle_i = 0 then
        --            swap(key_tmp(0), key_tmp(16)); -- k6 << 4 (part 2)
        --            -- swap(key_tmp(1*8-1 downto 0), key_tmp(17*8-1 downto 16*8)); -- k6 << 4 (part 2)
        --        end if;
        --    end if;
        --    
        --    if cycle_i >= 13 and cycle_i <= 65 and cycle_i mod 4 = 1 then
        --        swap(key_tmp(0), key_tmp(8)); -- k3 << 2
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(9*8-1 downto 8*8)); -- k3 << 2
        --    end if;

        --    if cycle_i >= 2 and cycle_i <= 30 and cycle_i mod 4 = 2 then
        --        swap(key_tmp(95), key_tmp(127)); -- k1 << 8
        --        -- swap(key_tmp(96*8-1 downto 95*8), key_tmp(128*8-1 downto 127*8)); -- k1 << 8
        --    end if;
        --    if cycle_i >= 19 and cycle_i <= 63 and cycle_i mod 4 = 3 then
        --        swap(key_tmp(0), key_tmp(16)); -- k1 << 4
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(17*8-1 downto 16*8)); -- k1 << 4
        --    end if;
        --    if cycle_i >= 83 and cycle_i <= 127 and cycle_i mod 4 = 3 then
        --        swap(key_tmp(0), key_tmp(16)); -- k0 << 4
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(17*8-1 downto 16*8)); -- k0 << 4
        --    end if;
        --end if;

        ---- swap 3
        ---- (k5 << 2), (k3 << 12), (k2 << 4)
        --if round_i mod 4 = 3 then
        --    -- reversals
        --    if cycle_i mod 4 = 0 then
        --        swap(key_tmp(125), key_tmp(126));
        --        -- swap(key_tmp(126*8-1 downto 125*8), key_tmp(127*8-1 downto 126*8));
        --    end if;
        --    if cycle_i mod 4 = 2 then
        --        swap(key_tmp(0), key_tmp(127));
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(128*8-1 downto 127*8));
        --    end if;

        --    if cycle_i >= 10 and cycle_i <= 62 and cycle_i mod 4 = 2 then
        --        swap(key_tmp(0), key_tmp(8)); -- k5 << 2
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(9*8-1 downto 8*8)); -- k5 << 2
        --    end if;

        --    if cycle_i >= 4 and cycle_i <= 32 and cycle_i mod 4 = 0 then
        --        swap(key_tmp(95), key_tmp(127)); -- k3 << 8
        --        -- swap(key_tmp(96*8-1 downto 95*8), key_tmp(128*8-1 downto 127*8)); -- k3 << 8
        --    end if;
        --    if cycle_i >= 21 and cycle_i <= 65 and cycle_i mod 4 = 1 then
        --        swap(key_tmp(0), key_tmp(16)); -- k3 << 4
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(17*8-1 downto 16*8)); -- k3 << 4
        --    end if;
        --    if cycle_i >= 85 and cycle_i <= 127 and cycle_i mod 4 = 1 then
        --        swap(key_tmp(0), key_tmp(16)); -- k2 << 4 (part 1)
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(17*8-1 downto 16*8)); -- k2 << 4 (part 1)
        --    end if;
        --end if;

        ---- swap 4
        ---- (k7 << 2), (k5 << 12), (k4 << 4)
        --if round_i mod 4 = 0 and round_i /= 0 then
        --    -- reversals
        --    if cycle_i mod 4 = 0 then
        --        swap(key_tmp(123), key_tmp(124));
        --        -- swap(key_tmp(124*8-1 downto 123*8), key_tmp(125*8-1 downto 124*8));
        --        if cycle_i /= 0 then
        --            swap(key_tmp(0), key_tmp(127));
        --            -- swap(key_tmp(1*8-1 downto 0), key_tmp(128*8-1 downto 127*8));
        --        end if;
        --    end if;

        --    if cycle_i = 1 then
        --        swap(key_tmp(0), key_tmp(16)); -- k2 << 4 (part 2)
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(17*8-1 downto 16*8)); -- k2 << 4 (part 2)
        --    end if;
        --    if cycle_i >= 12 and cycle_i <= 64 and cycle_i mod 4 = 0 then
        --        swap(key_tmp(0), key_tmp(8)); -- k7 << 2
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(9*8-1 downto 8*8)); -- k7 << 2
        --    end if;

        --    if cycle_i >= 1 and cycle_i <= 29 and cycle_i mod 4 = 1 then
        --        swap(key_tmp(95), key_tmp(127)); -- k5 << 8
        --        -- swap(key_tmp(96*8-1 downto 95*8), key_tmp(128*8-1 downto 127*8)); -- k5 << 8
        --    end if;
        --    if cycle_i >= 18 and cycle_i <= 62 and cycle_i mod 4 = 2 then
        --        swap(key_tmp(0), key_tmp(16)); -- k5 << 4
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(17*8-1 downto 16*8)); -- k5 << 4
        --    end if;
        --    if cycle_i >= 82 and cycle_i <= 128 and cycle_i mod 4 = 2 then
        --        swap(key_tmp(0), key_tmp(16)); -- k5 << 4
        --        -- swap(key_tmp(1*8-1 downto 0), key_tmp(17*8-1 downto 16*8)); -- k5 << 4
        --    end if;

        --end if;

        if round_i > 1 then
            if (cycle_i >= 32 and cycle_i < 44) or (cycle_i >= 48 and cycle_i < 60) then
                --swap(key_tmp(27), key_tmp(31));
                swap(key_tmp(28), key_tmp(32));
            end if;
            if cycle_i >= 44 and cycle_i < 52 then
                -- swap(key_tmp(35), key_tmp(43));
                swap(key_tmp(36), key_tmp(44));
            end if;
            if cycle_i >= 52 and cycle_i < 66 then
                --swap(key_tmp(49), key_tmp(51));
                swap(key_tmp(50), key_tmp(52));
            end if;
        end if;

        if round_i > 0 then
          if cycle_i >= 32 and cycle_i < 96 then
              --swap(key_tmp(63), key_tmp(127));
              swap(key_tmp(64), key_tmp(0));
          end if;
          if cycle_i >= 96 and cycle_i < 128 then
              --swap(key_tmp(95), key_tmp(127));
              swap(key_tmp(96), key_tmp(0));
          end if;
        end if;

        -- determine wrap-around bit.
        if round_i = 0 then
            key0 := key;
        else
            key0 := key_tmp(127);
            -- key0 := key_tmp(128*8-1 downto 127*8);
        end if;

        rotate(key_tmp, key0);

        key_next <= key_tmp;

    end process pipe;

end architecture behavioural;
