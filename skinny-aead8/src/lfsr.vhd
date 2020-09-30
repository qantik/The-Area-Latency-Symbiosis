library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity lfsr is 
port ( Clk:             in std_logic; 
       Rst:             in std_logic; 
       tick:            in std_logic;
       count:           in std_logic_vector(3 downto 0);
       round:           in std_logic_vector(5 downto 0);
       rcon:            out std_logic_vector(5 downto 0)
       );
end entity lfsr;


architecture comb of lfsr is

    signal rc: std_logic_vector(5 downto 0);

begin

rcon <= rc;

    process (Clk)
	variable round_i : integer range 0 to 63;
	variable count_i : integer range 0 to 15;
    begin
	round_i := to_integer(unsigned(round));
        count_i := to_integer(unsigned(count));
        
	--if Rst = '0' then
        --    rc <= "000001";
        if Clk'event and Clk ='1' then
	    if Rst = '1' then
                rc <= "000001";
	    elsif round_i = 55 and count_i = 15 then
                rc <= "000001";
            elsif tick = '1' then
                rc <= rc(4 downto 0) & (rc(5) xor rc(4) xor '1');
            end if;
        end if;
    end process;

end architecture;

