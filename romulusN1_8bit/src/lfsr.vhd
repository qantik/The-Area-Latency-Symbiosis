library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity lfsr is port (
    Clk:             in std_logic;
    Rst:             in std_logic;
    tick:            in std_logic;
    rot:             in std_logic;
    rcon:            out std_logic_vector(5 downto 0)
    );
end entity lfsr;


architecture behav of lfsr is

    signal rc:      std_logic_vector(5 downto 0);

begin

    rcon <= rc;

    process (Clk)
    begin
        if rising_edge(Clk) then
            if tick = '1' then
                rc <= rc(4 downto 0) & (rc(5) xor rc(4) xor '1');
            elsif rot = '1' then
                rc <= rc(4 downto 0) & rc(5);
            end if;
            if Rst='0' then
                rc <= "000001";
            end if;
        end if;
    end process;

end architecture;
