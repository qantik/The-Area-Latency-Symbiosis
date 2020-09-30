library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aead is
    generic (r : integer := 3);
    port (clk     : in std_logic;
          reset_n : in std_logic; -- active low

          key   : in std_logic;

          -- A data block is either associated data or plaintext.
          -- last_block indicates whether the current ad or plaintext
          -- block is the last one with last_partial indicating whether
          -- said block is only partially filled.
          data         : in std_logic;
          last_block   : in std_logic;
          last_partial : in std_logic;

          empty_ad     : in std_logic; -- Constant, set at the beginning.
          empty_msg    : in std_logic; -- Constant, set at the beginning.

          ready_block : out std_logic;

          ciphertext  : out std_logic;
          tag         : out std_logic);
end entity aead;

architecture structural of aead is

    signal feed  : std_logic;
    signal b0_en : std_logic;
    signal b1_en : std_logic;
    signal b0    : std_logic;
    signal b1    : std_logic;
    
    signal round   : std_logic_vector(5 downto 0);
    signal cycle   : std_logic_vector(6 downto 0);
    signal round_i : integer range 0 to 41;
    signal cycle_i : integer range 0 to 127;

    signal ready : std_logic;

    signal load     : std_logic;
    signal gift_in  : std_logic;
    signal gift_out : std_logic;

begin
    
    round_i <= to_integer(unsigned(round));
    cycle_i <= to_integer(unsigned(cycle));

    ready_block <= ready;
    ciphertext  <= gift_out xor data;
    tag         <= gift_out;

    gift : entity work.gift port map(clk, reset_n, key, data, empty_ad, empty_msg, last_block, last_partial, round,
                                     cycle, ready, gift_out);
end structural;
