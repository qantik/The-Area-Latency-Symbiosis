library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity lfsr56 is port (
    Clk:            in std_logic;
    one:            in std_logic;
    tick:           in std_logic;
    coreCount:      in std_logic_vector(6 downto 0);
    data:           out std_logic
    );
end;

architecture behav of lfsr56 is

    signal lfsr_p:      std_logic_vector(55 downto 0);
    signal lfsr_n:      std_logic_vector(55 downto 0);
    signal count_i:     integer range 0 to 127;
    signal rot:         std_logic;

begin

    count_i <= to_integer(unsigned(coreCount));
    rot <= '1' when count_i < 56 else '0';

    process (count_i, lfsr_p)
    begin
        data <= lfsr_p(55);
        if count_i > 7 and count_i < 16  then
            data <= lfsr_p(39);
        elsif count_i > 15 and count_i < 24  then
            data <= lfsr_p(23);
        elsif count_i > 23 and count_i < 32  then
            data <= lfsr_p(7);
        elsif count_i > 31 and count_i < 40  then
            data <= lfsr_p(47);
        elsif count_i > 39 and count_i < 48  then
            data <= lfsr_p(31);
        elsif count_i > 47 and count_i < 56  then
            data <= lfsr_p(15);    
        end if;
    end process;

    process (Clk)
    begin
        if rising_edge(Clk) then
            lfsr_p <= lfsr_n;
        end if;
    end process;

    process (lfsr_p, tick, one, rot)
    begin
        lfsr_n <= lfsr_p;
        if one = '1' then
            lfsr_n <= X"02000000000000";
        elsif tick = '1' then
            lfsr_n(7 downto 0) <= lfsr_p(6 downto 0) & lfsr_p(15);
            lfsr_n(15 downto 8) <= lfsr_p(14 downto 8) & lfsr_p(23);
            lfsr_n(23 downto 16) <= lfsr_p(22 downto 16) & lfsr_p(31);
            lfsr_n(31 downto 24) <= lfsr_p(30 downto 24) & lfsr_p(39);
            lfsr_n(39 downto 32) <= lfsr_p(38 downto 32) & lfsr_p(47);
            lfsr_n(47 downto 40) <= lfsr_p(46 downto 40) & lfsr_p(55);
            if lfsr_p(7) = '1' then
                lfsr_n(55 downto 48) <= lfsr_p(54 downto 48) & '0' xor X"95";
            else
                lfsr_n(55 downto 48) <= lfsr_p(54 downto 48) & '0';
            end if;
        elsif rot = '1' then
            lfsr_n(7 downto 0) <= lfsr_p(6 downto 0) & lfsr_p(15);
            lfsr_n(15 downto 8) <= lfsr_p(14 downto 8) & lfsr_p(23);
            lfsr_n(23 downto 16) <= lfsr_p(22 downto 16) & lfsr_p(31);
            lfsr_n(31 downto 24) <= lfsr_p(30 downto 24) & lfsr_p(39);
            lfsr_n(39 downto 32) <= lfsr_p(38 downto 32) & lfsr_p(47);
            lfsr_n(47 downto 40) <= lfsr_p(46 downto 40) & lfsr_p(55);
            lfsr_n(55 downto 48) <= lfsr_p(54 downto 48) & lfsr_p(7);
        end if;
    end process;

end;
