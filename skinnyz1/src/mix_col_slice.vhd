library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity mix_col_slice is
port ( X:      in std_logic_vector(3 downto 0);
       Y:      out std_logic_vector(3 downto 0)
       );
end entity mix_col_slice;


architecture behav of mix_col_slice is

begin

    Y(3) <= X(3) xor X(1) xor X(0);
    Y(2) <= X(3);
    Y(1) <= X(2) xor X(1);
    Y(0) <= X(3) xor X(1);

end architecture;
