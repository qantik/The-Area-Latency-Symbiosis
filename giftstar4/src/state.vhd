library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state is
    port (clk   : in std_logic;
          
          pt             : in std_logic_vector(3 downto 0);
          round_key      : in std_logic_vector(3 downto 0);
          round_constant : in std_logic_vector(5 downto 0);

          round : in std_logic_vector(5 downto 0);
          cycle : in std_logic_vector(4 downto 0);

          ready : out std_logic;
          ct    : out std_logic_vector(3 downto 0));
end entity state;

architecture behavioural of state is
    
    subtype int6type is integer range 0 to 127;
    type int6array is array (127 downto 0) of int6type;
    constant table : int6array := (
    	125, 121, 117, 113, 109, 105, 101, 97, 126, 122, 118, 114, 110, 106, 102, 98,
	127, 123, 119, 115, 111, 107, 103, 99, 124, 120, 116, 112, 108, 104, 100, 96, --0321
	
	94, 90, 86, 82, 78, 74, 70, 66, 95, 91, 87, 83, 79, 75, 71, 67,
	92, 88, 84, 80, 76, 72, 68, 64, 93, 89, 85, 81, 77, 73, 69, 65, --1032

	63, 59, 55, 51, 47, 43, 39, 35, 60, 56, 52, 48, 44, 40, 36, 32,
	61, 57, 53, 49, 45, 41, 37, 33, 62, 58, 54, 50, 46, 42, 38, 34, --2103

	28, 24, 20, 16, 12, 8, 4, 0, 29, 25, 21, 17, 13, 9, 5, 1,
	30, 26, 22, 18, 14, 10, 6, 2, 31, 27, 23, 19, 15, 11, 7, 3  --3210
    );

    signal st_curr, st_next : std_logic_vector(127 downto 0);

    signal sbox0, sbox1, sbox2, sbox3 : std_logic;
    signal sbox_in0, sbox_out0        : std_logic_vector(3 downto 0);
    signal sbox_in1, sbox_out1        : std_logic_vector(3 downto 0);
    signal sbox_in2, sbox_out2        : std_logic_vector(3 downto 0);
    signal sbox_in3, sbox_out3        : std_logic_vector(3 downto 0);

    procedure rotate (
        variable st : inout std_logic_vector(127 downto 0);
        variable b  : in std_logic_vector(3 downto 0)) is
    begin
        st := st(123 downto 0) & b;
    end procedure rotate;

begin

    sbox_in0 <= sbox0 & st_curr(31) & st_curr(63) & st_curr(95);
    sbox_in1 <= sbox1 & st_curr(30) & st_curr(62) & st_curr(94);
    sbox_in2 <= sbox2 & st_curr(29) & st_curr(61) & st_curr(93);
    sbox_in3 <= sbox3 & st_curr(28) & st_curr(60) & st_curr(92);
    
    sb0 : entity work.sbox port map (sbox_in0, sbox_out0);
    sb1 : entity work.sbox port map (sbox_in1, sbox_out1);
    sb2 : entity work.sbox port map (sbox_in2, sbox_out2);
    sb3 : entity work.sbox port map (sbox_in3, sbox_out3);

    fsm : process(clk)
    begin
        if rising_edge(clk) then
            st_curr <= st_next;
        end if;
    end process fsm;
    
    pipe : process(pt, st_curr, round, cycle, sbox_out0, sbox_out1, sbox_out2, sbox_out3, round_key, round_constant)
        variable st_tmp   : std_logic_vector(127 downto 0);
        variable perm_in  : std_logic_vector(127 downto 0);
        variable perm_out : std_logic_vector(127 downto 0);
        variable s0       : std_logic_vector(3 downto 0);
        
        variable round_i : integer range 0 to 41;
        variable cycle_i : integer range 0 to 31;
    begin
        st_tmp := st_curr;

        round_i := to_integer(unsigned(round));
        cycle_i := to_integer(unsigned(cycle));

	-- add round constant in the first cycle of a round
	if cycle_i = 0 then
	    st_tmp(31) := st_tmp(31) xor '1';
	    st_tmp(5 downto 0) := st_tmp(5 downto 0) xor round_constant;
	end if;

	if round_i = 0 then
            sbox0  <= pt(3);
            sbox1  <= pt(2);
            sbox2  <= pt(1);
            sbox3  <= pt(0);
	else
	    sbox0 <= st_tmp(127);
            sbox1 <= st_tmp(126);
            sbox2 <= st_tmp(125);
            sbox3 <= st_tmp(124);
        end if;

        -- substitution
        if cycle_i >= 24 then
            st_tmp(95) := sbox_out0(0);
            st_tmp(63) := sbox_out0(1);
            st_tmp(31) := sbox_out0(2);
            
	    st_tmp(94) := sbox_out1(0);
            st_tmp(62) := sbox_out1(1);
            st_tmp(30) := sbox_out1(2);
            
	    st_tmp(93) := sbox_out2(0);
            st_tmp(61) := sbox_out2(1);
            st_tmp(29) := sbox_out2(2);
            
	    st_tmp(92) := sbox_out3(0);
            st_tmp(60) := sbox_out3(1);
            st_tmp(28) := sbox_out3(2);
            
	    s0 := sbox_out0(3) & sbox_out1(3) & sbox_out2(3) & sbox_out3(3);
        end if;

	-- perform permutation during the last cycle of a round
	if cycle_i = 31 then
	    perm_in := st_tmp(123 downto 0) & sbox_out0(3) & sbox_out1(3)
	                                    & sbox_out2(3) & sbox_out3(3);
	    gen : for i in 0 to 127 loop
	        perm_out(i) := perm_in(table(i));
	    end loop;

	    st_tmp(123 downto 0) := perm_out(127 downto 4);
	    s0 := perm_out(3 downto 0);
	end if;
        
        -- determine wrap-around nibble	
        if round_i = 0 then
	    if cycle_i < 31 then
                s0    := pt;
    	    end if;
            if cycle_i >= 24 and cycle_i < 31 then
                s0 := sbox_out0(3) & sbox_out1(3) & sbox_out2(3) & sbox_out3(3);
            end if;
        elsif cycle_i < 24 then
            s0    := st_tmp(127 downto 124) xor round_key;-- xor round_constant;
        end if;

        ready <= '0';
        if round_i = 40 then
            ready <= '1';
        end if;
        
	if cycle_i < 24 then
            ct <= s0;
	else 
            ct <= st_tmp(127 downto 124);
	end if;
	
        rotate(st_tmp, s0);
        st_next <= st_tmp;

    end process pipe;

end architecture behavioural;
