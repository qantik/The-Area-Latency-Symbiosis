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

    constant clkphase:          time:= 50 ns;
    constant resetactivetime:   time:= 25 ns;
    file testinput:             text;
    file testoutput:            text;
    file correct_v:             text;
    signal clk:                 std_logic;
    signal reset:               std_logic;
    signal key:                 std_logic;
    signal nonce:               std_logic;
    signal data:                std_logic;
    signal last_block:          std_logic;
    signal last_partial:        std_logic;
    signal empty_ad:            std_logic;
    signal odd_ad_blocks:       std_logic;
    signal empty_msg:           std_logic;
    signal k1_bit:              std_logic;
    signal k2_bit:              std_logic;
    signal ct_bit:              std_logic;
    signal ready_key:           std_logic;
    signal ready_block:         std_logic;
    signal ready_full:          std_logic;
    signal cipher_ready:        std_logic;
    signal tag_ready:           std_logic;
    signal ciphertext:          std_logic;
    signal tag:                 std_logic;
    signal statebit:            std_logic;
    signal cont_flag:           boolean:= true;

begin

    mut: entity work.aead port map (
    clk        => clk,
    reset      => reset,
    key        => key,
    nonce      => nonce,
    data       => data,
    last_block => last_block,
    last_partial => last_partial,

    empty_ad   => empty_ad,
    odd_ad_blocks => odd_ad_blocks,
    empty_msg  => empty_msg,

    ready_key => ready_key,
    ready_block => ready_block,
    ready_full => ready_full,

    cipher_ready => cipher_ready,
    tag_ready => tag_ready,

    ciphertext => ciphertext,
    tag => tag,

    statebit => statebit,
    ct_bit => ct_bit,
    k1_bit => k1_bit,
    k2_bit => k2_bit
    );

    process
    begin
        if cont_flag then
            clk <= '1';
            wait for clkphase;
            clk <= '0';
            wait for clkphase;
        else
            wait;
        end if;
    end process;

    a: process
        variable line_var:              line;
        variable tmp_ct:                std_logic_vector(127 downto 0);
        variable tmp_tag:               std_logic_vector(127 downto 0);
        variable tmp_key:               std_logic_vector(127 downto 0);
        variable tmp_nonce:             std_logic_vector(95 downto 0);
        variable tmp_ad:                std_logic_vector(223 downto 0);
        variable tmp_data:              std_logic_vector(127 downto 0);
        variable tmp2:                  std_logic_vector(3 downto 0);
        variable ctx_store:             std_logic_vector(127 downto 0);
        variable tag_store:             std_logic_vector(127 downto 0);

        variable key_load_ctr:          integer range 0 to 127;
        variable data_ctr:              integer range 0 to 127;
        variable ctx_ctr:               integer range 0 to 127;
        variable tag_ctr:               integer range 0 to 127;

        variable test_count:            integer range 0 to 1000;
        variable odd_ad:                std_logic;

        variable ad_count:              integer range 0 to 1000;
        variable msg_count:             integer range 0 to 1000;
        variable ctr:                   integer range 0 to 1000;
        variable read_ctr:              integer range 0 to 1000;
        variable processing_ad:         std_logic;
        variable initial:               std_logic;
        variable last_partial_ad:       std_logic;
        variable last_partial_msg:      std_logic;
    begin
        cont_flag <= true;
        file_open(testinput, "Testinput.txt", read_mode);
        file_open(testoutput, "tb_output.txt", write_mode);
        file_open(correct_v, "Testoutput.txt", read_mode);
        test_count:= 0;

        appli_loop: while not (endfile(testinput)) loop

            reset      <= '0';

            wait until rising_edge(clk);
            reset      <= '1';

            readline(testinput, line_var);
            read(line_var, ad_count);
            readline(testinput, line_var);
            read(line_var, msg_count);
            readline(testinput, line_var);
            hread(line_var, tmp2);
            last_partial_ad:= tmp2(0);
            readline(testinput, line_var);
            hread(line_var, tmp2);
            odd_ad:= tmp2(0);
            readline(testinput, line_var);
            hread(line_var, tmp2);
            last_partial_msg:= tmp2(0);

            key_load_ctr:= 0;
            data_ctr:= 0;
            ctx_ctr:= 0;
            tag_ctr:= 0;
            odd_ad_blocks <= odd_ad;

            readline(testinput, line_var);    hread(line_var, tmp_nonce);
            readline(testinput, line_var);    hread(line_var, tmp_key);

            empty_ad <= '0';
            empty_msg <= '0';
            if ad_count = 0 then empty_ad <= '1'; end if;
            if msg_count = 0 then  empty_msg <= '1'; end if;
            ctr:= 1;
            read_ctr:= 1;
            last_block <= '0';
            if ctr = ad_count or ctr = msg_count + ad_count then last_block <= '1'; end if;
            inner_loop: loop

                wait until rising_edge(clk);

                if cipher_ready = '1' or ctx_ctr > 0 then
                    ctx_store(127 - ctx_ctr):= ciphertext;
                    if ctx_ctr = 127 then
                        -- in order to spot the testbench on fail
                        readline(correct_v, line_var); hread(line_var, tmp_ct);
                        if read_ctr = msg_count and (last_partial_msg = '1')  then
                            assert tmp_ct(127 downto 64)  = ctx_store (127 downto 64) report "CT (upper) does not match\n" severity failure;
                            ctx_store(63 downto 0):= X"0000000000000000"; -- In the case of incomplete block, we add extra 8 bytes of 0x00 so that later makefile diff works perfectly.
                        else
                            assert tmp_ct  = ctx_store report "CT (full) does not match\n" severity failure;
                        end if;
                        hwrite(line_var,  ctx_store); writeline(testoutput, line_var);
                        read_ctr:= read_ctr + 1;
                    end if;
                    ctx_ctr:= (ctx_ctr + 1) mod 128;
                end if;

                if tag_ready = '1' or tag_ctr > 0 then
                    tag_store(127 - tag_ctr):= tag;
                    if tag_ctr = 127 then
                        hwrite(line_var,  tag_store); writeline(testoutput, line_var);
                        -- in order to spot the testbench on fail
                        readline(correct_v, line_var); hread(line_var, tmp_tag);
                        assert tmp_tag  = tag_store  report "the tag does not match" severity failure;
                    end if;
                    tag_ctr:= (tag_ctr + 1) mod 128;
                end if;


                if ready_full = '1' then exit inner_loop; end if;

                if ready_key = '1' or key_load_ctr > 0 then
                    key <= tmp_key(127 - key_load_ctr);
                    if key_load_ctr > 31 and (ctr > ad_count or (ctr = ad_count and odd_ad = '1')) then -- ensure nonce is loaded either by NONCE or AD
                        nonce <= tmp_nonce(127 - key_load_ctr);
                    end if;
                    key_load_ctr:= (key_load_ctr + 1) mod 128;
                end if;

                if ready_block = '1' or data_ctr > 0 then
                    last_block <= '0';
                    last_partial <= '0';
                    -- am I reading AD block?
                    if ad_count >= ctr then
                        if ctr = ad_count then
                            last_block <= '1';
                            last_partial <= last_partial_ad;
                        end if;
                        if data_ctr = 0 then
                            readline(testinput, line_var);    hread(line_var, tmp_ad);
                        end if;
                        data <= tmp_ad(223-data_ctr);
                        if data_ctr > 31 and not (ctr = ad_count and odd_ad = '1') then
                            nonce <= tmp_ad(127-data_ctr);
                        end if;
                    elsif ad_count + msg_count >= ctr then
                        if ctr = msg_count + ad_count then
                            last_block <= '1';
                            last_partial <= last_partial_msg;
                        end if;
                        if data_ctr = 0 then
                            readline(testinput, line_var);    hread(line_var, tmp_data);
                        end if;
                        data <= tmp_data(127 - data_ctr);
                    end if;
                    if data_ctr = 127 then
                        ctr:= ctr + 1;
                    end if;
                    data_ctr:= (data_ctr + 1) mod 128;
                end if;

            end loop inner_loop;
            test_count:= test_count + 1;
            report "vector # " & integer'image(test_count) & ": passed";
        end loop appli_loop;

       wait until clk'event and clk = '1';
       cont_flag <= false;
       wait;
    end process a;
end tb;
