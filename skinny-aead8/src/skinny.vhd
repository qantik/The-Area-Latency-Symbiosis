library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity SKINNY is
    port (clk     : in std_logic;
          reset_n : in std_logic;
          
	      key   : in std_logic_vector(7 downto 0);
	      nonce : in std_logic_vector(7 downto 0);
          
          data         : in std_logic_vector(7 downto 0);
          last_block   : in std_logic;
          last_partial : in std_logic;
          
	      empty_ad     : in std_logic;
          empty_msg    : in std_logic;
          
	      ready_block  : out std_logic;
	      ready_tag    : out std_logic;
	      ready_cipher : out std_logic;

          tag   : out std_logic_vector(7 downto 0);
          ct    : out std_logic_vector(7 downto 0));
end entity SKINNY;

architecture comb of SKINNY is
 
    signal PTByte:          std_logic_vector(7 downto 0);
    signal SboxOUT:         std_logic_vector(7 downto 0);
    signal SboxIN:          std_logic_vector(7 downto 0);
    signal roundkeybyte:    std_logic_vector(7 downto 0);
    
    signal MCin:            std_logic_vector(31 downto 0);
    signal MCout:           std_logic_vector(31 downto 0);
    
    signal swap_ctrl:       std_logic_vector(2 downto 0); 
    signal load_mc:         std_logic; 
    signal load_sbox_st:    std_logic;
    signal init:            std_logic;
    signal swap_ctrl_k:     std_logic_vector(3 downto 0);
    signal rc_nibble:       std_logic_vector(3 downto 0);
    signal tick:            std_logic;
    signal rc:              std_logic_vector(5 downto 0);
    signal add_key:         std_logic;
    
    signal lfsr_ctl2_en:    std_logic;  
    
    signal key0:            std_logic_vector(7 downto 0);  
    signal key1:            std_logic_vector(7 downto 0);
    signal key2:            std_logic_vector(7 downto 0);
    
    signal count:           std_logic_vector(3 downto 0);  
    signal round:           std_logic_vector(5 downto 0);
    signal cycle:           std_logic_vector(9 downto 0);

    signal boot  : std_logic; -- init signal for controller and skinny lfsr
    signal epoch : std_logic; -- epoch = 0 -> first msg/ad block 

    signal sigma_in, sigma_out : std_logic_vector(7 downto 0);
    signal auth_in, auth_out   : std_logic_vector(7 downto 0);
    
    signal kfsr_init, kfsr_upd : std_logic;
    signal kfsr_out            : std_logic_vector(7 downto 0);

    signal tk0, tk1, tk2 : std_logic_vector(7 downto 0);
    signal flag          : std_logic_vector(7 downto 0);
    signal void          : std_logic_vector(7 downto 0);
    
    type st_type is (st_init, st_ad, st_msg, st_tag, st_end);
    signal st, st_next : st_type;
    
begin

    state_pipeline0: entity state_pipeline(comb) port map(SboxIN, void, MCin, clk, swap_ctrl, load_mc, init, PTByte, roundkeybyte, SboxOUT, MCout, rc_nibble, add_key);

    sbox0:	            entity sbox(comb) port map (SboxIN, SboxOUT); 
    mc0:	            entity mix_col(comb) port map (MCin, MCout);
    lfsr0:	            entity lfsr(comb) port map (Clk, boot, tick, count, round, rc);
    
    controller0:	    entity controller(comb) port map (Clk, reset_n, boot, rc, swap_ctrl, load_mc, init, swap_ctrl_k,  rc_nibble, tick, add_key, lfsr_ctl2_en, cycle);
    
    key_pipeline_tk0: entity key_pipeline1(comb) port map (key0, Clk, init, swap_ctrl_k, tk0);
    key_pipeline_tk1: entity key_pipeline2(comb) port map (key1, Clk, init, swap_ctrl_k, lfsr_ctl2_en, tk1);
    key_pipeline_tk2: entity key_pipeline3(comb) port map (key2, Clk, init, swap_ctrl_k, lfsr_ctl2_en, tk2);
    
    roundkeybyte <= key2 xor key1 xor key0;

    count <= cycle(3 downto 0);
    round <= cycle(9 downto 4);

    sigma_reg : entity work.bank port map (clk, sigma_in, sigma_out);
    auth_reg  : entity work.bank port map (clk, auth_in, auth_out);
    kfsr_reg  : entity work.kfsr port map (clk, kfsr_init, kfsr_upd, kfsr_out);

    tk1 <= nonce;
    tk2 <= key;

    ct  <= void;
    tag <= void xor auth_out;
    
    tk0_mux : process(count, kfsr_out, flag)
        variable count_i : integer range 0 to 15;
    begin
        count_i := to_integer(unsigned(count));
	
	tk0 <= kfsr_out;
	if count_i >= 8 and count_i < 15 then
	     tk0 <= (others => '0');
        elsif count_i = 15 then
	     tk0 <= flag;
        end if;
    end process;

    flag_mux : process(st, last_partial, empty_msg)
    begin
	if st = st_ad then
	    flag <= "00000010";
	    if last_partial = '1' then
	        flag <= "00000011";
            end if;
	elsif st = st_msg then
	    flag <= "00000000";
	    if last_partial = '1' then
	        flag <= "00000001";
            end if;
	elsif st = st_tag then
	    flag <= "00000100";
	    if last_partial = '1' and empty_msg = '0' then
	        flag <= "00000101";
            end if;
	else
	    flag <= "11111111";
        end if;
    end process;

    pt_mux : process(st, data, last_block, last_partial, sigma_out, kfsr_out, flag, count)
    begin
	PTByte <= data;
	if round = "000000" then
	    if (st = st_msg and last_block = '1' and last_partial = '1') then
	        PTByte <= (others => '0');
	    elsif st = st_tag then
		if empty_msg = '1' and empty_ad = '1' then
	            PTByte <= (others => '0');
	        elsif empty_msg  = '1'or last_partial = '0' then
	            PTByte <= sigma_out;
		else
	            PTByte <= sigma_out xor data;
	        end if;
	    end if;
	end if;	
    end process;

    auth_mux : process(st, epoch, auth_out, void, empty_ad, empty_msg, count)
    begin
	auth_in <= auth_out;	    
	if round = "000000" then
	    if (epoch = '0' and st = st_ad) or
	       (st = st_msg and empty_ad = '1' and empty_msg = '0') or
	       (st = st_tag and empty_ad = '1' and empty_msg = '1') then
	        auth_in <= (others => '0');
	    elsif (epoch = '1' and st = st_ad) or
	          (epoch = '0' and st = st_msg and empty_ad = '0') or
		  (epoch = '0' and st = st_tag and empty_ad = '0' and empty_msg = '1') then
		auth_in <= auth_out xor void;
	    end if;
	end if;
    end process;
    
    sigma_mux : process(st, data, epoch, sigma_out, empty_msg, empty_ad, count, last_partial, round)
    begin
	sigma_in <= sigma_out;	    
	if round = "000000" then
	    if epoch = '0' and ((st = st_ad) or
	       (st = st_tag and empty_ad = '1' and empty_msg = '1')) then
	       sigma_in <= (others => '0');
	    elsif st = st_msg then
		    if epoch = '0' and empty_ad = '1' then
		        if last_partial = '0' then
		            sigma_in <= data;
		        else
		            sigma_in <= (others => '0');
		        end if;
		    else
		        if last_partial = '0' then
		            sigma_in <= sigma_out xor data;
		        end if;
		    end if;
	    end if;
	end if;
    end process;

    kfsr_mux : process(st, count, round, last_block)
    begin
	    kfsr_init <= '0';
	    kfsr_upd  <= '0';
	    if st = st_init then
	        kfsr_init <= '1';
        elsif st = st_ad and count = "1111" and round = "110111" and last_block = '1'then
	        kfsr_init <= '1';
	    end if;

	    if st = st_ad and last_block = '0' and count = "1111" and round = "110111" then
	        kfsr_upd  <= '1';
	    elsif st = st_msg and count = "1111" and round = "110111" then
	        kfsr_upd  <= '1';
	    end if;
    end process;

    fsm_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            st <= st_init;
        elsif rising_edge(clk) then
            st <= st_next;
        end if;
    end process;
    
    epoch_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            epoch <= '0';
        elsif rising_edge(clk) then
            -- set epoch to 0 for the first block ad/msg block, and
            -- to 1 for the following blocks
            if count = "1111" and round = "110111" then
		if last_block = '0' then
        	    epoch <= '1';
		else
        	    epoch <= '0';
		end if;
             end if;
        end if;
    end process;
    
    fsm : process(st, round, count, empty_ad, empty_msg, last_block, last_partial)
    begin

        st_next <= st;

        ready_block  <= '0';
        ready_tag    <= '0';
        ready_cipher <= '0';
        
        if st /= st_init and round = "000000" then
            ready_block  <= '1';
        end if;
        	
	boot <= '0';

        case st is
            when st_init =>
        	boot <= '1';
        	if empty_ad = '1' and empty_msg = '1' then
        	    st_next <= st_tag;
        	elsif empty_ad = '0' and empty_msg = '1' then
        	    st_next <= st_ad;
        	elsif empty_ad = '1' and empty_msg = '0' then
        	    st_next <= st_msg;
        	else
        	    st_next <= st_ad;
        	end if;
	    when st_ad =>
	        st_next <= st_ad;
		if count = "1111" and round = "110111" and last_block = '1' then
		    st_next <= st_msg;	    
		    if empty_msg = '1' then
		        st_next <= st_tag;
		    end if;
		end if;
	    when st_msg =>
	        st_next <= st_msg;
		if count = "1111" and round = "110111" and last_block = '1' then
		    st_next <= st_tag;	    
		end if;
	    when st_tag =>
	        st_next <= st_tag;
		if count = "1111" and round = "110111" then
		    st_next <= st_end;	    
		end if;
	    when st_end =>
	        st_next      <= st_end;
		ready_tag    <= '1';
		ready_cipher <= '1';

        end case;
    end process;

end architecture comb;

