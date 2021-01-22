library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.all;

entity gift_tb is
end entity gift_tb;

architecture bench of gift_tb is
    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '1';

    signal key : std_logic;
    signal pt  : std_logic;
    
    signal ready : std_logic;
    signal ct    : std_logic;

    --constant tmp : std_logic_vector(127 downto 0) := X"08090A0B040506070C0D0E0F00010203";
    --constant kmp : std_logic_vector(127 downto 0) := X"000102030C0D0E0F0405060708090A0B";
    --constant kmp : std_logic_vector(127 downto 0) := X"000102030405060708090A0B0C0D0E0F";
    --constant ppp : std_logic_vector(127 downto 0) := X"000102030405060708090A0B0C0D0E0F";
    --constant kmp : std_logic_vector(127 downto 0) := X"00000000000000000000000000000000";
    constant ppp : std_logic_vector(127 downto 0) := X"F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0";
    --constant kmp : std_logic_vector(127 downto 0) := X"F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0";
    constant kmp : std_logic_vector(127 downto 0) := X"7FFF80007FFF80007FFF80007FFF8000";

    signal cont_flag : boolean := true;

    file testinput, testoutput, tb_output : text;
    
    constant clk_period   : time := 100 ns;
    constant reset_period : time := 25 ns;
    
    --procedure extract_key(variable k : in std_logic_vector(127 downto 0)) is
    --    variable t : std_logic_vector(63 downto 0);
    --begin
    --    for i in 0 to 31 loop
    --        t(i*2)   := k(0 + 4*i);
    --        t(i*2+1) := k(1 + 4*i);
    --    end loop;
    --    report to_hstring(k);
    --    report to_hstring(t);
    --end procedure extract_key;
    
    procedure reord_key (variable k : inout std_logic_vector(127 downto 0)) is
        variable t : std_logic_vector(127 downto 0);
    begin
        for i in 0 to 15 loop
            t((127-1)-(4*i)) := k(127-32-i);
            t((127-2)-(4*i)) := k(127-96-i);
            t((127-3)-(4*i)) := k(127-0-i);
            t((127-4)-(4*i)) := k(127-64-i);
            
            t((127-64-1)-(4*i)) := k(127-48-i);
            t((127-64-2)-(4*i)) := k(127-112-i);
            t((127-64-3)-(4*i)) := k(127-16-i);
            t(((127-64-4)-(4*i)) mod 128) := k(127-80-i);
        end loop;
	    k := t;
    end procedure reord_key;

begin

    gift : entity work.gift port map (clk, reset_n, key, pt, ready, ct);

    clock : process
    begin
        if cont_flag then
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        else
            wait;
        end if;
    end process clock;

    test : process
        variable out_line : line;
        variable vec_line : line;
        variable k_vec    : std_logic_vector(127 downto 0);
        variable p_vec    : std_logic_vector(127 downto 0);
        variable c_vec    : std_logic_vector(127 downto 0);
        variable tmp      : std_logic_vector(127 downto 0);
        variable counter  : integer;
    begin
        file_open(testinput, "Testinput.txt", read_mode);
        file_open(testoutput, "Testoutput.txt", read_mode);
        file_open(tb_output, "tb_output.txt", write_mode);

        cont_flag <= true;
        counter   := 0;

        while not endfile(testinput) loop
            counter := counter + 1;

            readline(testinput, vec_line);
            hread(vec_line, k_vec);
            reord_key(k_vec);
            
            readline(testinput, vec_line);
            hread(vec_line, p_vec);

            readline(testoutput, vec_line);
            hread(vec_line, c_vec);
        
            --pt  <= ppp(127);
            --key <= kmp(127);
            pt  <= p_vec(127);
            key <= k_vec(127);

            reset_n <= '0';
            wait for reset_period;
            reset_n <= '1';

            for i in 1 to 127 loop
                wait until rising_edge(clk);
                --pt  <= ppp(127-i);
                --key <= kmp(127-i);
                pt  <= p_vec(127-i);
                key <= k_vec(127-i);
            end loop;
                    
            wait until rising_edge(clk);
            pt  <= '0';
            key <= '0';
                
            --for i in 0 to 5 loop
            --    for j in 0 to 127 loop
            --        wait until rising_edge(clk);
            --        pt  <= '0';
            --        key <= '0';
            --        tmp(127-j) := ct;
            --    end loop;
            --    extract_key(tmp);
            --end loop;

            wait until ready = '1';
            for i in 0 to 127 loop
               wait until rising_edge(clk);
               tmp(127-i) := ct;
            end loop;

            hwrite(vec_line, tmp);
            writeline(tb_output, vec_line);
            assert tmp = c_vec report "incorrect ciphertext" severity failure;
            report "vector # " & integer'image(counter) & ": passed";
        end loop;
  
        wait for clk_period;
        
        file_close(testinput);
        file_close(testoutput);
        file_close(tb_output);

        cont_flag <= false;
        
        wait;
    end process test;

end architecture bench;
    
