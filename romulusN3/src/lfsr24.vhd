library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity lfsr24 is port (
    Clk:            in std_logic;
    one:            in std_logic;
    tick:           in std_logic;
    coreCount:      in std_logic_vector(6 downto 0);
    data:           out std_logic
    );
end;

architecture behav of lfsr24 is

    signal lfsr_p:      std_logic_vector(23 downto 0);
    signal lfsr_n:      std_logic_vector(23 downto 0);
    signal count_i:     integer range 0 to 127;
    signal rot:         std_logic;

begin

    count_i <= to_integer(unsigned(coreCount));
    rot <= '1' when count_i < 24 else '0';

    process (count_i, lfsr_p)
    begin
        data <= lfsr_p(23);
        if count_i > 7 and count_i < 16  then
            data <= lfsr_p(7);
        elsif count_i > 15 then
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
            lfsr_n <= X"020000";
        elsif tick = '1' then
            lfsr_n(7 downto 0) <= lfsr_p(6 downto 0) & lfsr_p(15);
            lfsr_n(15 downto 8) <= lfsr_p(14 downto 8) & lfsr_p(23);
            if lfsr_p(7) = '1' then
                lfsr_n(23 downto 16) <= (lfsr_p(22 downto 16) & '0') xor X"95";
            else
                lfsr_n(23 downto 16) <= lfsr_p(22 downto 16) & '0';
            end if;
        elsif rot = '1' then
            lfsr_n(7 downto 0) <= lfsr_p(6 downto 0) & lfsr_p(15);
            lfsr_n(15 downto 8) <= lfsr_p(14 downto 8) & lfsr_p(23);
            lfsr_n(23 downto 16) <= lfsr_p(22 downto 16) & lfsr_p(7);
        end if;
    end process;

end;
