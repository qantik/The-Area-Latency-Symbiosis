library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity key_pipeline2 is 
port (  roundkeybit: 		out std_logic;
        Clk:        in std_logic;
        init:       in std_logic;
        swap_ctrl_k: in std_logic_vector(3 downto 0);
        lfsr_ctl2:  in std_logic_vector(1 downto 0);
        KeyBit:     in std_logic
		);
end entity key_pipeline2;


architecture behav of key_pipeline2 is
		
    signal k_p, k_n: std_logic_vector(127 downto 0);

    procedure rotate (
        variable s : inout std_logic_vector(127 downto 0);
        variable b:	in std_logic
        ) is
        begin
            s := s(126 downto 0) & b;
        end rotate;

    procedure swap (
        variable a: 	inout std_logic; 
        variable b:		inout std_logic
        ) is
            variable tmp : std_logic;
        begin
            tmp := a;
            a := b;
            b := tmp;
        end swap;
	
begin


    process (Clk)
    begin
        if Clk'event and Clk = '1' then
            k_p <= k_n;
        end if;
    end process;

    process (k_p, init, swap_ctrl_k, KeyBit, lfsr_ctl2)
        variable s : std_logic_vector(127 downto 0);
        variable nextbit:	std_logic;
        variable tmp: std_logic_vector(7 downto 0);
    begin
        s := k_p;
        
        
        
        
        if swap_ctrl_k(0) = '1' then
            swap(s(127 - 56), s(127 - 120));
        end if;
        if swap_ctrl_k(1) = '1' then
            swap(s(127 - 48), s(127 - 56));
        end if;
        if swap_ctrl_k(2) = '1' then
            swap(s(127 - 24), s(127 - 56));
        end if;
        if swap_ctrl_k(3) = '1' then
            swap(s(127 - 24), s(127 - 8));
        end if;

        -- enable below for TK2
        if lfsr_ctl2(0) = '1' then
            s(127) := s(127) xor s(125);
        end if;
        
        if lfsr_ctl2(1) = '1' then
            swap(s(127), s(126));
        end if;    

        nextbit := s(127);
        if init = '1' then
            nextbit := KeyBit;
        end if;
        
        rotate(s, nextbit);
        
        
        
        roundkeybit <= s(8);
        k_n <= s;
    end process;

end architecture;

