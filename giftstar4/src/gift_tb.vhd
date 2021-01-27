library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity gift_tb is
end entity gift_tb;

architecture bench of gift_tb is
    signal clk:             std_logic := '0';
    signal reset_n:         std_logic := '1';
    signal key:             std_logic_vector(3 downto 0);
    signal pt:              std_logic_vector(3 downto 0);
    signal ready:           std_logic;
    signal ct:              std_logic_vector(3 downto 0);
    signal cont_flag:       boolean := true;
    file testinput:         text;
    file testoutput:        text;
    file tb_output:         text;
    constant clk_period:    time := 100 ns;
    constant reset_period:  time := 25 ns;

    procedure reord_key (
        variable k:     inout std_logic_vector(127 downto 0)
        ) is
        variable t:     std_logic_vector(127 downto 0);
    begin
        k := k(127 downto 96) & k(31 downto 0) & k(95 downto 64) & k(63 downto 32);
    end procedure reord_key;

begin

    gift : entity work.gift port map (clk, reset_n, key, pt, ready, ct);

    clock : process
    begin
        if cont_flag then
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        else
            wait;
        end if;
    end process clock;

    test : process
        variable out_line:      line;
        variable vec_line:      line;
        variable k_vec:         std_logic_vector(127 downto 0);
        variable p_vec:         std_logic_vector(127 downto 0);
        variable c_vec:         std_logic_vector(127 downto 0);
        variable tmp:           std_logic_vector(127 downto 0);
        variable counter:       integer;
    begin
        file_open(testinput, "Testinput.txt", read_mode);
        file_open(testoutput, "Testoutput.txt", read_mode);
        file_open(tb_output, "tb_output.txt", write_mode);
        cont_flag <= true;
        counter := 0;

        while not endfile(testinput) loop

            counter := counter + 1;

            readline(testinput, vec_line);
            hread(vec_line, k_vec);
            reord_key(k_vec);

            readline(testinput, vec_line);
            hread(vec_line, p_vec);

            readline(testoutput, vec_line);
            hread(vec_line, c_vec);

            key <= k_vec(127 downto 124);
            pt  <= p_vec(127 downto 124);

            reset_n <= '0';
            wait for reset_period;
            reset_n <= '1';

            for i in 1 to 31 loop
                wait until rising_edge(clk);
                pt  <= p_vec(127-4*i downto 124-4*i);
                key <= k_vec(127-4*i downto 124-4*i);
            end loop;

            wait until rising_edge(clk);

            wait until ready = '1' and rising_edge(clk);

            for i in 0 to 31 loop
                tmp(127-4*i downto 124-4*i) := ct;
                wait until rising_edge(clk);
            end loop;
            hwrite(vec_line, tmp);
            writeline(tb_output, vec_line);
            assert tmp = c_vec report "incorrect ciphertext" severity failure;
            report "vector # " & integer'image(counter) & ": passed";
        end loop;

        wait for 1*clk_period;

        file_close(testinput);

        cont_flag <= false;
        wait;
    end process test;

end architecture bench;
