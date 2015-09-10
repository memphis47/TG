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
-- syncronous ROM; MIPS executable defined as constant, word-indexed
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity fpga_ROM is
  generic (LOAD_FILE_NAME : string := "prog.bin");  -- not used with FPGA
  port (rst   : in    std_logic;
        clk,phi0 : in    std_logic;
        sel   : in    std_logic;         -- active in '0'
        rdy   : out   std_logic;         -- active in '0'
        addr  : in    reg32;
        data  : out   reg32);
  constant INST_ADDRS_BITS : natural := log2_ceil(INST_MEM_SZ);
  subtype rom_address is natural range 0 to ((INST_MEM_SZ / 4) - 1);
end entity fpga_ROM;

architecture rtl of fpga_ROM is

  component wait_states is
    generic (NUM_WAIT_STATES :integer := 0);
    port(rst     : in  std_logic;
         phi0    : in  std_logic;
         sel     : in  std_logic;         -- active in '0'
         waiting : out std_logic);        -- active in '1'
  end component wait_states;

  component single_port_rom is
    generic (N_WORDS : integer);
    port (addr : in rom_address;
          clk  : in std_logic;
          q    : out std_logic_vector);
  end component single_port_rom;

  signal instrn : reg32;
  signal index : rom_address := 0;

  signal waiting, strobe : std_logic;
  
begin  -- rtl

  U_BUS_WAIT: wait_states generic map (ROM_WAIT_STATES)
    port map (rst, phi0, sel, waiting);

  rdy <= not(waiting);

  strobe <= not(sel) and not(waiting) and not(clk);
  
  
  -- >>2 = /4: byte addressed but word indexed
  index <= to_integer(unsigned(addr((INST_ADDRS_BITS-1) downto 2)));

  U_ROM: single_port_rom generic map (INST_MEM_SZ / 4)
    port map (index, strobe, instrn);

  U_ROM_ACCESS: process (sel)
  begin
      if sel = '0' then
        data <= instrn;
        assert (index >= 0) and (index < INST_MEM_SZ/4)
          report "rom index out of bounds: " & natural'image(index)
          severity failure;
        -- assert false -- DEBUG
        --   report "romRD["& natural'image(index) &"]="& SLV32HEX(data); 
      else
        data <= (others => 'X');
      end if;
  end process U_ROM_ACCESS;

end rtl;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Adapted from Altera's design for a ROM that may be synthesized
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.p_wires.all;

entity single_port_rom is
  generic (N_WORDS : integer := 64);
  port (addr : in natural range 0 to (N_WORDS - 1);
        clk  : in std_logic;
        q    : out reg32);
end entity;

architecture rtl of single_port_rom is

  -- Build a 2-D array type for the RoM
  subtype word_t is std_logic_vector(31 downto 0);
  type memory_t is array(0 to (N_WORDS-1)) of word_t;

  -- tests/kbd7segMacnica.s
  -- assemble.sh -v kbd7segMacnica.s |\
  -- sed -e '1,6d' -e '/^$/d' -e '/^ /!d' -e 's:\t: :g' \
  -- -e 's#\(^ *[a-f0-9]*:\) *\(........\)  *\(.*\)$#x"\2", -- \1 \3#'

  constant test_prog : memory_t := (
x"00000000", --    0: nop
x"3c0f0f00", --    4: lui $15,0xf00
x"35ef0140", --    8: ori $15,$15,0x140
x"3c190f00", --    c: lui $25,0xf00
x"37390120", --   10: ori $25,$25,0x120
x"2401ffff", --   14: li $1,-1
x"241f0001", --   18: li $31,1
x"001fffc0", --   1c: sll $31,$31,0x1f
x"8de80000", --   20: lw $8,0($15)
x"00000000", --   24: nop
x"01014824", --   28: and $9,$8,$1
x"1120fffc", --   2c: beqz $9,20 <wait1>
x"00000000", --   30: nop
x"8de80000", --   34: lw $8,0($15)
x"00000000", --   38: nop
x"011f4824", --   3c: and $9,$8,$31
x"1120fffc", --   40: beqz $9,34 <deb1>
x"00000000", --   44: nop
x"af280000", --   48: sw $8,0($25)
x"08000008", --   4c: j 20 <wait1>
x"00000000", --   50: nop
x"00000000", --   54: nop
x"00000000", --   58: nop
x"42000020"  --   5c: wait
);
   

  function init_rom
    return memory_t is
    variable tmp : memory_t := (others => (others => '0'));
    variable i_addr : integer;
  begin
    for addr_pos in test_prog'range loop
      tmp(addr_pos) := test_prog(addr_pos);
      i_addr := addr_pos;
    end loop;

    for addr_pos in test_prog'high to (N_WORDS - 1) loop
      tmp(addr_pos) := x"00000000";      -- nop
    end loop;
    return tmp;
  end init_rom;

  -- Declare the ROM signal and specify a default value. Quartus II
  -- will create a memory initialization file (.mif) based on the 
  -- default value.
  signal rom : memory_t := init_rom;

begin
  
  process(clk)
  begin
    if(rising_edge(clk)) then
      q <= rom(addr);
    end if;
  end process;
  
end rtl;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
