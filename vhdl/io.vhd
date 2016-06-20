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



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: print_data
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity print_data is
  port (rst     : in  std_logic;
        clk     : in  std_logic;
        sel     : in  std_logic;
        rdy     : out std_logic;
        wr      : in  std_logic;
        addr    : in  reg32;
        data    : in  reg32);
end print_data;

architecture behavioral of print_data is

  file output : text open write_mode is "STD_OUTPUT";

begin

  rdy <= '1';

  U_WRITE_OUT: process(sel,clk)
    variable msg : line;
  begin
    if falling_edge(clk) and sel = '0' then
      --assert false report "Print["&SLV32HEX(data)&"]";
      write ( msg, string'(SLV32HEX(data)) );
      writeline( output, msg );
    end if;
  end process U_WRITE_OUT;

end behavioral;
-- ++ print_data +++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: to_stdout
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity to_stdout is
  port (rst     : in  std_logic;
        clk     : in  std_logic;
        sel     : in  std_logic;
        rdy     : out std_logic;
        wr      : in  std_logic;
        addr    : in  std_logic_vector;
        data    : in  std_logic_vector);
end to_stdout;

architecture behavioral of to_stdout is
  
  file output : text open write_mode is "STD_OUTPUT";

begin

  rdy <= '1';

  U_WRITE_OUT: process(clk,sel)
    variable msg : line;
  begin
    if falling_edge(clk) and sel = '0' then
      if (data(7 downto 0) = x"00") or (data(7 downto 0) = x"0a") then
        writeline( output, msg );
      else
      
        write(msg, character'val(to_integer( unsigned(data(7 downto 0)))));
      end if;
    end if;
  end process U_WRITE_OUT;
  
end behavioral;
-- ++ to_stdout +++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: write_data_to_file
--   if( addr(3 downto 0) ) = "0000" then write to file
--   if( addr(3 downto 0) ) = "0100" then close file
--   if( addr(3 downto 0) ) = "0111" then assert dump_ram
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity write_data_file is
  generic (OUTPUT_FILE_NAME : string := "output.data");
  port (rst      : in  std_logic;
        clk      : in  std_logic;
        sel      : in  std_logic;
        rdy      : out std_logic;
        wr       : in  std_logic;
        addr     : in  reg32;
        data     : in  reg32;
        byte_sel : in  reg4;
        dump_ram : out std_logic);
end write_data_file;

architecture behavioral of write_data_file is

  type uint_file_type is file of integer;
  file output_file: uint_file_type open write_mode is OUTPUT_FILE_NAME;

begin

  rdy <= '1';

  U_write_uint: process (clk,sel)
  begin

    dump_ram <= '0';

    if  falling_edge(clk) and sel = '0' then
      if addr(3 downto 0) = b"0000" then               -- data write
        if wr = '0' then
          write( output_file, to_integer(signed(data)) );
          -- assert FALSE
          --   report "IOwr[" & SLV32HEX(addr) &"]:"& SLV32HEX(data);
        end if;
      elsif addr(3 downto 0) = b"0100" then            -- close output file
        file_close(output_file);
      elsif addr(3 downto 0) = b"0111" then            -- dump RAM
        dump_ram <= '1';
      end if;
    end if;
    
  end process U_write_uint;

end behavioral;                         -- write_file_data
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: read_data_from_file
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity read_data_file is
  generic (INPUT_FILE_NAME : string := "input.data");
  port (rst      : in  std_logic;
        clk      : in  std_logic;
        sel      : in  std_logic;
        rdy      : out std_logic;
        wr       : in  std_logic;
        addr     : in  reg32;
        data     : out reg32;
        byte_sel : in  reg4);
end read_data_file;

architecture behavioral of read_data_file is

  type uint_file_type is file of integer;
  file input_file: uint_file_type open read_mode is INPUT_FILE_NAME;

  signal status : reg32 := (others => '0');

begin

  rdy <= '1';


  U_read_uint: process(clk,sel)
    variable datum : integer := 0;
    variable value : reg32;                 -- for debugging only
  begin

    data <= (others => 'X');

    if falling_edge(clk) and sel = '0' then
      if addr(3 downto 0) = b"0000" then               -- data read
        if wr = '1' then
          if not endfile(input_file) then
            read( input_file, datum );
            data <= std_logic_vector(to_signed(datum, 32));
            status <= x"00000000";        -- NOT_EndOfFile
            -- value := std_logic_vector(to_signed(datum, 32));   -- DEBUG
            -- assert FALSE
            --   report "IOrd[" & SLV32HEX(addr) &"]:"& SLV32HEX(value);
          else
            status <= x"00000001";        -- EndOfFile
          end if;
        else
          data <= (others => 'X');
        end if;
      else                                -- status read
        if wr = '1' then
          data <= status;
        else
          data <= (others => 'X');
        end if;
      end if;
    end if;
    
  end process U_read_uint;

end behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: generate interrupt after N clock cycles
--   Generates an interrupt after N cycles, N <= 2**30
--   Counting stops on reaching limit stored to counter.
--   data(31) = 1 enables interrupt on reaching limit;
--   data(31) = 0 disables interrupts
--   data(30) = 1 enables counting
--   data(30) = 0 stops counter and delays interrupt (forever?)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_wires.all;

entity do_interrupt is
  port (rst      : in    std_logic;
        clk      : in    std_logic;     -- clock pulses counted
        sel      : in    std_logic;
        rdy      : out   std_logic;
        wr       : in    std_logic;
        addr     : in    std_logic_vector;
        data_inp : in    std_logic_vector;
        data_out : out   std_logic_vector;
        irq      : out   std_logic);
  constant NUM_BITS : integer := 30;
  subtype c_width is std_logic_vector(NUM_BITS - 1 downto 0);
  constant START_COUNT : c_width := (others => '0');
end do_interrupt;

architecture behavioral of do_interrupt is

  component registerN is
    generic (NUM_BITS: integer);
    port(clk, rst, ld: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic_vector);
  end component registerN;

  component countNup is
    generic (NUM_BITS: integer);
    port(clk, rst, ld, en: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic_vector;
         co:           out std_logic);
  end component countNup;

  component simple_latch is
    port (enable, clr, data : in std_logic;
          q : out std_logic);
  end component simple_latch;
  
  signal Dlimit, Qlimit, Q: c_width;
  signal ld_cnt, ld_reg, clr, en, cnt_en, int_en, equals, int : std_logic;

begin

  ld_reg <= wr when sel = '0' else '1';

  Dlimit <= data_inp(NUM_BITS-1 downto 0);

  U_LIMIT: registerN  generic map (NUM_BITS)
    port map (clk, rst, ld_reg, Dlimit, Qlimit);
  
  U_COUNTER: countNup generic map (NUM_BITS)
    port map (clk, rst, ld_cnt, en, START_COUNT, Q, open);

  
  ld_cnt <= not ld_reg;
  clr    <= not rst;
  en     <= cnt_en and (not equals);
  
  U_LATCH_INTERR: simple_latch port map (ld_cnt, clr, data_inp(31), int_en);
  U_LATCH_COUNT:  simple_latch port map (ld_cnt, clr, data_inp(30), cnt_en);

  equals <= '1' when (Q = Qlimit(NUM_BITS-1 downto 0)) else '0';
  
  irq <= '1' when (equals = '1' and int_en = '1') else '0';

  data_out <= int_en & cnt_en & Q;

  rdy <= '1';

end behavioral;
-- ++ do_interrupt +++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: simple UART
--   8 data bits, no parity, not much error detection
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_wires.all;

entity simple_uart is
  port (rst     : in    std_logic;
        clk     : in    std_logic;      -- processor clock
        sel     : in    std_logic;
        rdy     : out   std_logic;
        wr      : in    std_logic;
        addr    : in    std_logic;
        data_inp : in   std_logic_vector;
        data_out : out  std_logic_vector;
        txdat   : out   std_logic;      -- serial transmission (output)
        rxdat   : in    std_logic;      -- serial reception (input)
        irq     : out   std_logic;      -- interrupt request
        bit_rt  : out   std_logic_vector); -- communication speed; for TB only
end simple_uart;

architecture behavioral of simple_uart is

  component uart_int is
    port(clk, rst: in std_logic;
         s_ctrl, s_stat, s_tx, s_rx: in std_logic;  -- select 4 registers
         ent:    in  std_logic_vector;  -- 32 bit input
         sai:    out std_logic_vector;  -- 32 bit output
         txdat:  out std_logic;         -- serial transmission (output)
         rxdat:  in  std_logic;         -- serial reception (input)
         interr: out std_logic;         -- interrupt request
         bit_rt: out std_logic_vector); -- communication speed - for TB only
  end component uart_int;
  
  signal s_ctrl, s_stat, s_tx, s_rx: std_logic;
  signal d_inp, d_out : reg32;

begin

  rdy <= '1';

  U_UART: uart_int port map (clk, rst, s_ctrl,s_stat, s_tx,s_rx,
                             d_inp,d_out, txdat,rxdat, irq, bit_rt);
  
  -- a2  wr  register (aligned to word addresses)
  --  0  0  control
  --  0  1  status
  --  1  0  transmission
  --  1  1  reception
  s_ctrl <= '1' when sel = '0' and addr = '0' and wr = '0' else '0';
  s_stat <= '1' when sel = '0' and addr = '0' and wr = '1' else '0';
  s_tx   <= '1' when sel = '0' and addr = '1' and wr = '0' else '0';
  s_rx   <= '1' when sel = '0' and addr = '1' and wr = '1' else '0';
  
  data_out <= d_out when wr='1' and  (s_rx = '1' or s_stat = '1');

  d_inp <= data_inp when wr='0' and  (s_tx = '1' or s_ctrl = '1');
  
end behavioral;
-- ++ simple uart +++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: system statistics: gather statistics in one peripheral
-- processor reads performance counters, on word boundaries, adressed as
-- cnt_dc_ref    when "00000", 0
-- cnt_dc_rd_hit when "00100", 4
-- cnt_dc_wr_hit when "01000", 8
-- cnt_dc_flush  when "01100", 12
-- cnt_ic_ref    when "10000", 16
-- cnt_ic_hit    when "10100", 20
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;

entity sys_stats is
  port (rst     : in    std_logic;
        clk     : in    std_logic;
        sel     : in    std_logic;
        rdy     : out   std_logic;
        wr      : in    std_logic;
        addr    : in    reg32;
        data    : out   reg32;
        cnt_dc_ref    : in  integer;
        cnt_dc_rd_hit : in  integer;
        cnt_dc_wr_hit : in  integer;
        cnt_dc_flush  : in  integer;
        cnt_ic_ref : in  integer;
        cnt_ic_hit : in  integer);
end sys_stats;

architecture behavioral of sys_stats is
begin

  U_SYNC_OUTPUT: process(clk,sel)
    variable i_c : integer := 0;
  begin
    data <= (others => '0');

    if falling_edge(clk) and sel = '0' then
      case addr(4 downto 2) is
        when "000" => i_c := cnt_dc_ref;
        when "001" => i_c := cnt_dc_rd_hit;
        when "010" => i_c := cnt_dc_wr_hit;
        when "011" => i_c := cnt_dc_flush;
        when "100" => i_c := cnt_ic_ref;
        when "101" => i_c := cnt_ic_hit;
        when others => i_c := 0;
      end case;
    end if;
    
    data <= std_logic_vector(to_signed(i_c,32));

  end process U_SYNC_OUTPUT;

  
  rdy <= '1';

end behavioral;
-- ++ system statistics ++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: to_7seg
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity to_7seg is
  port (rst      : in  std_logic;
        clk      : in  std_logic;
        sel      : in  std_logic;
        rdy      : out std_logic;
        wr       : in  std_logic;
        data     : in  std_logic_vector;
        display0 : out reg8;
        display1 : out reg8);
  constant NUM_BITS : integer := 10;    -- 2 decimal points, 2 hex digits
end to_7seg;

architecture behavioral of to_7seg is

  component registerN is
    generic (NUM_BITS: integer);
    port(clk, rst, ld: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic_vector);
  end component registerN;

  component display_7seg is
    port(data_i      : in  std_logic_vector(3 downto 0);
         decimal_i   : in  std_logic;
         disp_7seg_o : out std_logic_vector(7 downto 0));
  end component display_7seg;
  
  signal value : std_logic_vector(NUM_BITS-1 downto 0);
  signal strobe : std_logic;
  
begin
  
  strobe <= not(sel) and not(clk);
  
  U_HOLD_data: registerN generic map (NUM_BITS)
    port map (strobe, rst, sel, data(NUM_BITS-1 downto 0), value);

  U_DSP1: display_7seg port map (value(7 downto 4), value(9), display1);

  U_DSP0: display_7seg port map (value(3 downto 0), value(8), display0);

  
  rdy <= '1';

end behavioral;
-- ++ to_7seg +++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: read_keys
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_wires.all;

entity read_keys is
  port (rst      : in  std_logic;
        clk      : in  std_logic;
        sel      : in  std_logic;
        rdy      : out std_logic;
        data     : out reg32;
        kbd      : in  std_logic_vector (11 downto 0);
        sw       : in  std_logic_vector (3 downto 0));
end read_keys;

architecture behavioral of read_keys is
  
  component FFD is
    port(clk, rst, set : in std_logic;
         D : in  std_logic; Q : out std_logic);
  end component FFD;

  component sr_latch_rst is
    port(rst,set,clr : in  std_logic; q : out std_logic);
  end component sr_latch_rst;

  component registerN is
    generic (NUM_BITS: integer);
    port(clk, rst, ld: in  std_logic;
         D:            in  std_logic_vector(NUM_BITS-1 downto 0);
         Q:            out std_logic_vector(NUM_BITS-1 downto 0));
  end component registerN;
  
  component teclado_base is
  generic (DEBOUNCE : integer);
  port(clk_i         : in  std_logic;
       push_button_i : in  std_logic_vector;
       key_o         : out std_logic_vector;
       ready_o       : out std_logic);
  end component teclado_base;
 
  signal debounced, set, clr, pre_clr, n_sel, data_is_new, ready : std_logic;
  signal keys_data, old_data : reg4;

begin

  data(30 downto 8) <= (others => '0');

  U_KEYBOARD: teclado_base generic map (10)
    port map(clk, kbd, keys_data, debounced);

  U_HOLD_DATA: registerN  generic map (4)
    port map (clk, rst, data_is_new, keys_data, old_data);
  
  U_HOLD_READY: sr_latch_rst port map (rst, set, clr, ready);
  U_DELAY_READY: FFD port map (clk, rst, '1', ready, data(31));

  n_sel <= not(sel);
  U_DELAY_CLR: FFD port map (clk, rst, '1', n_sel, pre_clr);
  clr <= pre_clr and not(set);          -- do not assert clr AND set
  
  data_is_new <= BOOL2SL(keys_data = old_data);
  set <= debounced and not(data_is_new);

  data(7) <= sw(3);
  data(6) <= sw(2);
  data(5) <= sw(1);
  data(4) <= sw(0);
  data(3 downto 0) <= old_data;

  
  rdy <= '1';

end behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

