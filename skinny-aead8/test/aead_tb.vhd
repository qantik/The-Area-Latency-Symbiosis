library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity aead_tb is
end;

architecture test of aead_tb is

    -- Input signals.
    signal clk   : std_logic := '0';
    signal reset : std_logic;

    signal data         : std_logic_vector(7 downto 0);
    
    signal last_block   : std_logic := '0';
    signal last_partial : std_logic := '0';
    signal empty_ad     : std_logic := '0';
    signal empty_msg    : std_logic := '0';

    signal key     : std_logic_vector(7 downto 0);
    signal nonce   : std_logic_vector(7 downto 0);

    -- Output signals.
    signal ready_block  : std_logic;
    signal ready_tag    : std_logic;
    signal ready_cipher : std_logic;
    
    signal ct  : std_logic_vector(7 downto 0);
    signal tag : std_logic_vector(7 downto 0);

    file vec_file : text;

    constant clk_period   : time := 100 ns;
    constant reset_period : time := 25 ns;
    
begin

    aead : entity work.skinny
        port map (clk          => clk,
                  reset_n      => reset,
                  key          => key,
                  nonce        => nonce,
                  data         => data,
                  last_block   => last_block,
                  last_partial => last_partial,
                  empty_ad     => empty_ad,
                  empty_msg    => empty_msg,
                  ready_block  => ready_block,
                  ready_tag    => ready_tag,
                  ready_cipher => ready_cipher,
                  tag          => tag,
                  ct           => ct);

    clk_process : process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;
    
    test : process
        variable vec_line  : line;
        variable vec_space : character;
        
        variable vec_in_id, vec_out_id     : integer;
        variable vec_num_ad, vec_num_msg   : integer;
        variable vec_ad_part, vec_msg_part : std_logic;
        variable vec_init                  : std_logic_vector(127 downto 0);
        variable vec_key, vec_nonce        : std_logic_vector(127 downto 0);
        variable vec_ad, vec_msg           : std_logic_vector(127 downto 0);
        variable vec_cipher, vec_tag       : std_logic_vector(127 downto 0);

        variable round : integer := 1;

	procedure nodata(constant void : in integer := 0) is
	begin
	    empty_ad <= '1'; empty_msg <= '1';

	    reset <= '0';
            wait for reset_period;
            reset <= '1';
	    
	    for i in 0 to 15 loop
                wait until rising_edge(clk);
	    	data <= (others => '0');
                key  <= vec_key(127-8*i downto 120-8*i);
                nonce <= vec_nonce(127-8*i downto 120-8*i);
            end loop;

	    wait until rising_edge(clk);
            wait until ready_cipher = '1';
            
	    readline(vec_file, vec_line);
            hread(vec_line, vec_tag);
	    for i in 0 to 15 loop
                wait until rising_edge(clk);
	        assert tag = vec_tag(127-8*i downto 120-8*i) report "incorrect tag" severity failure;
            end loop;
	end procedure;
        
	--procedure noad(constant msg_blocks : in integer;
        --               constant partial   : in std_logic) is
	--begin
	--    data <= vec_init(127 downto 124);
	--    key <= vec_key(127 downto 124);

	--    empty_ad   <= '1'; empty_msg <= '0'; 
        --    last_block   <= '0'; last_partial <= '0';

	--    reset <= '0';
        --    wait for reset_period;
        --    reset <= '1';
        --    
	--    for i in 1 to 31 loop
        --        wait until rising_edge(clk);
        --        data <= vec_init(127-4*i downto 124-4*i);
        --        key  <= vec_key(127-4*i downto 124-4*i);
        --    end loop;

	--    wait until rising_edge(clk);
        --    wait until ready_block = '1';
        --    
	--    for i in 1 to msg_blocks loop
        --    	readline(vec_file, vec_line);
	--	hread(vec_line, vec_msg);
	--	
	--	last_block   <= '0'; last_partial <= '0';

	--	if i = msg_blocks then
	--	    last_block   <= '1'; last_partial <= partial;
	--	end if;
	--       
	--       	for j in 0 to 31 loop
        --            data <= vec_msg(127-4*j downto 124-4*j);
        --            key  <= vec_key(127-4*j downto 124-4*j);
        --       	    wait until rising_edge(clk);
        --    	end loop;

        --        data <= (others => '0');
	--	key <= (others => '0');
	--
        --        if i = msg_blocks then
	--	    wait until ready_tag = '1';
	--	    last_block  <= '0'; last_partial <= '0';
	--	    
        --    	    readline(vec_file, vec_line);
        --    	    hread(vec_line, vec_tag);
	--    	    for j in 0 to 31 loop
        --               key  <= vec_key(127-4*j downto 124-4*j); -- already feed key
        --    	       wait until rising_edge(clk);
	--    	       assert tag = vec_tag(127-4*j downto 124-4*j) report "incorrect tag" severity failure;
        --    	    end loop;
	--	    
	--	    if msg_blocks = 1 then
	--	        last_block <= '1';
	--	    end if;
	--	else
	--	    wait until ready_block = '1';
        --        end if;
        --    end loop;

	--    for i in 1 to msg_blocks loop
	--	wait until ready_block = '1';
        --    	
	--	readline(vec_file, vec_line);
	--	hread(vec_line, vec_msg);
	--	
	--	key <= (others => '0');
	--	last_block <= '0'; last_partial <= '0';

	--	if i = msg_blocks then
	--	    last_block <= '1';
	--	end if;
	--       
	--       	for j in 0 to 31 loop
        --       	    wait until rising_edge(clk);
        --            data <= vec_msg(127-4*j downto 124-4*j);
        --            key  <= vec_key(127-4*j downto 124-4*j);
        --    	end loop;

        --        data <= (others => '0');
        --    end loop;

	--end procedure;
        
	procedure noad(constant  msg_blocks : in integer;
                        constant partial   : in std_logic) is
	begin
	    empty_ad <= '1'; empty_msg <= '0';

	    reset <= '0';
            wait for reset_period;
            reset <= '1';
	    
	    for i in 1 to msg_blocks loop
            	readline(vec_file, vec_line);
		hread(vec_line, vec_msg);
		
		last_block   <= '0'; last_partial <= '0';

		if i = msg_blocks then
		    last_block   <= '1'; last_partial <= partial;
		end if;

		if i = 1 then wait until rising_edge(clk); end if;
	       
	       	for j in 0 to 15 loop
                    key  <= vec_key(127-8*j downto 120-8*j);
                    nonce <= vec_nonce(127-8*j downto 120-8*j);
                    data <= vec_msg(127-8*j downto 120-8*j);
               	    wait until rising_edge(clk);
            	end loop;

		wait until ready_block = '1';
            end loop;
		    
	    for j in 0 to 15 loop
                key  <= vec_key(127-8*j downto 120-8*j);
                nonce <= vec_nonce(127-8*j downto 120-8*j);
                data <= vec_msg(127-8*j downto 120-8*j);
                wait until rising_edge(clk);
            end loop;
		
	    wait until ready_tag = '1';
            	    
	    readline(vec_file, vec_line);
            hread(vec_line, vec_tag);
	    for j in 0 to 15 loop
                wait until rising_edge(clk);
	        assert tag = vec_tag(127-8*j downto 120-8*j) report "incorrect tag" severity failure;
            end loop;
	end procedure;

        procedure nomsg(constant ad_blocks : in integer;
                        constant partial   : in std_logic) is
	begin
	    empty_ad <= '0'; empty_msg <= '1';

	    reset <= '0';
            wait for reset_period;
            reset <= '1';
	    
	    for i in 1 to ad_blocks loop
            	readline(vec_file, vec_line);
		hread(vec_line, vec_ad);
		
		last_block   <= '0'; last_partial <= '0';

		if i = ad_blocks then
		    last_block   <= '1'; last_partial <= partial;
		end if;

		if i = 1 then wait until rising_edge(clk); end if;
	       
	       	for j in 0 to 15 loop
                    key  <= vec_key(127-8*j downto 120-8*j);
                    nonce <= vec_nonce(127-8*j downto 120-8*j);
                    data <= vec_ad(127-8*j downto 120-8*j);
               	    wait until rising_edge(clk);
            	end loop;

		wait until ready_block = '1';
            end loop;
		    
	    for j in 0 to 15 loop
                key  <= vec_key(127-8*j downto 120-8*j);
                nonce <= vec_nonce(127-8*j downto 120-8*j);
                data <= vec_ad(127-8*j downto 120-8*j);
                wait until rising_edge(clk);
            end loop;
		
	    wait until ready_tag = '1';
            	    
	    readline(vec_file, vec_line);
            hread(vec_line, vec_tag);
	    for j in 0 to 15 loop
                wait until rising_edge(clk);
	        assert tag = vec_tag(127-8*j downto 120-8*j) report "incorrect tag" severity failure;
            end loop;
	end procedure;
	
        procedure full(constant ad_blocks   : in integer;
		       constant msg_blocks  : in integer;
                       constant ad_partial  : in std_logic;
                       constant msg_partial : in std_logic) is
	begin
	    empty_ad <= '0'; empty_msg <= '0';

	    reset <= '0';
            wait for reset_period;
            reset <= '1';
	    
	    for i in 1 to ad_blocks loop
            	readline(vec_file, vec_line);
		hread(vec_line, vec_ad);
		
		last_block   <= '0'; last_partial <= '0';

		if i = ad_blocks then
		    last_block   <= '1'; last_partial <= ad_partial;
		end if;

		if i = 1 then wait until rising_edge(clk); end if;
	       
	       	for j in 0 to 15 loop
                    key  <= vec_key(127-8*j downto 120-8*j);
                    nonce <= vec_nonce(127-8*j downto 120-8*j);
                    data <= vec_ad(127-8*j downto 120-8*j);
               	    wait until rising_edge(clk);
            	end loop;

		wait until ready_block = '1';
            end loop;
	    
	    for i in 1 to msg_blocks loop
            	readline(vec_file, vec_line);
		hread(vec_line, vec_msg);
		
		last_block   <= '0'; last_partial <= '0';

		if i = msg_blocks then
		    last_block   <= '1'; last_partial <= msg_partial;
		end if;

		--if i = 1 then wait until rising_edge(clk); end if;
	       
	       	for j in 0 to 15 loop
                    key  <= vec_key(127-8*j downto 120-8*j);
                    nonce <= vec_nonce(127-8*j downto 120-8*j);
                    data <= vec_msg(127-8*j downto 120-8*j);
               	    wait until rising_edge(clk);
            	end loop;

		wait until ready_block = '1';
            end loop;
	    
	    for j in 0 to 15 loop
                key  <= vec_key(127-8*j downto 120-8*j);
                nonce <= vec_nonce(127-8*j downto 120-8*j);
                data <= vec_msg(127-8*j downto 120-8*j);
                wait until rising_edge(clk);
            end loop;
		
	    wait until ready_tag = '1';
            	    
	    readline(vec_file, vec_line);
            hread(vec_line, vec_tag);
	    for j in 0 to 15 loop
                wait until rising_edge(clk);
	        assert tag = vec_tag(127-8*j downto 120-8*j) report "incorrect tag" severity failure;
            end loop;

	end procedure;
        
    begin

        file_open(vec_file, "../test/vecs.txt", read_mode);

        while not endfile(vec_file) loop
        --for z in 1 to 1 loop
	    report "round: " & integer'image(round); round := round + 1;
            
	    readline(vec_file, vec_line);
            read(vec_line, vec_in_id); read(vec_line, vec_space);
            read(vec_line, vec_num_ad); read(vec_line, vec_space);
            read(vec_line, vec_num_msg); read(vec_line, vec_space);
            read(vec_line, vec_ad_part); read(vec_line, vec_space);
            read(vec_line, vec_msg_part);
            
            readline(vec_file, vec_line);
            hread(vec_line, vec_key);
            
	    readline(vec_file, vec_line);
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

        end loop;

        assert false report "test passed" severity failure;

    end process;

end;
