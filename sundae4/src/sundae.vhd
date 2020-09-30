library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aead is
    port (clk     : in std_logic;
          reset_n : in std_logic;
          
	  key : in std_logic_vector(3 downto 0);
          
          data         : in std_logic_vector(3 downto 0);
          last_block   : in std_logic;
          last_partial : in std_logic;
          
	  empty_ad     : in std_logic;
          empty_msg    : in std_logic;
          
	  ready_block  : out std_logic;
	  ready_tag    : out std_logic;
	  ready_cipher : out std_logic;

          tag   : out std_logic_vector(3 downto 0);
          ct    : out std_logic_vector(3 downto 0));
end entity aead;

architecture behavioural of aead is
    signal count : unsigned(10 downto 0);
    signal cycle : std_logic_vector(4 downto 0);
    signal round : std_logic_vector(5 downto 0);

    signal round_key      : std_logic_vector(3 downto 0);
    signal pt             : std_logic_vector(3 downto 0);
    signal round_constant : std_logic_vector(31 downto 0);
    
    signal void : std_logic_vector(3 downto 0);

    signal stall_count : std_logic;
    signal halt : std_logic_vector(1 downto 0);
    
    type st_type is (st_init, st_ad, st_tag, st_msg, st_end);
    signal st, st_next : st_type;

begin
    
    cycle <= std_logic_vector(count(4 downto 0));
    round <= std_logic_vector(count(10 downto 5));

    ct  <= void xor data;
    tag <= void;

    state_pipe : entity work.state port map (clk, pt, round_key, round_constant, halt(0), last_partial, round, cycle, void);
    key_pipe   : entity work.key port map (clk, key, halt(1), round, cycle, round_key);
    rc_pipe    : entity work.lfsr port map (clk, reset_n, halt(1), round, cycle, round_constant);

    counter : process(clk, reset_n)
    begin
        if reset_n = '0' then
            count      <= (others => '0');
        elsif rising_edge(clk) then
            count <= (count + 1) mod 1280;

	    -- Reset count after first stall
	    if count = 31 and halt(0) = '1' then
	        count <= (others => '0');
	    end if;
        end if;
    end process counter;

    pt_mux : process(st, data, void)
    begin
        if st = st_init then
	    pt <= data;
	elsif st = st_ad or st = st_tag then
	    pt <= void xor data;
	else
	    pt <= void;
	end if;
    end process;
    
    stall_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
	    stall_count <= '0';
        elsif rising_edge(clk) then
      	    if last_block = '1' and count = "00000011111" then
	        stall_count <= not stall_count;
	    end if;
        end if;
    end process;

    stall_mux : process(stall_count, last_block, round)
    begin
	halt <= "00";
	if round = "000000" and last_block = '1' then
	    if stall_count = '0' then
		halt <= "01";
	    else
		halt <= "10";
	    end if;
	end if;
    end process stall_mux;

    fsm_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            st <= st_init;
        elsif rising_edge(clk) then
            st <= st_next;
        end if;
    end process;
    
    fsm : process(st, empty_ad, empty_msg, count, round, cycle, last_block)
    begin

        st_next <= st;

	ready_block  <= '0';
	ready_tag    <= '0';
	ready_cipher <= '0';
   	
	if st /= st_init and round = "000000" then
	    ready_block  <= '1';
	end if;

        case st is
	    
	    when st_init =>
		 st_next <= st_init;
		 if count = 1279 then
		     if empty_ad = '1' and empty_msg = '1' then
			 st_next <= st_end;
	             elsif empty_ad = '0' then
			 st_next <= st_ad;
		     elsif empty_ad = '1' and empty_msg = '0' then
			 st_next <= st_tag;
		     end if;
	         end if;
	
	    when st_ad =>
		st_next <= st_ad;
		if count = 1279 and last_block = '1' then
		    if empty_msg = '0' then
	                 st_next <= st_tag;
		    else
			 st_next <= st_end;
		    end if; 
	        end if;

	    when st_tag => 
	        st_next <= st_tag;
		if count = 1279 and last_block = '1' then
	            st_next <= st_msg;
		end if;

	    when st_msg =>
	        st_next   <= st_msg;
		ready_tag <= '1';
		
		if count = 1279 and last_block = '1' then
		    st_next <= st_end;
	        end if;

	    when st_end =>
		st_next <= st_end;
		
		ready_cipher <= '1';
		if empty_msg = '1' then
		    ready_tag <= '1';
		end if;

        end case;
    end process;

end architecture behavioural;
