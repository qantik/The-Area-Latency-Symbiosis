library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state is
    port (clk   : in std_logic;
          
          pt             : in std_logic;
          round_key      : in std_logic;
          round_constant : in std_logic;

          last_block : in std_logic;

    	  epoch : in unsigned(1 downto 0);
    	  stall : in unsigned(1 downto 0);
          
          round : in std_logic_vector(5 downto 0);
          cycle : in std_logic_vector(6 downto 0);

          ready : out std_logic;
          ct    : out std_logic);
end entity state;

architecture behavioural of state is
    signal st_curr, st_next : std_logic_vector(127 downto 0);

    signal sbox0             : std_logic;
    signal sbox_in, sbox_out : std_logic_vector(3 downto 0);

    procedure rotate (
        variable st : inout std_logic_vector(127 downto 0);
        variable b  : in std_logic) is
    begin
        st := st(126 downto 0) & b;
    end procedure rotate;

    procedure swap (variable a, b : inout std_logic) is
        variable tmp : std_logic;
    begin
        tmp := a;
        a   := b;
        b   := tmp;
    end procedure swap;

begin

    sbox_in <= sbox0 & st_curr(31) & st_curr(63) & st_curr(95);
    sbox : entity work.sbox port map (sbox_in, sbox_out);

    fsm : process(clk)
    begin
        if rising_edge(clk) then
            st_curr <= st_next;
        end if;
    end process fsm;
    
    pipe : process(all)
        variable st_tmp : std_logic_vector(127 downto 0);
        variable s0     : std_logic;
        
        variable round_i : integer range 0 to 41;
        variable cycle_i : integer range 0 to 127;
    begin
        st_tmp := st_curr;

        round_i := to_integer(unsigned(round));
        cycle_i := to_integer(unsigned(cycle));

        -- substitution
        if cycle_i >= 96 and last_block = '0' and stall /= 2 then
        --if cycle_i >= 96 and last_block = '0' then
            st_tmp(95) := sbox_out(0);
            st_tmp(63) := sbox_out(1);
            st_tmp(31) := sbox_out(2);
        end if;

        if stall = 0 or (cycle_i >= 96 and stall = 1) then
        --if stall = 0 or cycle_i >= 96 then
             -- permutation layer A
            if last_block = '0' or cycle_i < 96 then
                if cycle_i mod 8 = 7 then
                    swap(st_tmp(96), st_tmp(97));
                end if;
                if (cycle_i mod 8 = 5) or (cycle_i mod 8 = 7) then
                    swap(st_tmp(96), st_tmp(99));
                end if;
                if cycle_i mod 8 = 5 then
                    swap(st_tmp(96), st_tmp(98));
                end if;
            end if;

            -- permutation layer X1
            if cycle_i = 0 or cycle_i = 1 or cycle_i = 42 or cycle_i = 43 or cycle_i = 50 or
               cycle_i = 51 or cycle_i = 58 or cycle_i = 59 or cycle_i = 66 or cycle_i = 67 or
               ((cycle_i = 104 or cycle_i = 105 or cycle_i = 112 or cycle_i = 113 or cycle_i = 120 or
               cycle_i = 121) and (last_block = '0')) then
                swap(st_tmp(99), st_tmp(103));
            end if;
            -- new stall
            if cycle_i = 6 or cycle_i = 7 or cycle_i = 10 or cycle_i = 11 or cycle_i = 14 or
               cycle_i = 15 or cycle_i = 18 or cycle_i = 19 or cycle_i = 22 or cycle_i = 23 or
               cycle_i = 26 or cycle_i = 27 or cycle_i = 30 or cycle_i = 31 or cycle_i = 34 or
               cycle_i = 35 or cycle_i = 72 or cycle_i = 73 or cycle_i = 80 or cycle_i = 81 or
               cycle_i = 88 or cycle_i = 89 or
               ((cycle_i = 96 or cycle_i = 97) and (stall = 0)) then
                swap(st_tmp(99), st_tmp(101));
            end if;
            -- new stall
            if cycle_i = 74 or cycle_i = 75 or cycle_i = 82 or cycle_i = 83 or cycle_i = 90 or
               cycle_i = 91 or ((cycle_i = 98 or cycle_i = 99) and (stall = 0)) then
                swap(st_tmp(99), st_tmp(105));
            end if;

            -- permutation layer X2
            if cycle_i = 2 or cycle_i = 3 or cycle_i = 34 or cycle_i = 35 or cycle_i = 66 or
               cycle_i = 67 or ((cycle_i = 98 or cycle_i = 99) and (stall = 0)) then
                swap(st_tmp(105), st_tmp(123));
            end if;
            if cycle_i = 4 or cycle_i = 5 or cycle_i = 26 or cycle_i = 27 or cycle_i = 36 or
               cycle_i = 37 or cycle_i = 58 or cycle_i = 59 or cycle_i = 68 or cycle_i = 69 or
               cycle_i = 90 or cycle_i = 91 or ((cycle_i = 100 or cycle_i = 101) and (stall = 0)) or
               ((cycle_i = 122 or cycle_i = 123) and (last_block = '0')) then
                swap(st_tmp(105), st_tmp(117));
            end if;
            if cycle_i = 6 or cycle_i = 7 or cycle_i = 18 or cycle_i = 19 or cycle_i = 28 or
               cycle_i = 29 or cycle_i = 38 or cycle_i = 39 or cycle_i = 50 or cycle_i = 51 or
               cycle_i = 60 or cycle_i = 61 or cycle_i = 70 or cycle_i = 71 or cycle_i = 82 or
               cycle_i = 83 or cycle_i = 92 or cycle_i = 93 or ((cycle_i = 102 or cycle_i = 103) and (stall = 0)) or
               ((cycle_i = 114 or cycle_i = 115 or cycle_i = 124 or cycle_i = 125) and (last_block = '0')) then
                swap(st_tmp(105), st_tmp(111));
            end if;
        end if;
        
        -- determine wrap-around bit.
        --if round_i = 0 and epoch = '0' then
        --    sbox0 <= pt;
        --    s0    := pt;
        --elsif round_i = 0 and stall > 0 then
        --    sbox0 <= st_tmp(127);
        --    s0    := st_tmp(127);
        --elsif round_i = 0 and epoch = '1' and stall /= 2 then
        ----elsif round_i = 0 and epoch = '1' and last_block = '1' then
        --    sbox0 <= st_tmp(127) xor pt xor round_key xor round_constant;
        --    s0    := st_tmp(127) xor pt xor round_key xor round_constant;
        --    if last_block = '1' and ((cycle_i >= 88 and cycle_i < 96) or (cycle_i >= 104 and cycle_i < 112) or (cycle_i >= 120 and cycle_i < 128)) then
        --        sbox0 <= st_tmp(127) xor pt xor round_key xor round_constant xor st_tmp(7);
        --        s0    := st_tmp(127) xor pt xor round_key xor round_constant xor st_tmp(7);
        --    end if;
	    --else
        --   	sbox0 <= st_tmp(127) xor round_key xor round_constant;
        --   	s0    := st_tmp(127) xor round_key xor round_constant;
        --end if;
       
        -- determine wrap-around bit.
        if round_i = 0 and epoch = 0 then
            s0 := pt;
        elsif round_i = 0 and stall > 0 then
            s0 := st_tmp(127);
        elsif round_i = 0 and (epoch = 1 or epoch = 2) and stall = 0 then
            s0 := st_tmp(127) xor pt xor round_key xor round_constant;
	    else
           	s0 := st_tmp(127) xor round_key xor round_constant;
        end if;
            
        if (last_block = '1' or stall = 2) and ((cycle_i >= 88 and cycle_i < 96) or
                                                (cycle_i >= 104 and cycle_i < 112) or
                                                (cycle_i >= 120 and cycle_i < 128)) then
            s0 := s0 xor st_tmp(7);
        end if;

        sbox0 <= s0;

        --if cycle_i >= 96 and last_block = '0' then
        if cycle_i >= 96 and last_block = '0' and stall /= 2 then
            s0 := sbox_out(3);
        end if;

        --if last_block = '1' and cycle_i >= 8 then
        if (last_block = '1' or stall = 2) and cycle_i >= 8 then
            swap(st_tmp(7), s0);
        end if;

        ready <= '0';
        if round_i = 0 and (epoch /= 0 and stall = 0) then
            ready <= '1';
        end if;
        
	    if cycle_i < 96 then
            ct <= s0;
	    else 
            ct <= st_tmp(127) xor round_constant;
	    end if;

        rotate(st_tmp, s0);

        st_next <= st_tmp;

    end process pipe;

end architecture behavioural;
