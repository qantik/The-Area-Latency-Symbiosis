library ieee;
use ieee.std_logic_1164.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity rho is port (
    clk:                    in std_logic;
    coreCount:              in std_logic_vector(6 downto 0);
    data:                   in std_logic;
    statebit:               in std_logic;
    rho_overwrite_zero:     in std_logic;
    ctbit:                  out std_logic
    );
end;

architecture behav of rho is

    signal tmp:             std_logic;
    signal tmp_next:        std_logic;
    signal msg:             std_logic_vector(6 downto 0);
    signal msg_next:        std_logic_vector(6 downto 0);
    signal padbit:          std_logic;

begin

    tmp_next <= statebit;

    process (coreCount, statebit, data, rho_overwrite_zero, tmp, msg)
    begin
        msg_next(6 downto 1) <= msg(5 downto 0);
        msg_next(0) <= tmp xor (data and not rho_overwrite_zero);
        if to_integer(unsigned(coreCount(2 downto 0))) = 0 then
            msg_next(0) <= statebit xor (data and not rho_overwrite_zero);
        end if;

        ctbit <= msg(6);
        if to_integer(unsigned(coreCount(2 downto 0))) = 7 then
            ctbit <= msg(6) xor statebit;
        end if;

    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            msg <= msg_next;
            tmp <= tmp_next;
        end if;
    end process;

end;
