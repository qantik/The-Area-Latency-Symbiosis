library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity mix_col is port (
    X:      in std_logic_vector(31 downto 0);
    Y:      out std_logic_vector(31 downto 0)
    );
end entity mix_col;


architecture comb of mix_col is
begin

    gen_loop: for i in 0 to 7 generate
        Y(31-i) <= X(31-i) xor X(15-i) xor X(7-i);
        Y(23-i) <= X(31-i);
        Y(15-i) <= X(23-i) xor X(15-i);
        Y(7-i) <= X(31-i) xor X(15-i);
    end generate gen_loop;

end architecture;
