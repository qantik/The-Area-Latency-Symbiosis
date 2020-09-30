library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use work.all;


entity saeb_aead is
 
        
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic_vector(7 downto 0);
          nonce : in std_logic_vector(7 downto 0);

 
          data         : in std_logic_vector(7 downto 0);
          last_block   : in std_logic;
          last_partial : in std_logic;

          empty_ad     : in std_logic; -- Constant, set at the beginning.
          empty_msg    : in std_logic; -- Constant, set at the beginning.

          ready_block  : out std_logic; -- Expecting new block at next rising edge.
          ready_full   : out std_logic; -- AEAD finished.

     
          cipher_ready : out std_logic;
          tag_ready    : out std_logic;

          ciphertext   : out std_logic_vector(7 downto 0);
          tag          : out std_logic_vector(7 downto 0));

end saeb_aead;

architecture saeb of saeb_aead is 


signal StatusxDP,StatusxDN  : std_logic_vector(1 downto 0);
signal ctr:       std_logic_vector(7 downto 0);
signal FcntxDP: integer range 0 to 255;

signal EINxD,rcout ,ct:  std_logic_vector(7 downto 0);

signal aready: std_logic;
signal reset_bc,SRst, process_pt,process_ad,nonce_enc,final_tag, load_mc, load_sbox_st, load_sbox_key, init, add_rc,   kxor,mcx1: std_logic;
signal swap_ctrl: std_logic_vector(2 downto 0);
signal swap_ctrl_k : std_logic_vector(1 downto 0);

 
signal ctr_i,ctr_in:       integer range 0 to 255;
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

ctr   <= std_logic_vector(to_unsigned(ctr_i, 8));

 

process(ctr_i)
begin
    if ctr_i < 175 then 
         ctr_in <= ( ctr_i+1 ) ;
     else
        ctr_in <= 16;
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

   if FcntxDP /=159 then
 
           
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

        if FcntxDP /=159 then
 		 
                  
 
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

    if FcntxDP /=159 then
		  
 
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

    if FcntxDP <175 then
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


    controller0:	    entity controller(behav) port map (Clk, reset, swap_ctrl, load_mc, load_sbox_st, load_sbox_key, init, add_rc,   swap_ctrl_k, kxor,mcx1,rcout,ctr);
--controller0: entity controller(behav) port map (clk, reset, SRst, swap_ctrl, load_mc, load_sbox_st, load_sbox_key, init, add_rc, notLSB, Poly, mctrigger, sbox_sel, swap_ctrl_k, kxor,ctr);

BC_01: entity AES (behav) port map (key,EINxD,clk,reset_bc,swap_ctrl, 
       load_mc,
       load_sbox_st, 
       load_sbox_key, 
       init, 
       add_rc, 
       swap_ctrl_k,
       kxor,
       mcx1,
       rcout,
       ct );

 
 

ciphertext <= data xor ct;

tag <=  ct;



ein_add: process(empty_ad,empty_msg, ct, data, last_block,last_partial,nonce,FcntxDP,StatusxDP)
begin
if FcntxDP < 16 then 
         
         if empty_ad ='1' then 
                   if (FcntxDP =0) then 
                      EINxD<=x"80";

                  elsif FcntxDP =15 then 
                      EINxD<= x"02";
                   else
                      EINxD<= x"00";
                   end if;
        else 
                   if FcntxDP<8 then 
                      EINxD<= data;
                   else
                      if last_block ='1' and last_partial ='1' and FcntxDP = 15 then 
                         EINxD<= x"02";
                      elsif last_block ='1' and last_partial ='0' and FcntxDP = 15 then 
                         EINxD<=x"01";
                      else
                         EINxD<=x"00";
                      end if;
                   end if;
        end if;
elsif FcntxDP>=160 and FcntxDP<168 and StatusxDP="00" then 
                  EINxD <= ct xor data;
elsif FcntxDP>=168 and FcntxDP<176 and StatusxDP="00" then 
           
            if last_block='1' then 
                if last_partial='1' and FcntxDP=175 then           
                      EINxD<= ct xor x"02";
                elsif last_partial='0' and FcntxDP=175 then  
                      EINxD<= ct xor x"01";
                else
                      EINxD<= ct;
                end if;
             else
                EINxD<= ct;
             end if;

 elsif FcntxDP>=160 and FcntxDP<175 and StatusxDP="01" then            
                      
             EINxD<= ct xor nonce;
 elsif FcntxDP=175 and StatusxDP="01" then            
           --  if FcntxDP>=1406 then 
                 EINxD<= ct xor x"03";
           --  else
           --     EINxD<= ct  ;
           --  end if;
elsif FcntxDP>=160 and FcntxDP<168 and StatusxDP="10" then 
             if empty_msg ='1' then 
                    if (FcntxDP =160 )then 
                      EINxD<= ct xor x"80";
                   else
                      EINxD<= ct;
                   end if;
              else
                  EINxD <= ct xor data;
              end if;
elsif FcntxDP>=168 and FcntxDP<176 and StatusxDP="10" then 
           
             if empty_msg ='1' and FcntxDP=175 then 
                      EINxD<= ct xor x"02";
             elsif last_block='1' and empty_msg ='0' then 
                if last_partial='1' and FcntxDP=175 then           
                      EINxD<= ct xor x"02";
                elsif last_partial='0' and FcntxDP=175 then  
                      EINxD<= ct xor x"01";
                else
                      EINxD<= ct;
                end if;
             else
                EINxD<= ct;
             end if;

end if;


end process ein_add; 


aready <= '1' when FcntxDP >=160 and FcntxDP <176 else '0';

cipher_ready <= '1' when StatusxDP = "10" and empty_msg='0' and FcntxDP >=160 and FcntxDP <168 else '0';

tag_ready <= '1' when StatusxDP = "11" and aready ='1' else '0';

end architecture;
 
