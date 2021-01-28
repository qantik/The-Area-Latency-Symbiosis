library ieee;
use ieee.std_logic_1164.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity aead_controller is port (
    clk:                    in std_logic;
    reset:                  in std_logic;
    last_block:             in std_logic;
    empty_ad:               in std_logic;
    odd_ad_blocks:          in std_logic;
    empty_msg:              in std_logic;
    incomplete:             in std_logic;
    coreRound:              in std_logic_vector(5 downto 0);
    coreCount:              in std_logic_vector(6 downto 0);
    domain:                 out std_logic_vector(4 downto 0);
    core_reset:             out std_logic;
    lfsr_rot:               out std_logic;
    lfsr_tick:              out std_logic;
    lfsr_one:               out std_logic;
    en_xor_data:            out std_logic;
    st_init:                out std_logic;
    key_init:               out std_logic;
    rho_overwrite_zero:     out std_logic;
    ready_block:            out std_logic;
    ready_key:              out std_logic;
    cipher_ready:           out std_logic;
    tag_ready:              out std_logic;
    aead_done:              out std_logic
    );
end;

architecture behav of aead_controller is

    signal processing_ad:           boolean;
    signal processing_msg:          boolean;
    signal loading:                 boolean;
    signal lfsr_plus_one:           boolean;
    signal first_block_p:           boolean;
    signal first_block_n:           boolean;
    signal core_reset_x:            std_logic;
    signal enc_last_round:          boolean;
    signal first_round:             boolean;
    signal last_count:              boolean;
    signal core_enc_done:           boolean;
    signal core_first_round_done:   boolean;

    type FSM_State is (INIT, AD_EVEN, AD_ODD, NONCE_START, NONCE, TAG, DONE, MSG, MSG_NONCE);
    signal state_p:                 FSM_State;
    signal state_n:                 FSM_State;

begin

    st_init <= '1' when to_integer(unsigned(coreRound)) = 0 and first_block_p else '0';
    key_init <= '1' when to_integer(unsigned(coreRound)) = 0 else '0';

    core_reset <= core_reset_x;
    core_reset_x <= '0' when state_p = INIT or (core_enc_done and (state_p = NONCE or state_p = AD_EVEN or state_p = MSG_NONCE)) else '1';
    ready_key <= not core_reset_x;

    first_round <= to_integer(unsigned(coreRound)) = 0;
    enc_last_round <= to_integer(unsigned(coreRound)) = 55;
    last_count <= to_integer(unsigned(coreCount)) = 127;
    core_enc_done <= last_count and enc_last_round;
    core_first_round_done <= last_count and first_round;

    rho_overwrite_zero <= '1' when (state_p = TAG) or (state_p = MSG and empty_msg = '1') else '0';
    lfsr_tick <= '1' when (core_enc_done and ((state_p = AD_EVEN and last_block = '0') or state_p = MSG_NONCE)) or (state_p = AD_ODD and last_count) else '0';

    lfsr_one <= '1' when state_p = INIT or (state_p = NONCE and core_enc_done) else '0';

    processing_ad <= state_p = AD_ODD or state_p = AD_EVEN or state_p = NONCE;
    processing_msg <= state_p = MSG or state_p = MSG_NONCE or state_p = TAG;

    domain(0) <= '1' when (incomplete = '1' or empty_msg = '1') and state_p = MSG else '0';
    domain(1) <= '1' when (incomplete = '1' or empty_ad = '1') and state_p = NONCE else '0';
    domain(2) <= '1' when state_p = MSG or state_p = MSG or state_p = TAG else '0';
    domain(3) <= '1' when state_p = AD_ODD or state_p = NONCE else '0';
    domain(4) <= '1' when state_p = NONCE or (state_p = MSG and (last_block = '1' or empty_msg = '1')) else '0';

    tag_ready <= '1' when to_integer(unsigned(coreCount)) = 7 and state_p = TAG else '0';

    cipher_ready <= '1' when (state_p = MSG and empty_msg = '0') and to_integer(unsigned(coreCount)) = 7 else '0';

    ready_block <= '1' when (state_p = INIT and empty_ad = '0') or (core_enc_done and not (state_p = AD_EVEN and last_block = '1') and not (state_p = MSG_NONCE and (last_block = '1' or empty_msg = '1'))) else '0';

    aead_done <= '1' when state_p = DONE and to_integer(unsigned(coreCount)) = 7 else '0';

    en_xor_data <= '1' when state_p = AD_ODD or (state_p = MSG and empty_msg = '0') or (state_p = NONCE and odd_ad_blocks = '1' and first_round and empty_ad = '0') else '0';

    state_reg : process(clk)
    begin
        if rising_edge(clk) then
            state_p <= state_n;
            first_block_p <= first_block_n;
            if reset = '0' then
                state_p <= INIT;
                first_block_p <= false;
            end if;
        end if;
    end process;

    fsm : process(state_p, core_enc_done, core_first_round_done, last_block, empty_ad, empty_msg, first_block_p, odd_ad_blocks)
    begin
        state_n <= state_p;
        first_block_n <= first_block_p;
        case state_p is
            when INIT =>
                first_block_n <= true;
                if empty_ad = '1' then
                    state_n <= NONCE;
                else
                    state_n <= AD_ODD;
                end if;

            when AD_ODD =>
                if (last_block = '1' and odd_ad_blocks = '1') then
                    state_n <= NONCE;
                end if;
                if core_first_round_done then
                    state_n <= AD_EVEN;
                    first_block_n <= false;
                end if;

            when AD_EVEN =>
                if core_enc_done then
                    state_n <= AD_ODD;
                    if last_block = '1' then
                        state_n <= NONCE;
                    end if;
                end if;

            when NONCE =>
                if core_enc_done then
                    first_block_n <= false;
                    state_n <= MSG;
                end if;


            when MSG =>
                if core_first_round_done then
                    state_n <= MSG_NONCE;
                end if;

            when MSG_NONCE =>
                if core_enc_done then
                    if last_block = '1' or empty_msg = '1' then
                        state_n <= TAG;
                    else
                        state_n <= MSG;
                    end if;
                end if;

            when TAG =>
                if core_first_round_done then
                    state_n <= DONE;
                end if;

            when others =>
                state_n <= DONE;
        end case;
    end process;

end;
