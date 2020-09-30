library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use work.all;


entity saeb_aead is
 
        
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

end saeb_aead;

architecture saeb of saeb_aead is 


signal StatusxDP,StatusxDN  : std_logic_vector(1 downto 0);
signal ctr:       std_logic_vector(10 downto 0);
signal FcntxDP: integer range 0 to 2047;

signal EINxD,  ct, aready: std_logic;
signal reset_bc,SRst, process_pt,process_ad,nonce_enc,final_tag, load_mc, load_sbox_st, load_sbox_key, init, add_rc, notLSB, Poly, mctrigger, sbox_sel, kxor: std_logic;
signal swap_ctrl: std_logic_vector(2 downto 0);
signal swap_ctrl_k : std_logic_vector(1 downto 0);

 
signal ctr_i,ctr_in:       integer range 0 to 2047;
begin

p_clk: process (reset, clk)
         begin
           if reset='0' then
             StatusxDP  <= "00";
             ctr_i <= 0;
           elsif clk'event and clk ='1' then
                  ctr_i <= ctr_in; 
                  StatusxDP  <= StatusxDN;
 
           end if;
end process p_clk;

ctr   <= std_logic_vector(to_unsigned(ctr_i, 11));

 

process(ctr_i)
begin
    if ctr_i < 1407 then 
         ctr_in <= ( ctr_i+1 ) ;
     else
        ctr_in <= 128;
    end if;
end process;

FcntxDP <= ctr_i;  

p_main: process (StatusxDP, FcntxDP, empty_ad, empty_msg, last_block, last_partial)
  
   begin
   
 
   reset_bc <= '1';

 
   SRst<='1';
   process_pt <='0';
   process_ad <='0'; 

   nonce_enc<='0';
   final_tag<='0';

   StatusxDN <= StatusxDP;
   
   case StatusxDP is 
 

   when "00" =>  process_ad <='1';

   if FcntxDP /=1279 then
 
           
                  StatusxDN <= StatusxDP;
   else
                 if last_block='1' or empty_ad = '1' then
                       StatusxDN <= "01";
 
                 else
                       StatusxDN <= StatusxDP; 
 
                 end if;
  
                 SRst  <= '0';
   end if;  
                   
            
   when "01" => nonce_enc <= '1';

        if FcntxDP /=1279 then
 		 
                  
 
                  StatusxDN <= StatusxDP;
       else 
               --  if empty_msg = '1' then
                   
                 --      StatusxDN <= "11";
                 --else
                       StatusxDN <= "10";
 
               
                 --end if;

 
                 SRst  <= '0';
   end if;  
   
   when "10" => process_pt <= '1';

    if FcntxDP /=1279 then
		  
 
                  StatusxDN <= StatusxDP;
   else
                 if last_block = '1' then
                    StatusxDN <= "11";
 
                 else
                    StatusxDN <= StatusxDP; 
 
                 end if;

 
                 SRst  <= '0';
   end if;  


   when "11" => final_tag <= '1';

    if FcntxDP <1407 then
		  if FcntxDP = 0 then
      			   reset_bc <= '0';
                  end if;

                 StatusxDN <= StatusxDP;
   else
 
                 reset_bc <= '0';   
                 SRst  <= '0';
   end if;  



  when others =>  
                 StatusxDN <= StatusxDP;
 
end case;
end process p_main;

controller0:	    entity controller(behav) port map (clk, reset, SRst, swap_ctrl, load_mc, load_sbox_st, load_sbox_key, init, add_rc, notLSB, Poly, mctrigger, sbox_sel, swap_ctrl_k, kxor,ctr);

BC_01: entity AES (behav) port map (key,EINxD,clk,reset_bc,swap_ctrl, 
       load_mc,
       load_sbox_st, 
       load_sbox_key, 
       init, 
       add_rc, 
       notLSB, 
       Poly,
       mctrigger ,
       sbox_sel,
       swap_ctrl_k,
       kxor,ct );

 
 

ciphertext <= data xor ct;

tag <=  ct;



ein_add: process(empty_ad,empty_msg, ct, data, last_block,last_partial,nonce,FcntxDP,StatusxDP)
begin
if FcntxDP < 128 then 
         
         if empty_ad ='1' then 
                   if (FcntxDP =0 or FcntxDP =126 )then 
                      EINxD<= '1';
                   else
                      EINxD<= '0';
                   end if;
        else 
                   if FcntxDP<64 then 
                      EINxD<= data;
                   else
                      if last_block ='1' and last_partial ='1' and FcntxDP = 126 then 
                         EINxD<= '1';
                      elsif last_block ='1' and last_partial ='0' and FcntxDP = 127 then 
                         EINxD<='1';
                      else
                         EINxD<='0';
                      end if;
                   end if;
        end if;
elsif FcntxDP>=1280 and FcntxDP<1344 and StatusxDP="00" then 
                  EINxD <= ct xor data;
elsif FcntxDP>=1344 and FcntxDP<1408 and StatusxDP="00" then 
           
            if last_block='1' then 
                if last_partial='1' and FcntxDP=1406 then           
                      EINxD<= ct xor '1';
                elsif last_partial='0' and FcntxDP=1407 then  
                      EINxD<= ct xor '1';
                else
                      EINxD<= ct;
                end if;
             else
                EINxD<= ct;
             end if;

 elsif FcntxDP>=1280 and FcntxDP<1400 and StatusxDP="01" then            
                      
             EINxD<= ct xor nonce;
 elsif FcntxDP>=1400 and FcntxDP<1408 and StatusxDP="01" then            
             if FcntxDP>=1406 then 
                 EINxD<= ct xor '1';
             else
                 EINxD<= ct  ;
             end if;
elsif FcntxDP>=1280 and FcntxDP<1344 and StatusxDP="10" then 
             if empty_msg ='1' then 
                    if (FcntxDP =1280 )then 
                      EINxD<= ct xor '1';
                   else
                      EINxD<= ct;
                   end if;
              else
                  EINxD <= ct xor data;
              end if;
elsif FcntxDP>=1344 and FcntxDP<1408 and StatusxDP="10" then 
           
             if empty_msg ='1' and FcntxDP=1406 then 
                      EINxD<= ct xor '1';
             elsif last_block='1' and empty_msg ='0' then 
                if last_partial='1' and FcntxDP=1406 then           
                      EINxD<= ct xor '1';
                elsif last_partial='0' and FcntxDP=1407 then  
                      EINxD<= ct xor '1';
                else
                      EINxD<= ct;
                end if;
             else
                EINxD<= ct;
             end if;

end if;


end process ein_add; 


aready <= '1' when FcntxDP >=1280 and FcntxDP <1408 else '0';

cipher_ready <= '1' when StatusxDP = "10" and empty_msg='0' and FcntxDP >=1280 and FcntxDP <1344 else '0';

tag_ready <= '1' when StatusxDP = "11" and aready ='1' else '0';

end architecture;
 
