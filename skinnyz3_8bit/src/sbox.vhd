library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SBOX is
    port (X : in  std_logic_vector (7 downto 0);
          Y : out std_logic_vector (7 downto 0));
end SBOX;

architecture comb of SBOX is

    signal o, p : std_logic_vector(39 downto 0);

begin

    p(7 downto 0) <= x;
    
    GEN : for i in 0 to 3 generate
        o((8 * i + 7) downto (8 * i + 4))  <= p((8 * i + 7) downto (8 * i + 5)) & (p(8 * i + 4) xor
                                              (P(8 * i + 7) nor p(8 * i + 6)));
        o((8 * i + 3) downto (8 * i + 0))  <= p((8 * i + 3) downto (8 * i + 1)) & (p(8 * i + 0) xor
                                              (p(8 * i + 3) nor P(8 * I + 2)));
        p((8 * i + 15) downto (8 * i + 8)) <= o((8 * i + 2)) & o((8 * I + 1)) & o((8 * i + 7)) &
                                              o((8 * i + 6)) & o((8 * I + 4)) & o((8 * i + 0)) &
                                              o((8 * i + 3)) & o((8 * I + 5));
    end generate;
    
    Y <= o(31 downto 27) & o(25) & o(26) & o(24);

end;
