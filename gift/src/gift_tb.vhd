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
    constant tmp : std_logic_vector(127 downto 0) := X"000102030C0D0E0F0405060708090A0B";
    constant ppp : std_logic_vector(127 downto 0) := X"000102030405060708090A0B0C0D0E0F";
    signal cmp   : std_logic_vector(127 downto 0);
    
    constant clk_period   : time := 100 ns;
    constant reset_period : time := 25 ns;

begin

    gift : entity work.gift port map (clk, reset_n, key, pt, ready, ct);

    clock : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clock;

    test : process
        file out_file     : text;
        variable out_line : line;
    begin
        file_open(out_file, "./out.txt", write_mode);
        
        pt  <= ppp(127);
        key <= tmp(127);

        reset_n <= '0';
        wait for reset_period;
        reset_n <= '1';

        for i in 1 to 127 loop
            wait until rising_edge(clk);
            -- key <= k_tmp((128-i)*8-1 downto (127-i)*8);
            pt  <= ppp(127-i);
            key <= tmp(127-i);
        end loop;
            
        wait until rising_edge(clk);
        pt  <= '0';
        key <= '0';

        wait until ready = '1';
        for i in 0 to 127 loop
           wait until rising_edge(clk);
           cmp(127-i) <= ct;
        end loop;
   
        --for r in 1 to 10 loop
        --    for i in 1 to 128 loop
        --        wait until rising_edge(clk);
        --        if i >= 1 and i <= 64 then
        --            cmp(64-i) <= ct;
        --        end if;
        --    end loop;
        --end loop;

        write(out_line, cmp);
        writeline(out_file, out_line);
        file_close(out_file);

        wait for 1*clk_period;

        assert false report "test finished" severity failure;

    end process test;

end architecture bench;
    
