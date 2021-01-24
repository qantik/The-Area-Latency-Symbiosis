library ieee;
use ieee.std_logic_1164.all;

entity sbox is
    port (InpxDI : in  std_logic_vector(3 downto 0);
          OupxDO : out std_logic_vector(3 downto 0));
end sbox;

architecture parallel of sbox is

    signal T0xD, T1xD, T2xD, T3xD, B0xD, B1xD, B2xD, B3xD, S1xD, S2xD : std_logic;
    signal Na12xD, Na13xD, No01xD, Na01xD                             : std_logic;

begin

    B0xD <= InpxDI(0);
    B1xD <= InpxDI(1);
    B2xD <= InpxDI(2);
    B3xD <= InpxDI(3);

    Na12xD <= B0xD nand B2xD;
    T1xD   <= B1xD xnor Na12xD;
    Na13xD <= T1xD nand B3xD;
    T0xD   <= B0xD xnor Na13xD;
    No01xD <= T0xD nor T1xD;
    T2xD   <= B2xD xnor No01xD;
    T3xD   <= B3xD xnor T2xD;
    S1xD   <= T1xD xnor T3xD;
    Na01xD <= T0xD nand S1xD;
    S2xD   <= T2xD xnor Na01xD;

    OupxDO <= T0xD & S2xD & S1xD & T3xD;

end parallel;
