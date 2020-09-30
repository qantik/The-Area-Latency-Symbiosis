library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity kfsr is
    port (clk   : in std_logic;
          
   	  init : in std_logic; 
   	  upd  : in std_logic; 
          y    : out std_logic_vector(7 downto 0));
end entity kfsr;

architecture behavioural of kfsr is
    
    signal kfsr_curr, kfsr_next : std_logic_vector(63 downto 0);

    procedure rotate (
        variable k : inout std_logic_vector(63 downto 0);
        variable b  : in std_logic_vector(7 downto 0)) is
    begin
        k := b & k(63 downto 8);
    end procedure rotate;

begin
        
    y <= kfsr_curr(7 downto 0);

    fsm : process(clk)
    begin
        if rising_edge(clk) then
            kfsr_curr <= kfsr_next;
        end if;
    end process fsm;

    pipe : process(kfsr_curr, init, upd)
        variable kfsr_tmp : std_logic_vector(63 downto 0);
        variable kfsr_rot : std_logic_vector(63 downto 0);
        variable kfsr0    : std_logic_vector(7 downto 0);
        
    begin
        kfsr_tmp := kfsr_curr;
	kfsr0    := kfsr_tmp(7 downto 0);

	if init = '1' then
	    kfsr_tmp := X"00000000000000" & "00000001";
        elsif upd = '1' then
            rotate(kfsr_tmp, kfsr0);
	    kfsr_tmp(3) := kfsr_tmp(3) xor kfsr_tmp(63); 
	    kfsr_tmp(2) := kfsr_tmp(2) xor kfsr_tmp(63); 
	    kfsr_tmp(0) := kfsr_tmp(0) xor kfsr_tmp(63); 

	    kfsr_rot(0) := kfsr_tmp(63);
	    for i in 0 to 62 loop
		kfsr_rot(63-i) := kfsr_tmp(63-i-1);
	    end loop;
	    kfsr_tmp := kfsr_rot;
	else
            rotate(kfsr_tmp, kfsr0);
	end if;

        kfsr_next <= kfsr_tmp;

    end process pipe;

end architecture behavioural;
