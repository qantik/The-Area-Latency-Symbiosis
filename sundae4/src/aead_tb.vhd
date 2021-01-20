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

    signal data         : std_logic_vector(3 downto 0);
    
    signal last_block   : std_logic := '0';
    signal last_partial : std_logic := '0';
    signal empty_ad     : std_logic := '0';
    signal empty_msg    : std_logic := '0';

    signal ad    : std_logic_vector(3 downto 0);
    signal key   : std_logic_vector(3 downto 0);

    -- Output signals.
    signal ready_block  : std_logic;
    signal ready_tag    : std_logic;
    signal ready_cipher : std_logic;
    
    signal ct  : std_logic_vector(3 downto 0);
    signal tag : std_logic_vector(3 downto 0);
    
    signal cont_flag       : boolean := true;
    file testio, tb_output : text;

    constant clk_period   : time := 100 ns;
    constant reset_period : time := 25 ns;
    
    procedure reord_key (variable k : inout std_logic_vector(127 downto 0)) is
        variable t : std_logic_vector(127 downto 0);
    begin
	    k := k(127 downto 96) & k(31 downto 0) & k(95 downto 64) & k(63 downto 32);
    end procedure reord_key;

begin

    aead : entity work.aead
        port map (clk          => clk,
                  reset_n      => reset,
                  key          => key,
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
        if cont_flag then
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        else
            wait;
        end if;
    end process;
    
    test : process
        variable vec_line  : line;
        variable vec_space : character;
        
        variable vec_in_id, vec_out_id     : integer;
        variable vec_num_ad, vec_num_msg   : integer;
        variable vec_ad_part, vec_msg_part : std_logic;
        variable vec_init                  : std_logic_vector(127 downto 0);
        variable vec_key                   : std_logic_vector(127 downto 0);
        variable vec_ad, vec_msg           : std_logic_vector(127 downto 0);
        variable vec_cipher, vec_tag       : std_logic_vector(127 downto 0);
        variable cmp                       : std_logic_vector(127 downto 0);

        variable round : integer := 0;

	procedure nodata(constant void : in integer := 0) is
	begin

	    data <= vec_init(127 downto 124);
	    key <= vec_key(127 downto 124);

	    empty_ad   <= '1'; empty_msg <= '1'; 

	    reset <= '0';
        wait for reset_period;
        reset <= '1';
            
	    for i in 1 to 31 loop
            wait until rising_edge(clk);
            data <= vec_init(127-4*i downto 124-4*i);
            key  <= vec_key(127-4*i downto 124-4*i);
        end loop;

	    wait until rising_edge(clk);
        wait until ready_cipher = '1';
            
	    readline(testio, vec_line);
        hread(vec_line, vec_tag);

	    for i in 0 to 31 loop
            wait until rising_edge(clk);
                   
            cmp(127-4*i downto 124-4*i) := tag;
	        assert tag = vec_tag(127-4*i downto 124-4*i) report "incorrect tag" severity failure;
        end loop;
        
        hwrite(vec_line, cmp);
        writeline(tb_output, vec_line);
	end procedure;
        
	procedure noad(constant msg_blocks : in integer;
                       constant partial   : in std_logic) is
	begin
	    data <= vec_init(127 downto 124);
	    key <= vec_key(127 downto 124);

	    empty_ad   <= '1'; empty_msg    <= '0'; 
        last_block <= '0'; last_partial <= '0';

	    reset <= '0';
        wait for reset_period;
        reset <= '1';
            
	    for i in 1 to 31 loop
            wait until rising_edge(clk);
            data <= vec_init(127-4*i downto 124-4*i);
            key  <= vec_key(127-4*i downto 124-4*i);
        end loop;

	    wait until rising_edge(clk);
        wait until ready_block = '1';
            
	    for i in 1 to msg_blocks loop
         	readline(testio, vec_line);
		    hread(vec_line, vec_msg);
		
		    last_block <= '0'; last_partial <= '0';

		    if i = msg_blocks then
		        last_block   <= '1'; last_partial <= partial;
		    end if;
	       
	       	for j in 0 to 31 loop
                data <= vec_msg(127-4*j downto 124-4*j);
                key  <= vec_key(127-4*j downto 124-4*j);
           	    wait until rising_edge(clk);
            end loop;

            data <= (others => '0');
		    key <= (others => '0');
	
            if i = msg_blocks then
		        wait until ready_tag = '1';
		        last_block <= '0'; last_partial <= '0';
		    
            	readline(testio, vec_line);
                hread(vec_line, vec_tag);
	    	    for j in 0 to 31 loop
                    key <= vec_key(127-4*j downto 124-4*j); -- already feed key
            	    wait until rising_edge(clk);
            
                    cmp(127-4*j downto 124-4*j) := tag;
	    	        assert tag = vec_tag(127-4*j downto 124-4*j) report "incorrect tag" severity failure;
                end loop;
                    
                hwrite(vec_line, cmp);
                writeline(tb_output, vec_line);
		    
		        if msg_blocks = 1 then
		            last_block <= '1';
		        end if;
		    else
		        wait until ready_block = '1';
            end if;
        end loop;

	    for i in 1 to msg_blocks loop
		    wait until ready_block = '1';
                	
		    readline(testio, vec_line);
		    hread(vec_line, vec_msg);
		    
		    key <= (others => '0');
		    last_block <= '0'; last_partial <= '0';

		    if i = msg_blocks then
		        last_block <= '1';
		    end if;
	       
	       	for j in 0 to 31 loop
                wait until rising_edge(clk);
                data <= vec_msg(127-4*j downto 124-4*j);
                key  <= vec_key(127-4*j downto 124-4*j);
            end loop;

            data <= (others => '0');
        end loop;

	end procedure;

    procedure nomsg(constant ad_blocks : in integer;
                        constant partial   : in std_logic) is
	begin
	    data <= vec_init(127 downto 124);
	    key  <= vec_key(127 downto 124);

	    empty_ad   <= '0'; empty_msg <= '1'; 
	    last_block <= '0'; last_partial <= '0';

	    reset <= '0';
        wait for reset_period;
        reset <= '1';
            
	    for i in 1 to 31 loop
            wait until rising_edge(clk);
            data <= vec_init(127-4*i downto 124-4*i);
            key  <= vec_key(127-4*i downto 124-4*i);
        end loop;

	    wait until rising_edge(clk);
        wait until ready_block = '1';
            
	    for i in 1 to ad_blocks loop
          	readline(testio, vec_line);
		    hread(vec_line, vec_ad);
		
		    last_block <= '0'; last_partial <= '0';

		    if i = ad_blocks then
		        last_block   <= '1'; last_partial <= partial;
		    end if;
	       
	       	for j in 0 to 31 loop
                data <= vec_ad(127-4*j downto 124-4*j);
                key  <= vec_key(127-4*j downto 124-4*j);
                wait until rising_edge(clk);
            end loop;

            data <= (others => '0');
		    key <= (others => '0');
	
            if i = ad_blocks then
		        wait until ready_tag = '1';
		        last_block <= '0'; last_partial <= '0';
		    
            	readline(testio, vec_line);
                hread(vec_line, vec_tag);
	    	    for j in 0 to 31 loop
                    wait until rising_edge(clk);

                    cmp(127-4*j downto 124-4*j) := tag;
	    	        assert tag = vec_tag(127-4*j downto 124-4*j) report "incorrect tag" severity failure;
                end loop;
                    
                hwrite(vec_line, cmp);
                writeline(tb_output, vec_line);
		    else
		        wait until ready_block = '1';
            end if;
        end loop;
	end procedure;
	
    procedure full(constant ad_blocks   : in integer;
                   constant msg_blocks  : in integer;
                   constant ad_partial  : in std_logic;
                   constant msg_partial : in std_logic) is
	begin
	    data <= vec_init(127 downto 124);
	    key  <= vec_key(127 downto 124);

	    empty_ad   <= '0'; empty_msg <= '0'; 
        last_block <= '0'; last_partial <= '0';

	    reset <= '0';
        wait for reset_period;
        reset <= '1';
            
	    for i in 1 to 31 loop
            wait until rising_edge(clk);
            data <= vec_init(127-4*i downto 124-4*i);
            key  <= vec_key(127-4*i downto 124-4*i);
        end loop;

	    wait until rising_edge(clk);
        wait until ready_block = '1';
	    
	    for i in 1 to ad_blocks loop
          	readline(testio, vec_line);
		    hread(vec_line, vec_ad);
		
		    last_block <= '0'; last_partial <= '0';

		    if i = ad_blocks then
		        last_block   <= '1'; last_partial <= ad_partial;
		    end if;
	       
	       	for j in 0 to 31 loop
                data <= vec_ad(127-4*j downto 124-4*j);
                key  <= vec_key(127-4*j downto 124-4*j);
            	wait until rising_edge(clk);
            end loop;

            data <= (others => '0');
		    key <= (others => '0');
		    wait until ready_block = '1';
	
        end loop;
            
	    for i in 1 to msg_blocks loop
          	readline(testio, vec_line);
		    hread(vec_line, vec_msg);
		
		    last_block <= '0'; last_partial <= '0';

		    if i = msg_blocks then
		        last_block   <= '1'; last_partial <= msg_partial;
		    end if;
	       
	       	for j in 0 to 31 loop
                data <= vec_msg(127-4*j downto 124-4*j);
                key  <= vec_key(127-4*j downto 124-4*j);
           	    wait until rising_edge(clk);
            end loop;

            data <= (others => '0');
		    key <= (others => '0');
	
            if i = msg_blocks then
		        wait until ready_tag = '1';
		        last_block  <= '0'; last_partial <= '0';
		    
                readline(testio, vec_line);
                hread(vec_line, vec_tag);
	    	    for j in 0 to 31 loop
                    key  <= vec_key(127-4*j downto 124-4*j); -- already feed key
                    wait until rising_edge(clk);

                    cmp(127-4*j downto 124-4*j) := tag;
	      	        assert tag = vec_tag(127-4*j downto 124-4*j) report "incorrect tag" severity failure;
                end loop;
                    
                hwrite(vec_line, cmp);
                writeline(tb_output, vec_line);
		    
		        if msg_blocks = 1 then
		            last_block <= '1';
		        end if;
		    else
		        wait until ready_block = '1';
            end if;
        end loop;

	    for i in 1 to msg_blocks loop
		    wait until ready_block = '1';
                	
		    readline(testio, vec_line);
		    hread(vec_line, vec_msg);
		    
		    key <= (others => '0');
		    last_block <= '0'; last_partial <= '0';

		    if i = msg_blocks then
		        last_block <= '1';
		    end if;
	       
	       	for j in 0 to 31 loop
           	    wait until rising_edge(clk);
                data <= vec_msg(127-4*j downto 124-4*j);
                key  <= vec_key(127-4*j downto 124-4*j);
            end loop;

            data <= (others => '0');
        end loop;

	end procedure;
        
    begin

        file_open(testio, "Testinput.txt", read_mode);
        file_open(tb_output, "tb_output.txt", write_mode);

        while not endfile(testio) loop
            round := round + 1;
            
	        readline(testio, vec_line);
            read(vec_line, vec_in_id); read(vec_line, vec_space);
            read(vec_line, vec_num_ad); read(vec_line, vec_space);
            read(vec_line, vec_num_msg); read(vec_line, vec_space);
            read(vec_line, vec_ad_part); read(vec_line, vec_space);
            read(vec_line, vec_msg_part);
            
	        readline(testio, vec_line);
            hread(vec_line, vec_init);

            readline(testio, vec_line);
            hread(vec_line, vec_key);
	        reord_key(vec_key);

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

        wait for clk_period;
        
        file_close(testio);
        file_close(tb_output);

        cont_flag <= false;
        
        wait;

    end process;

end;
