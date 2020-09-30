library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bank is
    port (clk   : in std_logic;
         
          x : in std_logic_vector(7 downto 0);
          y : out std_logic_vector(7 downto 0));
end entity bank;

architecture behavioural of bank is
    
    signal bank_curr, bank_next : std_logic_vector(127 downto 0);

    procedure rotate (
        variable k : inout std_logic_vector(127 downto 0);
        variable b  : in std_logic_vector(7 downto 0)) is
    begin
        k := k(119 downto 0) & b;
    end procedure rotate;

begin
        
    y <= bank_curr(127 downto 120);

    fsm : process(clk)
    begin
        if rising_edge(clk) then
            bank_curr <= bank_next;
        end if;
    end process fsm;

    pipe : process(bank_curr, x)
        variable bank_tmp : std_logic_vector(127 downto 0);
        variable bank0    : std_logic_vector(7 downto 0);
        
    begin
        bank_tmp := bank_curr;

        bank0 := x;

        rotate(bank_tmp, bank0);
        bank_next <= bank_tmp;

    end process pipe;

end architecture behavioural;
