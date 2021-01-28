library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity testbench is
end testbench;


architecture tb of testbench is  

    constant quarter:           time := 25 ns;
    constant clkphase:          time := 50 ns;
    file testinput:             text;
    file testoutput:            text;
    file tb_output:             text;
    signal PTBit:               std_logic;
    signal CTBit:               std_logic;
    signal ClkxC:               std_logic;
    signal Reset:               std_logic;
    signal Ready:               std_logic;
    signal KeyBit:              std_logic_vector(2 downto 0);
    constant total_cycles:      integer := 128*57;
    signal cont_flag:           boolean := true;

    component SKINNY port (
        KeyBit:      in std_logic_vector(2 downto 0);
        PTBit:       in std_logic;
        Clk:         in std_logic;
        Rst:         in std_logic;
        CT:          out std_logic
        );
    end component SKINNY;

begin

    mut: SKINNY port map (KeyBit, PTBit, ClkxC, Reset, CTBit);

    process
    begin
        if cont_flag then
            ClkxC <= '1';
            wait for clkphase;
            ClkxC <= '0';
            wait for clkphase;
        else
            wait;
        end if;
    end process;

    process
    begin
        if cont_flag then
            Reset <= '0'; wait for quarter;
            Reset <= '1'; wait for 2*total_cycles*clkphase - quarter;
        else
            wait;
        end if;
    end process;

    process
        variable line_var:      line;
        variable pt128:         std_logic_vector(127 downto 0);
        variable ct128:         std_logic_vector(127 downto 0);
        variable k0:            std_logic_vector(127 downto 0);
        variable k1:            std_logic_vector(127 downto 0);
        variable k2:            std_logic_vector(127 downto 0);
        variable tmp :          std_logic_vector(127 downto 0);
        variable counter:       integer;
    begin
        cont_flag <= true;
        file_open(testinput, "Testinput.txt", read_mode);
        file_open(testoutput, "Testoutput.txt", read_mode);
        file_open(tb_output, "tb_output.txt", write_mode);
        counter := 0;

        while not (endfile(testinput)) loop

            readline(testinput, line_var);
            hread(line_var, k0);
            readline(testinput, line_var);
            hread(line_var, k1);
            readline(testinput, line_var);
            hread(line_var, k2);
            readline(testinput, line_var);
            hread(line_var, pt128);
            readline(testoutput, line_var);
            hread(line_var, ct128);

            counter := counter + 1;

            wait for 2*quarter;
            -- load
            for i in 127 downto 0 loop
                KeyBit(0) <= k0(i);
                KeyBit(1) <= k1(i);
                KeyBit(2) <= k2(i);
                PTBit <= pt128(i);
                wait for 2*clkphase;
            end loop;

            wait for 2*total_cycles*clkphase - 2*(256)*clkphase;

            for i in 127 downto 1 loop
                tmp(i) := CTBit;
                wait for 2*clkphase;
            end loop;

            tmp(0) := CTBit;
            wait for 2*quarter;

            hwrite(line_var, tmp);
            writeline(tb_output, line_var);
            assert tmp = ct128 report "======>>> DOES NOT MATCH <<<======" severity failure;
            report "vector # " & integer'image(counter) & ": passed";
        end loop;
        cont_flag <= false;
        wait;
    end process;
end tb;
