library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity mix_col_slice is 
port ( State0:      in std_logic_vector(3 downto 0); 
       State1:      in std_logic_vector(3 downto 0); 
       notLSB:      in std_logic; 
       Poly:        in std_logic; 
       enableStore: in std_logic;
       CLK:         in std_logic;
       MC:          out std_logic_vector(3 downto 0)
       );
end entity mix_col_slice;


architecture behav of mix_col_slice is
 

-- Model the operation as follows:
-- result <= A xor (FF . 1_{poly}) xor (B . 1_{notLSB})
-- which is equivalent to A xor ( nand(FF, 1_poly) xor nand(B, 1_notLSB) )

    signal B_pred, F_pred, X_pred : std_logic_vector(3 downto 0);
    
    signal F: std_logic_vector(3 downto 0);

begin

    process (CLK)
    begin
        if rising_edge(CLK) and enableStore = '1' then
            F <= State0;
        end if;
    end process;

    B_pred(3) <= State1(3) nand notLSB;
    B_pred(2) <= State1(2) nand notLSB;
    B_pred(1) <= State1(1) nand notLSB;
    B_pred(0) <= State1(0) nand notLSB;
    
    F_pred(3) <= F(3) nand Poly;
    F_pred(2) <= F(2) nand Poly;
    F_pred(1) <= F(1) nand Poly;
    F_pred(0) <= F(0) nand Poly;
    
    X_pred(3) <= F_pred(3) xor B_pred(3) xor State0(2);
    X_pred(2) <= F_pred(2) xor B_pred(2) xor State0(1);
    X_pred(1) <= F_pred(1) xor B_pred(1) xor State0(0);
    X_pred(0) <= F_pred(0) xor B_pred(0) xor State0(3);
    
    MC(3) <= X_pred(3) xor X_pred(2) xor State0(0);
    MC(2) <= X_pred(2) xor X_pred(1) xor State0(3);
    MC(1) <= X_pred(1) xor X_pred(0) xor State0(2);
    MC(0) <= X_pred(0) xor X_pred(3) xor State0(1);
    

end architecture;

