library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gift is
    port (clk     : in std_logic;
          reset_n : in std_logic;

          key : in std_logic;
          pt  : in std_logic;

          empty_ad  : in std_logic;
          empty_msg : in std_logic;

          last_block   : in std_logic;
          last_partial : in std_logic;

    	  r : out std_logic_vector(5 downto 0);
    	  c : out std_logic_vector(6 downto 0);
          
          ready : out std_logic;
          ct    : out std_logic);
end entity gift;

architecture behavioural of gift is
    signal count : unsigned(12 downto 0);
    signal cycle : std_logic_vector(6 downto 0);
    signal round : std_logic_vector(5 downto 0);

    signal round_key      : std_logic;
    signal round_constant : std_logic;

    signal void  : std_logic;
    
    signal epoch : unsigned(1 downto 0);
    signal stall : unsigned(1 downto 0);

begin

    cycle <= std_logic_vector(count(6 downto 0));
    round <= std_logic_vector(count(12 downto 7));

    r <= round;
    c <= cycle;

    ct <= void;

    state_pipe : entity work.state port map (clk, pt, round_key, round_constant, last_block, epoch, stall, round, cycle, ready, void);
    key_pipe   : entity work.key port map (clk, key, last_block, stall, round, cycle, round_key);
    rc_pipe    : entity work.lfsr port map (clk, reset_n, round, cycle, round_constant);

    counter : process(clk, reset_n)
    begin
        if reset_n = '0' then
            count <= (others => '0');
	        epoch <= "00";
	        stall <= "00";
        elsif rising_edge(clk) then
            count <= (count + 1) mod 5120;
	        
            if count = 2000 and epoch = 0 then
                --epoch <= epoch + 1;
                if empty_ad = '1' then
                    epoch <= epoch + 2;
                else
                    epoch <= epoch + 1;
                end if;
            elsif epoch /= 0 and stall = 1 and count = 0 then
                epoch <= epoch + 1;
	        end if;

            if count = 127 and (last_block = '1') then
                count <= (others => '0');
                if last_partial = '0' then
                    stall <= "10";
                else
                    stall <= "01";
                end if;
            elsif count = 127 and stall = 2 then
                count <= (others => '0');
            end if;
            if count = 127 and stall > 0 and last_block = '0' then
                stall <= stall - 1;
            end if;
        end if;
    end process counter;

end architecture behavioural;
