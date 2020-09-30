library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

entity sundae_tb is
end entity sundae_tb;

architecture bench of sundae_tb is
    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '1';

    signal key  : std_logic;
    
    signal data         : std_logic;
    signal last_block   : std_logic;
    signal last_partial : std_logic;
    
    signal empty_ad  : std_logic := '0';
    signal empty_msg : std_logic := '0';
    
    signal ready  : std_logic;
    signal cipher : std_logic;
    signal tag    : std_logic;

    constant domain : std_logic_vector(127 downto 0) := X"E0000000000000000000000000000000";
    constant ad1    : std_logic_vector(127 downto 0) := X"000102030405060708090A0B0C0D0E0F";
    constant ad2    : std_logic_vector(127 downto 0) := X"00000000000000000000000000000000";
    constant msg    : std_logic_vector(127 downto 0) := X"000102030405060708090A0B0C0D0E0F";

    constant tmp : std_logic_vector(127 downto 0) := X"000102030C0D0E0F0405060708090A0B";
    signal cmp   : std_logic_vector(127 downto 0);
    
    constant clk_period   : time := 100 ns;
    constant reset_period : time := 25 ns;

begin

    sundae : entity work.aead port map (clk, reset_n, key, data, last_block, last_partial,
			                            empty_ad, empty_msg, ready, cipher, tag);

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
       
        last_block   <= '0';
        last_partial <= '0';
	    data <= domain(127);
        key  <= tmp(127);
	
        reset_n <= '0';
        wait for reset_period;
        reset_n <= '1';

	    -- feed nonce
        for i in 1 to 127 loop
            wait until rising_edge(clk);
            data <= domain(127-i);
            key  <= tmp(127-i);
        end loop;
        
	    wait until rising_edge(clk);
        data <= '0';
        key  <= '0';

	    -- feed ad
        wait until ready = '1';
        for i in 0 to 127 loop
            data <= ad1(127-i);
            key  <= tmp(127-i);
            wait until rising_edge(clk);
        end loop;
        
        data <= '0';
        key  <= '0';

        wait until ready = '1';
        last_block   <= '1';
        last_partial <= '0';
        for i in 0 to 127 loop
            data <= ad2(127-i);
            key  <= tmp(127-i);
            wait until rising_edge(clk);
        end loop;
        last_block   <= '0';
        last_partial <= '0';
        
        data <= '0';
        key  <= '0';
       
        -- feed msg
        wait for 384*clk_period;
        wait until ready = '1';
        last_block   <= '1';
        last_partial <= '0';
        for i in 0 to 127 loop
            data <= msg(127-i);
            key  <= tmp(127-i);
            wait until rising_edge(clk);
        end loop;
        last_block   <= '0';
        last_partial <= '0';
        
        data <= '0';
        key  <= '0';
        
        -- refeed msg
        wait for 384*clk_period;
        wait until ready = '1';
        for i in 0 to 127 loop
            data <= msg(127-i);
            key  <= tmp(127-i);
            wait until rising_edge(clk);
        end loop;
        
        data <= '0';
        key  <= '0';

        wait for 384*clk_period;
        wait until ready = '1';
        for i in 0 to 127 loop
            wait until rising_edge(clk);
            cmp(127-i) <= cipher;
        end loop;
	
        write(out_line, cmp);
        writeline(out_file, out_line);
        file_close(out_file);

        wait for 1*clk_period;

        assert false report "test finished" severity failure;

    end process test;

end architecture bench;
    
