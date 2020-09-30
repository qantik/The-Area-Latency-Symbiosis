library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gift is
    port (clk     : in std_logic;
          reset_n : in std_logic;

          key : in std_logic_vector(3 downto 0);
          pt  : in std_logic_vector(3 downto 0);
          
          ready : out std_logic;
          ct    : out std_logic_vector(3 downto 0));
end entity gift;

architecture behavioural of gift is
    signal count : unsigned(10 downto 0);
    signal cycle : std_logic_vector(4 downto 0);
    signal round : std_logic_vector(5 downto 0);

    signal round_key      : std_logic_vector(3 downto 0);
    signal round_constant : std_logic_vector(5 downto 0);

    signal void : std_logic_vector(3 downto 0);
begin

    cycle <= std_logic_vector(count(4 downto 0));
    round <= std_logic_vector(count(10 downto 5));

    ct <= void;

    state_pipe : entity work.state port map (clk, pt, round_key, round_constant, round, cycle, ready, void);
    key_pipe   : entity work.key port map (clk, key, round, cycle, round_key);
    rc_pipe    : entity work.lfsr port map (clk, reset_n, round, cycle, round_constant);

    counter : process(clk, reset_n)
    begin
        if reset_n = '0' then
            count <= (others => '0');
        elsif rising_edge(clk) then
            count <= (count + 1) mod 2048; 
        end if;
    end process counter;

end architecture behavioural;
