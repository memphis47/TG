-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--  cMIPS, a VHDL model of the classical five stage MIPS pipeline.
--  Copyright (C) 2013  Roberto Andre Hexsel
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, version 3.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UART internals; the external interface is defined in io.vhdl
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- control register, least significant byte only
-- b0..b2: transmit/receive clock speed
--         000: 1/4 CPU clock rate
--         111: 1/256 CPU clock rate
-- b3=1:   signal interrupt on RX buffer full, new octet is available
-- b4=1:   signal interrupt on TX buffer empty, space is available
-- b5..b7: ignored, not used

-- status register, least significant byte only
-- b0: overurn error, last octet received overwrote previous in buffer
-- b1: framing error, last octet was not framed by START, STOP bits
-- b2: not used, returns zero
-- b3: interrupt pending on RX buffer full
-- b4: interrupt pending on TX buffer empty
-- b5: receive buffer is full
-- b6: transmit buffer is empty
-- b7: not used, returns zero
-- when CPU reads status register bits 0,1,3,4 are cleared

library ieee; use ieee.std_logic_1164.all;
use work.p_WIRES.all;

entity uart_int is
  port(clk, rst: in std_logic;
       s_ctrl, s_stat, s_tx, s_rx: in std_logic;  -- select registers
       ent:    in  reg32;               -- input
       sai:    out reg32;               -- output
       txdat:  out std_logic;           -- serial transmission
       rxdat:  in  std_logic;           -- serial reception
       interr: out std_logic;           -- interrupt request
       bit_rt: out reg3);               -- communication speed, 1/2-1/64 clock
end uart_int;

architecture estrutural of uart_int is

  component register8 is
    port(rel, rst, ld: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic_vector);
  end component register8;

  component counter8 is
    port(rel, rst, ld, en: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic_vector);
  end component counter8;

  component par_ser10 is
    port(rel, rst, ld, desl: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic);
  end component par_ser10;

  component ser_par10 is
    port(rel, rst, desl: in  std_logic;
         D:            in  std_logic;
         Q:            out std_logic_vector);
  end component ser_par10;

  component sr_latch_rst is
    port(rst, set, clr: in  std_logic; Q: out std_logic);
  end component sr_latch_rst;

  component FFD is
    port(clk, rst, set, D : in std_logic; Q : out std_logic);
  end component FFD;

  -- state machine for interface transmission-CPU
  type txcpu_state is (st_idle, st_check, st_done);
  signal txcpu_current_st, txcpu_next_st : txcpu_state;
  
  -- state machine for transmission circuit
  type tx_state is (st_idle, st_check, st_start,
                    st_b0, st_b1, st_b2, st_b3, st_b4, st_b5, st_b6, st_b7,
                    st_stop, st_done);
  signal tx_current_st, tx_next_st : tx_state;


  -- state machine for interface reception-CPU
  type rxcpu_state is (st_idle, st_copy, st_check, st_error);
  signal rxcpu_current_st, rxcpu_next_st : rxcpu_state;
  
  -- state machine for reception circuit
  type rx_state is (st_idle, st_check, st_start,
                    st_b0, st_b1, st_b2, st_b3, st_b4, st_b5, st_b6, st_b7,
                    st_stop, st_done);
  signal rx_current_st, rx_next_st : rx_state;

  -- for debugging only
  signal tx_dbg_st, txcpu_dbg_st, rx_dbg_st, rxcpu_dbg_st : integer; 

  signal ctrl, status, txreg, rxreg, received : reg8;
  signal tx_bit_rt, rx_bit_rt : reg8;
  signal car_tx, des_tx, tx_bfr_empt, tx_shr_full, en_tx_clk, txclk : std_logic;
  signal car_rx, des_rx, rx_bfr_full, en_rx_clk, done_rx, rxclk : std_logic;
  signal a_overrun, a_framing, sel_delayed, reset_rxck : std_logic;
  signal sta_xmit_sto, sta_recv_sto : reg10;
  signal err_overrun, err_framing : std_logic;
  signal rx_int_set, interr_RX_full, tx_int_set, interr_TX_empty : std_logic;
  
begin

  sai <= x"000000" & received when s_rx = '1'   else
         x"000000" & status;

  -- testing only: tells remote unit of transmission speed
  bit_rt <= ctrl(2 downto 0);
  
  U_ctrl:  register8 port map (clk,rst,s_ctrl, ent(7 downto 0), ctrl);
  
  status <= '0' & tx_bfr_empt & rx_bfr_full &
            interr_TX_empty & interr_RX_full & 
            '0' & err_framing & err_overrun;

  interr <= interr_TX_empty or interr_RX_full;
  
  -- TRANSMISSION ===========================================================
  U_txreg: register8 port map (clk,rst,s_tx, ent(7 downto 0), txreg);

  -- transmission baud rate generator 1/4 to 1/128 of CPU clock rate
  U_bit_rt_tx: counter8 port map (clk,rst,car_tx,en_tx_clk,x"00",tx_bit_rt);
  with ctrl(2 downto 0) select
    txclk <= tx_bit_rt(1) when b"000",
             tx_bit_rt(2) when b"001",
             tx_bit_rt(3) when b"010",
             tx_bit_rt(4) when b"011",
             tx_bit_rt(5) when b"100",
             tx_bit_rt(6) when b"101",
             tx_bit_rt(7) when others;

  sta_xmit_sto <= '1'& txreg & '0';      -- start (b0), octet, stop (b9)
  U_transmit: par_ser10 port map (txclk, rst, car_tx, des_tx,
                                   sta_xmit_sto, txdat);

  tx_int_set <= ctrl(4) and car_tx;
  U_tx_int: sr_latch_rst
    port map (rst, tx_int_set, sel_delayed, interr_TX_empty);
  
  -- this state machine contols the CPU-transmission interface -----------
  U_TXCPU_st_reg: process(rst,clk)
  begin
    if rst = '0' then
      txcpu_current_st <= st_idle;
    elsif rising_edge(clk) then
      txcpu_current_st <= txcpu_next_st;
    end if;
  end process U_TXCPU_st_reg;

  txcpu_dbg_st <= integer(txcpu_state'pos(txcpu_current_st)); -- for debugging

  U_TXCPU_st_transitions: process(txcpu_current_st,s_tx,tx_shr_full)
  begin
    case txcpu_current_st is
      when st_idle =>                   -- 0
        car_tx      <= '0';
        tx_bfr_empt <= '1';
        if s_tx = '1' then
          txcpu_next_st <= st_check;
        else
          txcpu_next_st <= st_idle;
        end if;
      when st_check =>                  -- 1
        tx_bfr_empt <= '0';
        if tx_shr_full = '1' then
          txcpu_next_st <= st_check;
        else
          txcpu_next_st <= st_done;
        end if;
      when st_done =>                   -- 2
        car_tx <= '1';
        txcpu_next_st <= st_idle;
      when others =>
        assert false report "TX-CPU stateMachine broken"
          & integer'image(txcpu_state'pos(txcpu_current_st)) severity failure;
    end case;
  end process U_TXCPU_st_transitions;   ------------------------------------
  

  -- state machine controls data transmission circuit ----------------------
  U_TX_st_reg: process(rst,clk)
  begin
    if rst = '0' then
      tx_current_st <= st_idle;
    elsif rising_edge(clk) then
      tx_current_st <= tx_next_st;
    end if;
  end process U_TX_st_reg;

  tx_dbg_st <= integer(tx_state'pos(tx_current_st));  -- debugging
  
  U_TX_st_transitions: process(tx_current_st,car_tx,txclk)
  begin
    case tx_current_st is
      when st_idle =>
        tx_shr_full <= '0';
        des_tx      <= '0';
        en_tx_clk   <= '0';
        if car_tx = '1' then
          tx_next_st <= st_check;
        else
          tx_next_st <= st_idle;
        end if;
      when st_check =>
        en_tx_clk <= '1';
        tx_shr_full <= '1';
        tx_next_st <= st_start;
      when st_start =>
        des_tx <= '1';
        if rising_edge(txclk) then      -- synchronize CPUclock with TXclock
          tx_next_st <= st_b0;
        else
          tx_next_st <= st_start;
        end if;
      when st_b0 =>
        if rising_edge(txclk) then
          tx_next_st <= st_b1;
        else
          tx_next_st <= st_b0;
        end if;
      when st_b1 =>
        if rising_edge(txclk) then
          tx_next_st <= st_b2;
        else
          tx_next_st <= st_b1;
        end if;
      when st_b2 =>
        if rising_edge(txclk) then
          tx_next_st <= st_b3;
        else
          tx_next_st <= st_b2;
        end if;
      when st_b3 =>
        if rising_edge(txclk) then
          tx_next_st <= st_b4;
        else
          tx_next_st <= st_b3;
        end if;
      when st_b4 =>
        if rising_edge(txclk) then
          tx_next_st <= st_b5;
        else
          tx_next_st <= st_b4;
        end if;
      when st_b5 =>
        if rising_edge(txclk) then
          tx_next_st <= st_b6;
        else
          tx_next_st <= st_b5;
        end if;
      when st_b6 =>
        if rising_edge(txclk) then
          tx_next_st <= st_b7;
        else
          tx_next_st <= st_b6;
        end if;
      when st_b7 =>
        if rising_edge(txclk) then
          tx_next_st <= st_stop;
        else
          tx_next_st <= st_b7;
        end if;
      when st_stop =>
        if rising_edge(txclk) then
          tx_next_st <= st_done;
        else
          tx_next_st <= st_stop;
        end if;
      when st_done =>
        des_tx      <= '0';
        tx_shr_full <= '1';
        tx_next_st  <= st_idle;
      when others =>
        assert false report "TX stateMachine broken"
          & integer'image(tx_state'pos(tx_current_st)) severity failure;
    end case;
  end process U_TX_st_transitions;   -- -----------------------------------



  -- RECEPTION =============================================================
  
  U_rxreg: register8 port map (clk,rst, car_rx, rxreg, received);
  
  U_bit_rt_rx: counter8
    port map (clk,rst,reset_rxck,en_rx_clk,x"00",rx_bit_rt);
  with ctrl(2 downto 0) select
    rxclk <= rx_bit_rt(1) when b"000",
             rx_bit_rt(2) when b"001",
             rx_bit_rt(3) when b"010",
             rx_bit_rt(4) when b"011",
             rx_bit_rt(5) when b"100",
             rx_bit_rt(6) when b"101",
             rx_bit_rt(7) when others;

  U_receive: ser_par10 port map (rxclk, rst, des_rx, rxdat, sta_recv_sto);
  rxreg <= sta_recv_sto(8 downto 1);

  -- framing error: 10th bit not a STOP=1 or 1st bit not a START=0
  a_framing <= '1' when ( (car_rx = '1') and
                          (sta_recv_sto(9)/='1' or sta_recv_sto(0)/='0') )
               else '0';
  U_framing: sr_latch_rst port map (rst, a_framing, sel_delayed, err_framing);
  
  U_overrun: sr_latch_rst port map (rst, a_overrun, sel_delayed, err_overrun);

  U_delay:   FFD port map (clk, rst, '1', s_stat, sel_delayed);

  rx_int_set <= ctrl(3) and done_rx;
  U_rx_int: sr_latch_rst
    port map (rst, rx_int_set, sel_delayed, interr_RX_full);

  -- SM controls reception-CPU interface -------------------------------
  U_RXCPU_st_reg: process(rst,clk)
  begin
    if rst = '0' then
      rxcpu_current_st <= st_idle;
    elsif rising_edge(clk) then
      rxcpu_current_st <= rxcpu_next_st;
    end if;
  end process U_RXCPU_st_reg;

  rxcpu_dbg_st <= integer(rxcpu_state'pos(rxcpu_current_st));  -- debugging

  U_RXCPU_st_transitions: process(rxcpu_current_st, done_rx, s_rx)
  begin
    case rxcpu_current_st is
      when st_idle =>                   -- 0
        car_rx      <= '0';
        rx_bfr_full <= '0';
        a_overrun   <= '0';
        if done_rx = '1' then           -- rx buffer full
          rxcpu_next_st <= st_copy;
        else
          rxcpu_next_st <= st_idle;
        end if;
      when st_copy =>                   -- 1
        rx_bfr_full <= '1';
        car_rx      <= '1';
        rxcpu_next_st <= st_check;
      when st_check =>                  -- 2
        car_rx <= '0';
        if done_rx = '1' then
          rxcpu_next_st <= st_error;
        elsif s_rx = '1' then
          rxcpu_next_st <= st_idle;
        else
          rxcpu_next_st <= st_check;
        end if;
      when st_error =>                  -- 3
        a_overrun     <= '1';    -- assert overrun error, char overwritten
        rxcpu_next_st <= st_check;
      when others =>
        assert false report "RX-CPU stateMachine broken"
          & integer'image(rxcpu_state'pos(rxcpu_current_st)) severity failure;
    end case;
  end process U_RXCPU_st_transitions; --------------------------------------

  
  -- SM controls data reception circuit ------------------------------------
  U_RX_st_reg: process(rst,clk)
  begin
    if rst = '0' then
      rx_current_st <= st_idle;
    elsif rising_edge(clk) then
      rx_current_st <= rx_next_st;
    end if;
  end process U_RX_st_reg;

  rx_dbg_st <= integer(rx_state'pos(rx_current_st));  -- debugging only
  
  U_RX_st_transitions: process(rx_current_st, rxclk, rxdat)
  begin
    case rx_current_st is
      when st_idle =>
        done_rx    <= '0';
        des_rx     <= '0';
        reset_rxck <= '0';
        en_rx_clk  <= '0';
        if falling_edge(rxdat) then    -- start bit
          rx_next_st <= st_check;
        else
          rx_next_st <= st_idle;
        end if;
      when st_check =>
        reset_rxck <= '1';
        en_rx_clk  <= '1';
        rx_next_st <= st_start;
      when st_start =>
        reset_rxck <= '0';
        des_rx <= '1';
        if falling_edge(rxclk) then
          rx_next_st <= st_b0;
        else
          rx_next_st <= st_start;
        end if;
      when st_b0 =>
        if falling_edge(rxclk) then
          rx_next_st <= st_b1;
        else
          rx_next_st <= st_b0;
        end if;
      when st_b1 =>
        if falling_edge(rxclk) then
          rx_next_st <= st_b2;
        else
          rx_next_st <= st_b1;
        end if;
      when st_b2 =>
        if falling_edge(rxclk) then
          rx_next_st <= st_b3;
        else
          rx_next_st <= st_b2;
        end if;
      when st_b3 =>
        if falling_edge(rxclk) then
          rx_next_st <= st_b4;
        else
          rx_next_st <= st_b3;
        end if;
      when st_b4 =>
        if falling_edge(rxclk) then
          rx_next_st <= st_b5;
        else
          rx_next_st <= st_b4;
        end if;
      when st_b5 =>
        if falling_edge(rxclk) then
          rx_next_st <= st_b6;
        else
          rx_next_st <= st_b5;
        end if;
      when st_b6 =>
        if falling_edge(rxclk) then
          rx_next_st <= st_b7;
        else
          rx_next_st <= st_b6;
        end if;
      when st_b7 =>
        if falling_edge(rxclk) then
          rx_next_st <= st_stop;
        else
          rx_next_st <= st_b7;
        end if;
      when st_stop =>
        if falling_edge(rxclk) then
          rx_next_st <= st_done;
        else
          rx_next_st <= st_stop;
        end if;
      when st_done =>
        en_rx_clk  <= '0';
        des_rx     <= '0';
        done_rx    <= '1';
        rx_next_st <= st_idle;
      when others =>
        assert false report "RX stateMachine broken"
          & integer'image(rx_state'pos(rx_current_st)) severity failure;
    end case;
  end process U_RX_st_transitions;

    
end estrutural;
-- -------------------------------------------------------------------



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 8 bit counter, reset=0 asynchronous, load=1 synchronous
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee; use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.p_WIRES.all;

entity counter8 is
  port(rel, rst, ld, en: in  std_logic;
       D:               in  reg8;
       Q:               out reg8);
end counter8;

architecture functional of counter8 is
  signal count: reg8;
begin

  process(rel, rst, ld, en)
  begin
    if rst = '0' then
      count <= x"00";
    elsif ld = '1' and rising_edge(rel) then
      count <= D;
    elsif en = '1' and rising_edge(rel) then
      count <= std_logic_vector(unsigned(count) + x"01");
    end if;
  end process;

  Q <= count;
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 8 bit register, reset=0 asynchronous, load=1 synchronous
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee; use ieee.std_logic_1164.all;
use work.p_WIRES.all;

entity register8 is
  port(rel, rst, ld: in  std_logic;
        D:           in  reg8;
        Q:           out reg8);
end register8;

architecture functional of register8 is
  signal value: reg8;
begin

  process(rel, rst, ld)
  begin
    if rst = '0' then
      value <= x"00";
    elsif ld = '1' and rising_edge(rel) then
      value <= D;
    end if;
  end process;

  Q <= value;
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 8 bit shift-register, reset=0 asynch, load,shift=1 sunch
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee; use ieee.std_logic_1164.all;
use work.p_WIRES.all;

entity deslocador8 is
  port(rel, rst, ld, desl: in  std_logic;
        D:           in  reg8;
        Q:           out reg8);
end deslocador8;

architecture functional of deslocador8 is
  signal value: reg8;
begin

  process(rel, rst)
  begin
    if rst = '0' then
      value <= x"00";
    elsif ld = '1' and rising_edge(rel) then
      value <= D;
    elsif desl = '1' and rising_edge(rel) then
      value(0) <= D(0);
      value(7 downto 1) <= value(6 downto 0);
    end if;
  end process;

  Q <= value;

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 10 bit shift-register, parallel load, serial output
--   reset=0 asynch, load=1 asynch, shift=1 synch, fills with '1's
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee; use ieee.std_logic_1164.all;
use work.p_WIRES.all;

entity par_ser10 is
  port(rel, rst, ld, desl: in  std_logic;
       D:                  in  reg10;
       Q:                  out std_logic);
end par_ser10;

architecture functional of par_ser10 is
begin

  process(rel, rst, ld, desl, D)
    variable value: reg10;
  begin
    if rst = '0' then
      value := b"1111111111";
      Q <= '1';
    elsif falling_edge(ld) then
      value := D;
    elsif desl = '1' and rising_edge(rel) then
      Q <= value(0);
      value(8 downto 0) := value(9 downto 1);
      value(9) := '1';                  -- when idle, send stop-bits
    end if;
  end process;

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 10 bit shift register, serial input, parallel output
--   reset=0 asynch, load,shift=1 synch
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee; use ieee.std_logic_1164.all;
use work.p_WIRES.all;

entity ser_par10 is
  port(rel, rst, desl: in  std_logic;
       D:              in  std_logic;
       Q:              out reg10);
end ser_par10;

architecture functional of ser_par10 is
begin

  process(rel, rst, desl)
    variable value: reg10;
  begin
    if rst = '0' then
      value := b"0000000000";
    elsif desl = '1' and rising_edge(rel) then
      value(8 downto 0) := value(9 downto 1);
      value(9) := D;
    end if;
    Q <= value;
  end process;
  
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


