library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.all;

entity skinny_aead_tb is
end;

architecture test of skinny_aead_tb is

    -- Input signals.
    signal clk:             std_logic:= '0';
    signal reset:           std_logic;
    signal data:            std_logic;
    signal last_block:      std_logic:= '0';
    signal last_partial:    std_logic:= '0';
    signal empty_ad:        std_logic:= '0';
    signal empty_msg:       std_logic:= '0';
    signal key:             std_logic;
    signal nonce:           std_logic;
    -- Output signals.
    signal ready_block:     std_logic;
    signal ready_full:      std_logic;
    signal cipher_ready:    std_logic;
    signal tag_ready:       std_logic;
    signal cont_flag:       boolean:= true;
    signal ciphertext:      std_logic ;
    signal tag:             std_logic ;
    file in_vecs:           text;
    file tb_output:         text;
    constant clk_period:    time:= 100 ns;
    constant reset_period:  time:= 25 ns;

begin

    mut: entity work.skinny_aead port map (
    clk          => clk,
    reset        => reset,
    key          => key,
    nonce        => nonce,
    data         => data,
    last_block   => last_block,
    last_partial => last_partial,
    empty_ad     => empty_ad,
    empty_msg    => empty_msg,
    ready_block  => ready_block,
    ready_full   => ready_full,
    cipher_ready => cipher_ready,
    tag_ready    => tag_ready,
    ciphertext   => ciphertext,
    tag          => tag
    );

    clk_process: process
    begin
        if cont_flag then
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        else
            wait;
        end if;
    end process;

    test: process
        variable vec_line:          line;
        variable vec_space:         character;
        variable vec_in_id:         integer;
        variable vec_out_id:        integer;
        variable vec_num_ad:        integer;
        variable vec_num_msg:       integer;
        variable vec_ad_part:       std_logic;
        variable vec_msg_part:      std_logic;
        variable ad_iters:          integer;
        variable vec_key:           std_logic_vector(127 downto 0);
        variable vec_ad:            std_logic_vector(127 downto 0);
        variable vec_msg:           std_logic_vector(127 downto 0);
        variable vec_cipher:        std_logic_vector(127 downto 0);
        variable vec_tag:           std_logic_vector(127 downto 0);
        variable vec_nonce:         std_logic_vector(127 downto 0);
        variable cmp:               std_logic_vector(127 downto 0);
        variable round:             integer:= 1;

    procedure nodata(
        constant void:      in integer:= 0
        ) is
    begin
        empty_ad   <= '1'; empty_msg <= '1';
        data       <=  '0' ;

        reset <= '0';
        wait for reset_period;
        reset <= '1';

        for i in 127 downto 0 loop
            key     <= vec_key(i);
            nonce   <= vec_nonce(i);
            wait for clk_period;
        end loop;

        readline(in_vecs, vec_line);
        hread(vec_line, vec_tag);

        wait for 7040*clk_period-reset_period;

        for i in 0 to 127 loop
            wait until falling_edge(clk);
            cmp(127-i):= tag;
            assert tag = vec_tag(127-i) report "incorrect tag" severity failure;
        end loop;
        wait for clk_period/2;
        hwrite(vec_line, cmp);
        writeline(tb_output, vec_line);
    end procedure;


    procedure noad(
        constant msg_blocks:    in integer;
        constant partial:       in std_logic
        ) is
    begin
        empty_ad   <= '1'; empty_msg <= '0';
        data       <= '0' ;
        reset <= '0';
        wait for reset_period;
        reset <= '1';
        for j in 1 to msg_blocks-1 loop
            last_block   <= '0';
            last_partial <= '0';
            readline(in_vecs, vec_line);
            hread(vec_line, vec_msg);
            for i in 127 downto 0 loop
                data <= vec_msg(i);
                key   <= vec_key(i);
                nonce   <= vec_nonce(i);
                wait for clk_period;
            end loop;
            wait for 7168*clk_period;
        end loop;
        last_block   <= '1';
        last_partial <= partial;
        readline(in_vecs, vec_line);
        hread(vec_line, vec_msg);

        if partial='0' then
            for i in 127 downto 0 loop
                data <= vec_msg(i);
                key   <= vec_key(i);
                nonce   <= vec_nonce(i);
                wait for clk_period;
            end loop;
            wait for 7168*clk_period -reset_period;
        else
            for i in 127 downto 0 loop
                key   <= vec_key(i);
                nonce   <= vec_nonce(i);
                wait for clk_period;
            end loop;
            wait for 7040*clk_period -reset_period ;
            for i in 127 downto 0 loop
                data <= vec_msg(i);
                wait for clk_period;
            end loop;
        end if;

        for i in 127 downto 0 loop
            key   <= vec_key(i);
            nonce   <= vec_nonce(i);
            wait for clk_period;
        end loop;

        readline(in_vecs, vec_line);
        hread(vec_line, vec_tag);
        wait for 7040*clk_period;

        for i in 0 to 127 loop
            wait until falling_edge(clk);
            cmp(127-i):= tag;
            assert tag = vec_tag(127-i) report "incorrect tag" severity failure;
        end loop;
        wait for clk_period/2;
        hwrite(vec_line, cmp);
        writeline(tb_output, vec_line);
     end procedure;


    procedure nomsg(
        constant ad_blocks:     in integer;
        constant partial:       in std_logic
        ) is
    begin
        empty_ad   <= '0'; empty_msg <= '1';
        data       <=  '0' ;
        reset <= '0';
        wait for reset_period;
        reset <= '1';
        for j in 1 to ad_blocks-1 loop
            last_block   <= '0';
            last_partial <= '0';
            readline(in_vecs, vec_line);
            hread(vec_line, vec_ad);
            for i in 127 downto 0 loop
                data <= vec_ad(i);
                key   <= vec_key(i);
                nonce   <= vec_nonce(i);
                wait for clk_period;
            end loop;
            wait for 7168*clk_period;---reset_period;
        end loop;
        last_block   <= '1';
        last_partial <= partial;
        readline(in_vecs, vec_line);
        hread(vec_line, vec_ad);
        for i in 127 downto 0 loop
            data <= vec_ad(i);
            key   <= vec_key(i);
            nonce   <= vec_nonce(i);
            wait for clk_period;
        end loop;
        wait for 7168*clk_period -reset_period;
        for i in 127 downto 0 loop
            key   <= vec_key(i);
            nonce   <= vec_nonce(i);
            wait for clk_period;
        end loop;
        readline(in_vecs, vec_line);
        hread(vec_line, vec_tag);
        wait for 7040*clk_period;
        for i in 0 to 127 loop
            wait until falling_edge(clk);
            cmp(127-i):= tag;
            assert tag = vec_tag(127-i) report "incorrect tag" severity failure;
        end loop;
        wait for clk_period/2;
        hwrite(vec_line, cmp);
        writeline(tb_output, vec_line);
    end procedure;


    procedure full(
        constant ad_blocks:         in integer;
        constant msg_blocks:        in integer;
        constant ad_partial:        in std_logic;
        constant msg_partial:       in std_logic
        ) is
    begin
        empty_ad   <= '0'; empty_msg <= '0';
        data       <=   '0' ;
        reset <= '0';
        wait for reset_period;
        reset <= '1';
        for j in 1 to ad_blocks-1 loop
            last_block   <= '0';
            last_partial <= '0';
            readline(in_vecs, vec_line);
            hread(vec_line, vec_ad);
            for i in 127 downto 0 loop
                data <= vec_ad(i);
                key   <= vec_key(i);
                nonce   <= vec_nonce(i);
                wait for clk_period;
            end loop;
            wait for 7168*clk_period;---reset_period;
        end loop;
        last_block   <= '1';
        last_partial <= ad_partial;
        readline(in_vecs, vec_line);
        hread(vec_line, vec_ad);
        for i in 127 downto 0 loop
            data <= vec_ad(i);
            key   <= vec_key(i);
            nonce   <= vec_nonce(i);
            wait for clk_period;
        end loop;
        wait for 7168*clk_period -reset_period;

        for j in 1 to msg_blocks-1 loop
            last_block   <= '0';
            last_partial <= '0';
            readline(in_vecs, vec_line);
            hread(vec_line, vec_msg);
            for i in 127 downto 0 loop
                data <= vec_msg(i);
                key   <= vec_key(i);
                nonce   <= vec_nonce(i);
                wait for clk_period;
            end loop;
            wait for 7168*clk_period;---reset_period;
        end loop;

        last_block   <= '1';
        last_partial <= msg_partial;
        readline(in_vecs, vec_line);
        hread(vec_line, vec_msg);

        if msg_partial='0' then
            for i in 127 downto 0 loop
                data <= vec_msg(i);
                key   <= vec_key(i);
                nonce   <= vec_nonce(i);
                wait for clk_period;
            end loop;
            wait for 7168*clk_period  ;
        else
            for i in 127 downto 0 loop
                key   <= vec_key(i);
                nonce   <= vec_nonce(i);
                wait for clk_period;
            end loop;
            wait for 7040*clk_period  ;
            for i in 127 downto 0 loop
                data <= vec_msg(i);
                wait for clk_period;
            end loop;
        end if;

        for i in 127 downto 0 loop
            key   <= vec_key(i);
            nonce   <= vec_nonce(i);
            wait for clk_period;
        end loop;
        readline(in_vecs, vec_line);
        hread(vec_line, vec_tag);

        wait for 7040*clk_period;

        for i in 0 to 127 loop
            wait until falling_edge(clk);
            cmp(127-i):= tag;
            assert tag = vec_tag(127-i) report "incorrect tag" severity failure;
        end loop;
        wait for clk_period/2;
        hwrite(vec_line, cmp);
        writeline(tb_output, vec_line);
    end procedure;

begin
        cont_flag <= true;
        file_open(in_vecs, "Testinput.txt", read_mode);
        file_open(tb_output, "tb_output.txt", write_mode);
        while not endfile(in_vecs) loop
            round:= round + 1;
            readline(in_vecs, vec_line);
            read(vec_line, vec_in_id);
            read(vec_line, vec_space);
            read(vec_line, vec_num_ad);
            read(vec_line, vec_space);
            read(vec_line, vec_num_msg);
            read(vec_line, vec_space);
            read(vec_line, vec_ad_part);
            read(vec_line, vec_space);
            read(vec_line, vec_msg_part);

            readline(in_vecs, vec_line);
            hread(vec_line, vec_key);
            readline(in_vecs, vec_line);
            hread(vec_line, vec_nonce);

        if (vec_num_ad = 0) and (vec_num_msg = 0) then
            nodata(0);
        elsif (vec_num_ad = 0) and (vec_num_msg /= 0) then
            noad(vec_num_msg, vec_msg_part);
        elsif (vec_num_ad /= 0) and (vec_num_msg = 0) then
            nomsg(vec_num_ad, vec_ad_part);
        else
            full(vec_num_ad, vec_num_msg, vec_ad_part, vec_msg_part);
        end if;
            report "vector # " & integer'image(round) & ": passed";
        end loop;
        cont_flag <= false;
        wait;
    end process;

end;
