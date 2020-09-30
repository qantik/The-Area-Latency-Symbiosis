library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gift is
    port (clk     : in std_logic;
          reset_n : in std_logic;

          key : in std_logic;
          pt  : in std_logic;
          
          ready : out std_logic;
          ct    : out std_logic);
end entity gift;

architecture behavioural of gift is
    signal count : unsigned(12 downto 0);
    signal cycle : std_logic_vector(6 downto 0);
    signal round : std_logic_vector(5 downto 0);

    signal round_key      : std_logic;
    signal round_constant : std_logic;

    signal void : std_logic;
begin

    cycle <= std_logic_vector(count(6 downto 0));
    round <= std_logic_vector(count(12 downto 7));

    ct <= void;

    state_pipe : entity work.state port map (clk, pt, round_key, round_constant, round, cycle, ready, void);
    key_pipe   : entity work.key port map (clk, key, round, cycle, round_key);
    rc_pipe    : entity work.lfsr port map (clk, reset_n, round, cycle, round_constant);

    counter : process(clk, reset_n)
    begin
        if reset_n = '0' then
            count <= (others => '0');
        elsif rising_edge(clk) then
            count <= (count + 1) mod 8192; 
        end if;
    end process counter;

end architecture behavioural;
