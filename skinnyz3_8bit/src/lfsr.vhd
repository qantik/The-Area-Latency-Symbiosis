library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity lfsr is port (
    Clk:             in std_logic;
    Rst:             in std_logic;
    tick:            in std_logic;
    rcon:            out std_logic_vector(5 downto 0)
    );
end entity lfsr;


architecture comb of lfsr is

    signal rc: std_logic_vector(5 downto 0);

begin

    rcon <= rc;

    process (Rst, Clk)
    begin
        if Rst='0' then
            rc <= "000001";
        elsif Clk'event and Clk ='1' then
            if tick = '1' then
                rc <= rc(4 downto 0) & (rc(5) xor rc(4) xor '1');
            end if;
        end if;
    end process;

end architecture;
