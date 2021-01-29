library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use work.all;


entity skinny_aead is
 
        
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic;
          nonce : in std_logic;

 
          data         : in std_logic;
          last_block   : in std_logic;
          last_partial : in std_logic;

          empty_ad     : in std_logic; -- Constant, set at the beginning.
          empty_msg    : in std_logic; -- Constant, set at the beginning.

          ready_block  : out std_logic; -- Expecting new block at next rising edge.
          ready_full   : out std_logic; -- AEAD finished.

     
          cipher_ready : out std_logic;
          tag_ready    : out std_logic;

          ciphertext   : out std_logic;
          tag          : out std_logic);

end skinny_aead;

architecture skinny of skinny_aead is 

    signal StatusxDP,StatusxDN  : std_logic_vector(1 downto 0);
    signal ctr:       std_logic_vector(12 downto 0);
    signal FcntxDP: integer range 0 to 8191;

    signal EINxD,  ct, aready,reset_lf: std_logic;
    signal bkey : std_logic_vector(2 downto 0);
    signal reset_bc,SRst, process_pt,process_ad,process_tag,nonce_enc,final_tag, load_mc, load_sbox_st, load_sbox_key, init, add_rc, notLSB, Poly, mctrigger, sbox_sel, kxor: std_logic;
    signal swap_ctrl: std_logic_vector(2 downto 0);
    signal swap_ctrl_k : std_logic_vector(3 downto 0);
    signal rc_bit, add_key, lfsr_ctl3: std_logic;
    signal lfsr_ctl2  : std_logic_vector(1 downto 0);
    signal ctr_i,ctr_in:       integer range 0 to 8191;

    signal lfsrp,lfsrn,up1 ,up2,r : std_logic_vector(63 downto 0);

    signal up: std_logic_vector(7 downto 0);
    signal u1,u2,u3 ,s,a,s1,a1,s2,reset_l,tick,rot,eout: std_logic;
    signal rc : std_logic_vector(5 downto 0	);

    signal SigmaxDP, SigmaxDN, AuthxDP,AuthxDN: std_logic_vector(127 downto 0);

    signal finn,finp: std_logic;


begin

    p_clk: process (reset, clk)
            begin
            if reset='0' then
                StatusxDP  <= "00";
                ctr_i <= 0;
                lfsrp <= x"0100000000000000";
                finp <='1';
                -- SigmaxDP<= (others=>'0');
                -- AuthxDP<=  (others=>'0');
            elsif clk'event and clk ='1' then
                    ctr_i <= ctr_in; 
                    StatusxDP  <= StatusxDN;
                SigmaxDP<= SigmaxDN;
            AuthxDP<=AuthxDN;
                    lfsrp <= lfsrn;
                    finp<=finn;
            end if;
    end process p_clk;

ctr   <= std_logic_vector(to_unsigned(ctr_i, 13));
 
 

process(ctr_i)
begin
    if ctr_i < 7295 then 
         ctr_in <= ( ctr_i+1 ) ;
     else
         ctr_in <= 0;
    end if;
end process;


process(ctr_i,finp)
begin
    if ctr_i < 127 and finp='1' then 
         finn <= '1' ;
     else
         finn <= '0';
    end if;
end process;
FcntxDP <= ctr_i;  

    p_main: process (StatusxDP, FcntxDP, empty_ad, empty_msg, last_block, last_partial)
    
    begin
    
    
    reset_l <= '1';

    
    
    process_pt <='0';
    process_ad <='0'; 
    process_tag<='0';



    case StatusxDP is 
    when "00" => process_ad<='1';

                    if empty_ad ='1' then 
                            if empty_msg ='1' then 
                            StatusxDN <="10";
                            else
                            StatusxDN <="01";reset_l <= '0';
                            end if;
                            
                        else

                            if FcntxDP /=7295 then
                                StatusxDN <= StatusxDP;

                            elsif last_block='0' then 
                                StatusxDN <= StatusxDP;
                            elsif last_block='1'  then
                                if empty_msg='1' then 
                                    StatusxDN <= "10";reset_l <= '0';
                                else
                                    StatusxDN <= "01";reset_l <= '0';
                                end if;
                            end if;        
                        
                    end if;

    when "01" =>  process_pt<='1';

                            if FcntxDP /=7295 then
                                StatusxDN <= StatusxDP;
                            elsif last_block='0'  then
    
                                StatusxDN <= StatusxDP;
                            else
                                StatusxDN <= "10";
                            end if;
                            
    
    when "10" =>  process_tag<='1';  StatusxDN <="10";

        
    when others => 
                    StatusxDN <= StatusxDP;

    end case;
    end process;
    reset_lf<='0' when ctr_i=0 else '1';

        lfsr0:        entity lfsr(behav) port map (Clk, reset_lf  , tick, rot, rc);
        controller0:  entity controller(behav) port map (Clk, reset, rc, swap_ctrl, load_mc, load_sbox_st, init, swap_ctrl_k,  rc_bit, tick, add_key, lfsr_ctl2, lfsr_ctl3, rot,ctr);

        BC_01: entity work.SKINNY(behav) port map (bkey,EINxD,clk,reset_bc,CT, rc, swap_ctrl, load_mc, load_sbox_st, init, swap_ctrl_k,  rc_bit, tick, add_key, lfsr_ctl2, lfsr_ctl3, rot );
    
    eout <= '1' when ctr_i>= 7168 else '0';

    ciphertext <= CT xor data when process_pt='1' and last_block='1' and last_partial='1' else CT;
    tag <= CT xor AuthxDP(127);



    tag_ready<= '1' when process_tag='1' and eout='1' else '0';
    cipher_ready <= '1' when process_pt='1' and eout='1' else '0';


    EINxD <= SigmaxDP(127) when process_tag='1' and (empty_msg='0' or empty_ad='0') else 
            '0' when (process_pt='1' and last_block='1' and last_partial='1') or ( empty_msg='1' and empty_ad='1') else
            data;

    s<= (SigmaxDP(127) xor data) when (process_pt='1' and ((ctr_i<128 and last_partial='0') or (last_block='1' and last_partial='1' and eout='1'))) or (process_tag='1' and  ctr_i<128) else SigmaxDP(127);
    a<= (AuthxDP (127) xor ct) when (process_ad='1' or process_tag='1') and eout='1' else AuthxDP(127);


    a1<='0' when empty_ad='1' or finp='1' else a; 
    s1<='0' when empty_msg='1' or finp='1' 
    else s;

    s2 <= data when empty_ad='1' and empty_msg='0' and finp='1' else s1;

    SigmaxDN <= SigmaxDP(126 downto 0) & s2; -- else SigmaxDP;
    AuthxDN  <= AuthxDP(126 downto 0) & a1 ;-- else AuthxDP; 


    bkey(2)<= key;
    bkey(1)<= nonce;
    bkey(0)<= lfsrp(63) when ctr_i<64  
            else '1'  when (ctr_i =125 and (process_tag='1')) or  (ctr_i =126 and (process_ad='1')) or (ctr_i =127 and ((last_block='1' and last_partial='1' and process_tag='0') or (process_tag='1' and empty_msg='0' and last_partial='1') ))
            else '0'   ;
    u1<=  lfsrp(7) xor lfsrp(59);
    u2<=  lfsrp(7) xor lfsrp(58);
    u3<=  lfsrp(7) xor lfsrp(56);
    up <= lfsrp(62 downto 60) & u1 & u2 & lfsrp(57)& u3 & lfsrp(7);  

    up1 <= up & lfsrp(54 downto 48)& lfsrp(63) & lfsrp(46 downto 40) & lfsrp(55) & lfsrp(38 downto 32)& lfsrp(47) & lfsrp(30 downto 24) & lfsrp(39) & 
        lfsrp(22 downto 16)& lfsrp(31) & lfsrp(14 downto 8)& lfsrp(23) & lfsrp(6 downto 0) & lfsrp(15); 

    up2 <= up1(62 downto 0) & up1(63);   

    r <= lfsrp(62 downto 0) & lfsrp(63);

    lfsrn <=   up1 when ctr_i=64
    else r   when ctr_i<64 
    else x"0100000000000000" when reset_l <= '0'  
    else lfsrp; 



end architecture;
