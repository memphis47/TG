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



-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- syncronous RAM for synthesis; NON-initialized, byte-indexed
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity fpga_RAM is
  generic (LOAD_FILE_NAME : string := "data.bin";
           DUMP_FILE_NAME : string := "dump.data");
  port (rst      : in    std_logic;
        clk,phi0 : in    std_logic;
        sel      : in    std_logic;         -- active in '0'
        rdy      : out   std_logic;         -- active in '0'
        wr       : in    std_logic;
        addr     : in    reg32;
        data_inp : in    reg32;
        data_out : out   reg32;
        byte_sel : in    reg4;
        dump_ram : in    std_logic);        -- dump RAM contents
  constant DATA_ADDRS_BITS : natural := log2_ceil(DATA_MEM_SZ);
  subtype ram_address is integer range 0 to ((DATA_MEM_SZ /4) - 1);
end entity fpga_RAM;

architecture rtl of fpga_RAM is

  component wait_states is
    generic (NUM_WAIT_STATES :integer := 0);
    port(rst     : in  std_logic;
         phi0    : in  std_logic;
         sel     : in  std_logic;
         waiting : out std_logic);
  end component wait_states;

  component ram_dual is
    generic (N_WORDS : integer;
             WIDTH : integer);
    port (data  : in std_logic_vector;
          raddr : in ram_address;
          waddr : in ram_address;
          we    : in std_logic;
          rclk  : in std_logic;
          wclk  : in std_logic;
          q     : out std_logic_vector);
  end component ram_dual;
  
  component single_port_ram is
    generic (N_WORDS : integer);
    port (data : in std_logic_vector;
          addr : in ram_address;
          we   : in std_logic;
          clk  : in std_logic;
          q    : out std_logic_vector);
  end component single_port_ram;

  constant WAIT_COUNT : max_wait_states := NUM_MAX_W_STS - RAM_WAIT_STATES;
  signal wait_counter, ram_current : integer;
  
  signal we0,we1,we2,we3 : std_logic := '0';
  signal di,do : reg32;

  signal r_addr : ram_address := 0;

  signal waiting, strobe : std_logic;

begin  -- behavioral

  U_BUS_WAIT: wait_states generic map (RAM_WAIT_STATES)
    port map (rst, phi0, sel, waiting);

  rdy <= not(waiting);

  strobe <= not(sel) and not(waiting) and not(clk);

  
  -- CPU acesses are word-addressed; RAM is byte-addressed, 4-bytes wide
  r_addr <= to_integer( unsigned(addr( (DATA_ADDRS_BITS-1) downto 2 ) ) );

  U_ram0: ram_dual generic map (DATA_MEM_SZ/4, 8)  -- least significant
    port map (di(7 downto 0),   r_addr,r_addr, we0, strobe,strobe, do(7 downto 0));

  U_ram1: ram_dual generic map (DATA_MEM_SZ/4, 8)
    port map (di(15 downto 8),  r_addr,r_addr, we1, strobe,strobe, do(15 downto 8));

  U_ram2: ram_dual generic map (DATA_MEM_SZ/4, 8)
    port map (di(23 downto 16), r_addr,r_addr, we2, strobe,strobe, do(23 downto 16));

  U_ram3: ram_dual generic map (DATA_MEM_SZ/4, 8)  -- MOST significant
    port map (di(31 downto 24), r_addr,r_addr, we3, strobe,strobe, do(31 downto 24));

--   U_ram0: single_port_ram generic map (DATA_MEM_SZ/4)  -- least significant
--     port map (di(7 downto 0),   r_addr, we0, strobe, do(7 downto 0));
-- 
--   U_ram1: single_port_ram generic map (DATA_MEM_SZ/4)
--     port map (di(15 downto 8),  r_addr, we1, strobe, do(15 downto 8));
-- 
--   U_ram2: single_port_ram generic map (DATA_MEM_SZ/4)
--     port map (di(23 downto 16), r_addr, we2, strobe, do(23 downto 16));
-- 
--   U_ram3: single_port_ram generic map (DATA_MEM_SZ/4)  -- MOST significant
--     port map (di(31 downto 24), r_addr, we3, strobe, do(31 downto 24));


  accessRAM: process(sel, wr, r_addr, byte_sel, data_inp, do)
  begin

    if sel = '0' then

      if wr = '0' then                  -- WRITE to MEM
        
        assert (r_addr >= 0) and (r_addr < (DATA_MEM_SZ/4))
          report "ramWR index out of bounds: " & natural'image(r_addr)
          severity failure;

        case byte_sel is
          when b"1111"  =>      -- SW
            we3 <= '1';
            we2 <= '1';
            we1 <= '1';
            we0 <= '1';
            di  <= data_inp;
          when b"1100" =>       -- SH, upper
            we3 <= '1';
            we2 <= '1';
            we1 <= '0';
            we0 <= '0';
            di(31 downto 16) <= data_inp(15 downto 0);
            di(15 downto 0)  <= (others => 'X');
          when b"0011" =>       -- SH. lower
            we3 <= '0';
            we2 <= '0';
            we1 <= '1';
            we0 <= '1';
            di(15 downto 0)  <= data_inp(15 downto 0);
            di(31 downto 16) <= (others => 'X');
          when b"0001" =>       -- SB
            we3 <= '0';
            we2 <= '0';
            we1 <= '0';
            we0 <= '1';
            di(7 downto 0)  <= data_inp(7 downto 0);
            di(31 downto 8) <= (others => 'X');
          when b"0010" =>
            we3 <= '0';
            we2 <= '0';
            we1 <= '1';
            we0 <= '0';
            di(31 downto 16) <= (others => 'X');
            di(15 downto 8)  <= data_inp(7 downto 0);
            di(7 downto 0)   <= (others => 'X');
          when b"0100" =>
            we3 <= '0';
            we2 <= '1';
            we1 <= '0';
            we0 <= '0';
            di(31 downto 24) <= (others => 'X');
            di(23 downto 16) <= data_inp(7 downto 0);
            di(15 downto 0)  <= (others => 'X');
          when b"1000" =>
            we3 <= '1';
            we2 <= '0';
            we1 <= '0';
            we0 <= '0';
            di(31 downto 24) <= data_inp(7 downto 0);
            di(23 downto 0)  <= (others => 'X');
          when others =>
            we3 <= '0';
            we2 <= '0';
            we1 <= '0';
            we0 <= '0';
            di  <= (others => 'X');

        end case;
        -- assert false report "ramWR["& natural'image(r_addr) &"] "
        --   & SLV32HEX(data_out) &" bySel=" & SLV2STR(byte_sel); -- DEBUG

        data_out <= (others => 'X');
        
      else                              -- READ from MEM, wr /= 0

        we3 <= '0';
        we2 <= '0';
        we1 <= '0';
        we0 <= '0';
        di  <= (others => 'X');

        assert (r_addr >= 0) and (r_addr < (DATA_MEM_SZ/4))
          report "ramRD index out of bounds: " & natural'image(r_addr)
          severity failure;

        case byte_sel is
          when b"1111"  =>                              -- LW
            data_out(31 downto 24) <= do(31 downto 24);
            data_out(23 downto 16) <= do(23 downto 16);
            data_out(15 downto  8) <= do(15 downto  8);
            data_out(7  downto  0) <= do(7  downto  0);

          when b"1100" =>                               -- LH top-half
            data_out(31 downto 24) <= do(31 downto 24);
            data_out(23 downto 16) <= do(23 downto 16);
            data_out(15 downto  0) <= (others => 'X');

          when b"0011" =>                               -- LH bottom-half
            data_out(31 downto 16) <= (others => 'X');
            data_out(15 downto  8) <= do(15 downto  8);
            data_out(7  downto  0) <= do(7  downto  0);

          when b"0001" =>                               -- LB top byte
            data_out(31 downto  8) <= (others => 'X');
            data_out(7  downto  0) <= do(7  downto  0);
          when b"0010" =>                               -- LB mid-top byte
            data_out(31 downto 16) <= (others => 'X');
            data_out(15 downto  8) <= do(15 downto  8);
            data_out(7  downto  0) <= (others => 'X');
          when b"0100" =>                               -- LB mid-bot byte
            data_out(31 downto 24) <= (others => 'X');
            data_out(23 downto 16) <= do(23 downto 16);
            data_out(15 downto  0) <= (others => 'X');
          when b"1000" =>                               -- LB bottom byte
            data_out(31 downto 24) <= do(31 downto 24);
            data_out(23 downto  0) <= (others => 'X');
          when others => 
            data_out <= (others => 'X');
        end case;  
        -- assert false report "ramRD["& natural'image(r_addr) &"] "
        --   & SLV32HEX(do) &" bySel="& SLV2STR(byte_sel);  -- DEBUG

      end if;                           -- wr

    else      -- sel /= 0

      we3 <= '0';
      we2 <= '0';
      we1 <= '0';
      we0 <= '0';
      di       <= (others => 'X');
      data_out <= (others => 'X');

    end if;
        
  end process accessRAM;

end architecture rtl;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Altera's design for a single-port RAM that can be synthesized
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee;
use ieee.std_logic_1164.all;

entity single_port_ram is
  generic (N_WORDS : integer := 64);
  port (data : in std_logic_vector(7 downto 0);
        addr : in natural range 0 to N_WORDS - 1;
        we   : in std_logic;
        clk  : in std_logic;
        q    : out std_logic_vector(7 downto 0) );
end entity;

architecture rtl of single_port_ram is

  -- Build a 2-D array type for the RAM
  subtype word_t is std_logic_vector(7 downto 0);
  type memory_t is array(N_WORDS - 1 downto 0) of word_t;
	
  -- Declare the RAM signal.
  signal ram : memory_t;
  
  -- Register to hold the address
  signal addr_reg : natural range 0 to N_WORDS - 1;

begin

  process(clk)
  begin
    if(rising_edge(clk)) then
      if(we = '1') then
        ram(addr) <= data;
      end if;
			
      -- Register the address for reading
      addr_reg <= addr;
    end if;
    
  end process;
  
  q <= ram(addr_reg);
	
end rtl;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Altera's design for a dual-port RAM that can be synthesized
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee;
use ieee.std_logic_1164.all;

entity ram_dual is
  generic (N_WORDS : integer := 64;
           WIDTH : integer := 8);
  port (data  : in std_logic_vector(WIDTH - 1 downto 0);
    raddr : in natural range 0 to N_WORDS - 1;
    waddr : in natural range 0 to N_WORDS - 1;
    we	  : in std_logic;
    rclk  : in std_logic;
    wclk  : in std_logic;
    q	  : out std_logic_vector(WIDTH - 1 downto 0));
end ram_dual;

architecture rtl of ram_dual is

  -- Build a 2-D array type for the RAM
  subtype word_t is std_logic_vector(WIDTH - 1 downto 0);
  type memory_t is array(N_WORDS - 1 downto 0) of word_t;
  
  -- Declare the RAM signal.
  signal ram : memory_t; --  := (others => (others => '0'));

begin

  process(wclk)
  begin
    if(rising_edge(wclk)) then 
      if(we = '1') then
        ram(waddr) <= data;
      end if;
    end if;
  end process;
	
  process(rclk)
  begin
    if(rising_edge(rclk)) then
      q <= ram(raddr);
    end if;
  end process;
  
end rtl;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
