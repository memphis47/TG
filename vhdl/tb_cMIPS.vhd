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
-- data address decoding 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity data_addr_decode is              -- CPU side triggers access
  port (rst         : in  std_logic;
        clk         : in  std_logic;    -- no use, except synch-ing asserts
        cpu_d_aVal  : in  std_logic;    -- CPU data addr valid (active=0)
        addr        : in  std_logic_vector;  -- CPU address
        aVal        : out std_logic;    -- data address (act=0)
        dev_select  : out std_logic_vector;  -- select input to CPU
        print_sel   : out std_logic;    -- std_out (integer)   (act=0)
        stdout_sel  : out std_logic;    -- std_out (character) (act=0)
        stdin_sel   : out std_logic;    -- std_inp (character)  (act=0)
        read_sel    : out std_logic;    -- file read  (act=0)
        write_sel   : out std_logic;    -- file write (act=0)
        counter_sel : out std_logic;    -- interrupt counter (act=0)
        FPU_sel     : out std_logic;    -- floating point unit (act=0)
        UART_sel    : out std_logic;    -- floating point unit (act=0)
        SSTATS_sel  : out std_logic;    -- system statistics (act=0)
        dsp7seg_sel : out std_logic;    -- 7 segments display (act=0)
        keybd_sel   : out std_logic;    -- telephone keyboard (act=0)
        -- BCD_W
        bcdW_sel    : out std_logic;    -- bcd_write (integer) (act=0)
        bcdR_sel    : out std_logic;    -- bcd_read  (integer) (act=0)
        -- DMA_USB
        dmaUSB_sel  : out std_logic;    -- dma_usb (act = 0)
        -- DMA_VGA
        dmaVGA_sel : out std_logic;
        not_waiting : in  std_logic);   -- no other device is waiting
  constant RAM_TOP : integer := DATA_BASE_ADDR + DATA_MEM_SZ;
end entity data_addr_decode;

architecture behavioral of data_addr_decode is
begin

  U_decode: process(rst,clk,cpu_d_aVal,addr,not_waiting)
    constant is_noise   : integer := 0;
    constant is_data    : integer := 1;
    constant is_print   : integer := 2;
    constant is_stdout  : integer := 3;
    constant is_stdin   : integer := 4;
    constant is_read    : integer := 5;
    constant is_write   : integer := 6;
    constant is_count   : integer := 7;
    constant is_FPU     : integer := 8;
    constant is_UART    : integer := 9;
    constant is_SSTATS  : integer := 10;
    constant is_dsp7seg : integer := 11;
    constant is_keybd   : integer := 12;
    -- BCD
    constant is_bcdW    : integer := 13;
    constant is_bcdR    : integer := 14;
    -- DMA_USB
    constant is_dmaUSB  : integer := 15;
    -- DMA_VGA
    constant is_dmaVGA : integer := 16;
    variable i_d_addr, refType : integer;
  begin

    aVal        <= '1';
    print_sel   <= '1';
    stdout_sel  <= '1';
    stdin_sel   <= '1';
    read_sel    <= '1';
    write_sel   <= '1';
    counter_sel <= '1';
    FPU_sel     <= '1';
    UART_sel    <= '1';
    SSTATS_sel  <= '1';
    dsp7seg_sel <= '1';
    keybd_sel   <= '1';
    -- BCD
    bcdW_sel    <= '1';
    bcdR_sel    <= '1';
    -- DMA_USB
    dmaUSB_sel  <= '1';
    -- DMA_VGA
    dmaVGA_sel <= '1';
    refType := is_noise;

    if (cpu_d_aVal = '0' and rst = '1') then

      -- assert false
      -- report "d_addr "& SLV32HEX(addr) &"m "&SLV32HEX(x_IO_ADDR_MASK);--DEBUG

      -- mask off I/O devices displacement; RAM accesses are always on
      --    a range wider than IO_ADDR_MASK
      i_d_addr := to_integer(signed(addr and x_IO_ADDR_MASK));

      if ( (i_d_addr >= DATA_BASE_ADDR) and (i_d_addr < RAM_TOP) ) then
        refType := is_data;
        -- assert false report "data["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;
      if (i_d_addr = IO_PRINT_ADDR and not_waiting = '1') then
        refType := is_print;
        -- assert false report "IOpr["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;
      if (i_d_addr = IO_STDOUT_ADDR and not_waiting = '1') then
        refType := is_stdout;
        -- assert false report "IOpr["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;
      if (i_d_addr = IO_STDIN_ADDR and not_waiting = '1') then
        refType := is_stdin;
        -- assert false report "IOpr["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;
      if (i_d_addr = IO_READ_ADDR and not_waiting = '1') then
        refType := is_read;
        -- assert false report "IOrd["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;
      if (i_d_addr = IO_WRITE_ADDR and not_waiting = '1') then
        refType := is_write;
        -- assert false report "IOwr["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;
      if (i_d_addr = IO_COUNT_ADDR and not_waiting = '1') then
        refType := is_count;
        -- assert false report "IOwr["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;
      if (i_d_addr = IO_FPU_ADDR and not_waiting = '1') then
        refType := is_FPU;
        -- assert false report "IOwr["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;
      if (i_d_addr = IO_UART_ADDR and not_waiting = '1') then
        refType := is_UART;
        -- assert false report "IOwr["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;
      if (i_d_addr = IO_STATS_ADDR and not_waiting = '1') then
        refType := is_SSTATS;
        -- assert false report "IOwr["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;

      if (i_d_addr = IO_DSP7SEG_ADDR and not_waiting = '1') then
        refType := is_dsp7seg;
        -- assert false report "IOwr["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;
      if (i_d_addr = IO_KEYBD_ADDR and not_waiting = '1') then
        refType := is_keybd;
        -- assert false report "IOwr["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;

      -- BCD_W
      if (i_d_addr = IO_BCDW_ADDR and not_waiting = '1') then
        refType := is_bcdW;
--        assert false report "IOBCDW["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;

      -- BCD_R
      if ((i_d_addr = IO_BCDR_ADDR or i_d_addr = IO_BCDR_ADDR+1) and not_waiting = '1') then
        refType := is_bcdR;
--        assert false report "IOBCDR["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;

      -- DMA_USB
      if ( (i_d_addr = IO_DMA_USB_ADDR or i_d_addr = IO_DMA_USB_ADDR+1) and not_waiting = '1')then
        refType := is_dmaUSB;
--        assert false report "IOUSB["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;

      -- DMA_VGA
      if ( (i_d_addr = IO_DMA_VGA_ADDR or i_d_addr = IO_DMA_VGA_ADDR+2) and not_waiting = '1')then
        refType := is_dmaVGA;
--        assert false report "IOVGA["&SLV32HEX(addr)&"]";  -- DEBUG
      end if;

      if falling_edge(clk) and not_waiting = '1' then
        assert (refType /= is_noise)
          report "TB addr decode: invalid data address "& SLV32HEX(addr)
          &" refType = "& integer'image(refType)
          severity warning; -- failure; 
      end if;

    else

      refType := is_noise;
      
    end if;

    dev_select <= std_logic_vector(to_signed(refType, 5));

    case refType is
      when is_data   => aVal         <= '0';
      when is_print  => print_sel    <= '0';
      when is_stdout => stdout_sel   <= '0';
      when is_stdin  => stdin_sel    <= '0';
      when is_read   => read_sel     <= '0';
      when is_write  => write_sel    <= '0';
      when is_count  => counter_sel  <= '0';
      when is_FPU    => FPU_sel      <= '0';
      when is_UART   => UART_sel     <= '0';
      when is_SSTATS => SSTATS_sel   <= '0';
      when is_dsp7seg => dsp7seg_sel <= '0';
      when is_keybd  =>  keybd_sel   <= '0';
      -- BCD
      when is_bcdW   => bcdW_sel     <= '0';
      when is_bcdR   => bcdR_sel     <= '0';
      -- DMA_USB
      when is_dmaUSB => dmaUSB_sel   <= '0';
      -- DMA_VGA
      when is_dmaVGA => dmaVGA_sel   <= '0';
      when others =>
        if( not_waiting = '1' and cpu_d_aVal /= '0' ) then
          aVal <= '1'; 

          -- BCD
          bcdW_sel <= '1'; 
          bcdR_sel <= '1'; 

          -- DMA_USB
          dmaUSB_sel   <= '1';

          -- DMA_VGA
          dmaVGA_sel   <= '1';

      	  print_sel <= '1'; stdout_sel <= '1'; stdin_sel <= '1';
          read_sel <= '1'; write_sel <= '1';
          counter_sel <= '1';  FPU_sel <= '1'; UART_sel <= '1';
          SSTATS_sel <= '1'; dsp7seg_sel <= '1'; keybd_sel <= '1';
        end if;
    end case;

  end process U_decode;
      
end architecture behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- instruction address decoding 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity inst_addr_decode is              -- CPU side triggers access
  port (rst         : in  std_logic;
        cpu_i_aVal  : in  std_logic;    -- CPU instr addr valid (act=0)
        addr        : in  reg32;        -- CPU address
        aVal        : out std_logic;    -- decoded address in range (act=0)
        not_waiting : in  std_logic);   -- no other device is waiting
  constant ROM_TOP    : integer := INST_BASE_ADDR + INST_MEM_SZ;
end entity inst_addr_decode;

architecture behavioral of inst_addr_decode is
begin

  U_decode: process(rst,cpu_i_aVal,addr,not_waiting)
    constant is_noise : integer := 0;
    constant is_instr : integer := 1;
    variable i_addr, refType : integer;
  begin

    aVal    <= '1';
    refType := is_noise;

    if (cpu_i_aVal = '0' and rst = '1') then

      i_addr := to_integer(signed(addr));
      if ( (i_addr >= INST_BASE_ADDR) and (i_addr < ROM_TOP) ) then
        refType := is_instr;
        -- assert false report "instr["&SLV32HEX(i_addr);  -- DEBUG

        assert (refType /= is_noise)
          report "invalid instr address "& SLV32HEX(addr)
          &" "& integer'image(i_addr)
          severity failure; 

      end if;
    end if;

    case refType is
      when is_instr => aVal <= '0';
      when others   =>
        if( not_waiting = '1' and cpu_i_aVal = '1' ) then
          aVal <= '1';
        end if;
    end case;

  end process U_decode;
      
end architecture behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- testbench for classicalMIPS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity tb_cMIPS is
end tb_cMIPS;

architecture TB of tb_cMIPS is

  component FFD is
    port(clk, rst, set, D : in std_logic; Q : out std_logic);
  end component FFD;

  component to_7seg is
    port (rst      : in  std_logic;
          clk      : in  std_logic;
          sel      : in  std_logic;
          rdy      : out std_logic;
          wr       : in  std_logic;
          data     : in  std_logic_vector;
          display0 : out std_logic_vector;
          display1 : out std_logic_vector);
  end component to_7seg;

  component read_keys is
    port (rst      : in  std_logic;
          clk      : in  std_logic;
          sel      : in  std_logic;
          rdy      : out std_logic;
          data     : out reg32;
          kbd      : in  std_logic_vector (11 downto 0);
          sw       : in  std_logic_vector (3 downto 0));
  end component read_keys;

  -- BCD
  component circularBuffer is
	  port (
		  clk	      : in std_logic;
      clk4x     : in std_logic;
		  rst       : in std_logic;
		  -- XeamZoom
		  w_sel 	  : in  std_logic;	-- Sinal de seleção
		  w_data_in : in  reg32;		  -- Dados para gravação
		  w_we 	    : in  std_logic;		-- Sinal de gravação (=1) ou leitura de estado (=0)
		  w_out_st  : out reg32;			  -- Dados de estado (capacidade restante)
		  w_rdy 	  : out std_logic;		-- iwait
		  -- XeamContraste
		  r_sel 	  : in std_logic;	-- Sinal de seleção
      r_addr    : in  reg32;         -- Endereço para leitura de dados ou estado
		  r_out	    : out reg32;			  -- Dados de estado (palavras)
		  r_rdy 	  : out std_logic		  -- iwait
	  );
  end component circularBuffer;

  -- DMA_USB
  component dma_usb_module is
    port (
      rst       : in  std_logic;
      clk       : in  std_logic;
      phi1      : in  std_logic;
      -- cMIPS
      dma_sel 	   : in  std_logic;	  -- Sinal de seleção
      dma_data_in  : in  reg32;		    -- Dados para gravação / endereço inicial
      dma_data_out : out reg32;		    -- Dados de leitura / imagem completamente gravada
      dma_addr     : in  reg32;
      dma_we 	     : in  std_logic;		-- Sinal de gravação (=1) ou leitura (=0)
      dma_rdy 	   : out std_logic; 		-- iwait
      -- RAM
      sel_ram    : out std_logic;
      rdy_ram    : in  std_logic;
      wr_ram     : out std_logic;
      addr_ram   : out reg32;
      datram_in  : out reg32;       -- envia para ram
      datram_out : in  reg32;       -- recebe da  ram
      xfer_ram  : out reg4;
      -- DCACHE
      sel_dcache     : in  std_logic;
      rdy_dcache     : out std_logic;
      wr_dcache      : in  std_logic;
      addr_dcache    : in  reg32;
      datdcache_in  : out reg32;   -- envia para dcache
      datdcache_out : in  reg32;   -- recebe de  dcache
      b_sel_dcache   : in  reg4
    );
  end component dma_usb_module;

  -- dma_VGA
  component dma_vga_module is
    port (
      rst       : in  std_logic;
      clk       : in  std_logic;
      phi0      : in  std_logic;
      phi1      : in  std_logic;
      phi2      : in  std_logic;
      -- cMIPS
      dma_sel 	   : in  std_logic;	  -- Sinal de seleção
      dma_data_in  : in  reg32;		    -- Dados para gravação / endereço inicial
      dma_data_out : out reg32;		    -- Dados de leitura / imagem completamente gravada
      dma_addr     : in  reg32;
      dma_we 	     : in  std_logic;		-- Sinal de gravação (=1) ou leitura (=0)
      dma_rdy 	   : out std_logic; 		-- iwait
      -- RAM
      sel_ram    : out std_logic;
      rdy_ram    : in  std_logic;
      wr_ram     : out std_logic;
      addr_ram   : out reg32;
      datram_in  : out reg32;       -- envia para ram
      datram_out : in  reg32;       -- recebe da  ram
      xfer_ram  : out reg4;
      -- DCACHE
      sel_dcache     : in  std_logic;
      rdy_dcache     : out std_logic;
      wr_dcache      : in  std_logic;
      addr_dcache    : in  reg32;
      datdcache_in  : out reg32;   -- envia para dcache
      datdcache_out : in  reg32;   -- recebe de  dcache
      b_sel_dcache   : in  reg4
    );
  end component dma_vga_module;


  component print_data is
    port (rst     : in  std_logic;
          clk     : in  std_logic;
          sel     : in  std_logic;
          rdy     : out std_logic;
          wr      : in  std_logic;
          addr    : in  std_logic_vector;
          data    : in  std_logic_vector);
  end component print_data;

  component to_stdout is
    port (rst     : in  std_logic;
          clk     : in  std_logic;
          sel     : in  std_logic;
          rdy     : out std_logic;
          wr      : in  std_logic;
          addr    : in  std_logic_vector;
          data    : in  std_logic_vector);
  end component to_stdout;

  component write_data_file is
    generic (OUTPUT_FILE_NAME : string);
    port (rst      : in  std_logic;
          clk      : in  std_logic;
          sel      : in  std_logic;
          rdy      : out std_logic;
          wr       : in  std_logic;
          addr     : in  std_logic_vector;
          data     : in  std_logic_vector;
          byte_sel : in  std_logic_vector;
          dump_ram : out std_logic);
  end component write_data_file;

  component read_data_file is
    generic (INPUT_FILE_NAME : string);
    port (rst     : in  std_logic;
          clk     : in  std_logic;
          sel     : in  std_logic;
          rdy     : out std_logic;
          wr      : in  std_logic;
          addr    : in  std_logic_vector;
          data    : out std_logic_vector;
          byte_sel: in  std_logic_vector);
  end component read_data_file;

  component do_interrupt is
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          wr      : in    std_logic;
          addr    : in    std_logic_vector;
          data_inp : in   std_logic_vector;
          data_out : out  std_logic_vector;
          irq      : out  std_logic);
  end component do_interrupt;

  component simple_uart is
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          wr      : in    std_logic;
          addr    : in    std_logic;
          data_inp : in   std_logic_vector;
          data_out : out  std_logic_vector;
          txdat   : out   std_logic;      -- serial transmission (output)
          rxdat   : in    std_logic;      -- serial reception (input)
          irq     : out   std_logic;
          bit_rt  : out   std_logic_vector);-- communication speed - TB only
  end component simple_uart;

  component remota is
    generic(OUTPUT_FILE_NAME : string; INPUT_FILE_NAME : string);
    port(rst, clk  : in  std_logic;
         start     : in  std_logic;
         inpDat    : in  std_logic;    -- serial input
         outDat    : out std_logic;    -- serial output
         bit_rt    : in  std_logic_vector);
  end component remota;

  component sys_stats is
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          wr      : in    std_logic;
          addr    : in    std_logic_vector;
          data    : out   std_logic_vector;
          cnt_dc_ref    : in  integer;
          cnt_dc_rd_hit : in  integer;
          cnt_dc_wr_hit : in  integer;
          cnt_dc_flush  : in  integer;
          cnt_ic_ref : in  integer;
          cnt_ic_hit : in  integer);
  end component sys_stats;

  
  component data_addr_decode is
    port (rst         : in  std_logic;
          clk         : in  std_logic;    -- no use, except in synch-ing asserts
          cpu_d_aVal  : in  std_logic;
          addr        : in  std_logic_vector;
          aVal        : out std_logic;
          dev_select  : out std_logic_vector;
          print_sel   : out std_logic;
          stdout_sel  : out std_logic;
          stdin_sel   : out std_logic;
          read_sel    : out std_logic;
          write_sel   : out std_logic;
          counter_sel : out std_logic;
          FPU_sel     : out std_logic;
          uart_sel    : out std_logic;
          sstats_sel  : out std_logic;
          dsp7seg_sel : out std_logic;
          keybd_sel   : out std_logic;
          -- BCD
          bcdW_Sel    : out std_logic;
          bcdR_Sel    : out std_logic;
          -- DMA_USB
          dmaUSB_sel : out std_logic;
          -- DMA_VGA
          dmaVGA_sel : out std_logic;
          not_waiting : in  std_logic);
  end component data_addr_decode;

  component inst_addr_decode is
    port (rst         : in  std_logic;
          cpu_i_aVal  : in  std_logic;
          addr        : in  std_logic_vector;
          aVal        : out std_logic;
          not_waiting : in  std_logic);
  end component inst_addr_decode;
    
  component simul_ROM is 
    generic (LOAD_FILE_NAME : string);
    port (rst     : in    std_logic;
          clk	  : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
	  strobe    : in    std_logic;
          addr    : in    std_logic_vector;
          data    : out   std_logic_vector);
  end component simul_ROM;

  component fpga_ROM is 
    generic (LOAD_FILE_NAME : string);
    port (rst     : in    std_logic;
          clk,phi0 : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          addr    : in    std_logic_vector;
          data    : out   std_logic_vector);
  end component fpga_ROM;

  component simul_RAM is
    generic (LOAD_FILE_NAME : string; DUMP_FILE_NAME : string);
    port (rst      : in    std_logic;
          clk      : in    std_logic;
          sel      : in    std_logic;
          rdy      : out   std_logic;
          wr       : in    std_logic;
	  strobe   : in    std_logic;
          addr     : in    std_logic_vector;
          data_inp : in    std_logic_vector;
          data_out : out   std_logic_vector;
          byte_sel : in    std_logic_vector;
          dump_ram : in    std_logic);
  end component simul_RAM;

  component fpga_RAM is
    generic (LOAD_FILE_NAME : string; DUMP_FILE_NAME : string);
    port (rst      : in    std_logic;
          clk,phi0 : in    std_logic;
          sel      : in    std_logic;
          rdy      : out   std_logic;
          wr       : in    std_logic;
          addr     : in    std_logic_vector;
          data_inp : in    std_logic_vector;
          data_out : out   std_logic_vector;
          byte_sel : in    std_logic_vector;
          dump_ram : in    std_logic);
  end component fpga_RAM;

  component fake_I_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          ic_reset : out   std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data : out   std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_addr : out   std_logic_vector;
          mem_data : in    std_logic_vector;
          ref_cnt  : out   integer;
          hit_cnt  : out   integer);
  end component fake_I_CACHE;

  component I_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          ic_reset : out   std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data : out   std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_addr : out   std_logic_vector;
          mem_data : in    std_logic_vector;
          ref_cnt  : out   integer;
          hit_cnt  : out   integer);
  end component I_CACHE;

  component I_CACHE_fpga is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          ic_reset : out   std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data : out   std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_addr : out   std_logic_vector;
          mem_data : in    std_logic_vector;
          ref_cnt  : out   integer;
          hit_cnt  : out   integer);
  end component I_CACHE_fpga;

  component fake_D_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_wr   : in    std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data_inp : in  std_logic_vector;
          cpu_data_out : out std_logic_vector;
          cpu_xfer : in    std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_wr   : out   std_logic;
          mem_addr : out   std_logic_vector;
          mem_data_inp : in  std_logic_vector;
          mem_data_out : out std_logic_vector;
          mem_xfer : out   std_logic_vector;
          ref_cnt  : out   integer;
          rd_hit_cnt : out integer;
          wr_hit_cnt : out integer;
          flush_cnt  : out integer);
  end component fake_D_CACHE;

  component D_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_wr   : in    std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data_inp : in  std_logic_vector;
          cpu_data_out : out std_logic_vector;
          cpu_xfer : in    std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_wr   : out   std_logic;
          mem_addr : out   std_logic_vector;
          mem_data_inp : in  std_logic_vector;
          mem_data_out : out std_logic_vector;
          mem_xfer : out   std_logic_vector;
          ref_cnt  : out   integer;
          rd_hit_cnt : out integer;
          wr_hit_cnt : out integer;
          flush_cnt  : out integer);
  end component D_CACHE;

  
  component core is
    generic(coreNumber : integer := 0);
    port (rst    : in    std_logic;
          clk    : in    std_logic;
          clk4x  : in    std_logic;
          phi0   : in    std_logic;
          phi1   : in    std_logic;
          phi2   : in    std_logic;
          phi3   : in    std_logic;
          i_aVal : out   std_logic;
          i_wait : in    std_logic;
          i_addr : out   std_logic_vector;
          instr  : in    std_logic_vector;
          d_aVal : out   std_logic;
          d_wait : in    std_logic;
          d_addr : out   std_logic_vector;
          data_inp : in  std_logic_vector;
          data_out : out std_logic_vector;
          wr     : out   std_logic;
          b_sel  : out   std_logic_vector;
          nmi    : in    std_logic;
          irq    : in    std_logic_vector);
  end component core;

  component count4phases is
    port(clk, rst    : in  std_logic;
         p0,p1,p2,p3 : out std_logic);
  end component count4phases;


  signal clk,clk4x,rst : std_logic;
  signal phi0,phi1,phi2,phi3 : std_logic;
  signal ic_reset, async_reset, cpu_reset : std_logic;

  -- cMIPS_0 (Xeam_Zoom)
  signal cpu_i_aVal, cpu_i_wait, wr, cpu_d_aVal, cpu_d_wait : std_logic := 'H';
  signal nmi : std_logic;
  signal irq : reg6;
  signal inst_aVal, inst_wait, rom_rdy : std_logic := '1';
  signal data_aVal, data_wait, ram_rdy, mem_wr : std_logic := '1';
  signal cpu_xfer, mem_xfer  : reg4;
  signal dev_select : reg5;
  signal io_print_sel,   io_print_wait   : std_logic := '1';
  signal io_stdout_sel,  io_stdout_wait  : std_logic := '1';
  signal io_stdin_sel,   io_stdin_wait   : std_logic := '1';
  signal io_write_sel,   io_write_wait   : std_logic := '1';
  signal io_read_sel,    io_read_wait    : std_logic := '1';
  signal io_counter_sel, io_counter_wait : std_logic := '1';
  signal io_fpu_sel,     io_fpu_wait     : std_logic := '1';
  signal io_uart_sel,    io_uart_wait    : std_logic := '1';
  signal io_sstats_sel,  io_sstats_wait  : std_logic := '1';
  signal io_7seg_sel,    io_7seg_wait    : std_logic := '1';
  signal io_keys_sel,    io_keys_wait    : std_logic := '1';
  signal d_cache_d_out, stdin_d_out, read_d_out, counter_d_out : reg32;
  signal fpu_d_out, uart_d_out, sstats_d_out, keybd_d_out : reg32;

  signal counter_irq : std_logic := '0';
  signal io_wait, not_waiting : std_logic := '0';
  signal i_addr,d_addr,p_addr : reg32;
  signal datrom, datram_inp,datram_out, cpu_instr : reg32;
  signal cpu_data_inp, cpu_data_out, cpu_data : reg32;
  signal mem_i_sel, mem_d_sel: std_logic := '1';
  signal mem_i_addr, mem_addr, mem_d_addr: reg32;
  signal cnt_i_ref,cnt_i_hit : integer;
  signal cnt_d_ref,cnt_d_rd_hit,cnt_d_wr_hit,cnt_d_flush : integer := 0;

  signal dump_ram : std_logic := '0';
  
  -- cMIPS_1 (Xeam_Constraste)
  signal cpu_i_aVal_1, cpu_i_wait_1, wr_1, cpu_d_aVal_1, cpu_d_wait_1 : std_logic := 'H';
  signal nmi_1 : std_logic;
  signal irq_1 : reg6;
  signal inst_aVal_1, inst_wait_1, rom_rdy_1 : std_logic := '1';
  signal data_aVal_1, data_wait_1, ram_rdy_1, mem_wr_1 : std_logic := '1';
  signal cpu_xfer_1, mem_xfer_1  : reg4;
  signal dev_select_1 : reg5;
  
  signal io_print_sel_1,   io_print_wait_1   : std_logic := '1';
  signal io_stdout_sel_1,  io_stdout_wait_1  : std_logic := '1';
  signal io_stdin_sel_1,   io_stdin_wait_1   : std_logic := '1';
  signal io_write_sel_1,   io_write_wait_1   : std_logic := '1';
  signal io_read_sel_1,    io_read_wait_1    : std_logic := '1';
  signal io_counter_sel_1, io_counter_wait_1 : std_logic := '1';
  signal io_fpu_sel_1,     io_fpu_wait_1     : std_logic := '1';
  signal io_uart_sel_1,    io_uart_wait_1    : std_logic := '1';
  signal io_sstats_sel_1,  io_sstats_wait_1  : std_logic := '1';
  signal io_7seg_sel_1,    io_7seg_wait_1    : std_logic := '1';
  signal io_keys_sel_1,    io_keys_wait_1    : std_logic := '1';
  signal d_cache_d_out_1, stdin_d_out_1, read_d_out_1, counter_d_out_1 : reg32;
  signal fpu_d_out_1, uart_d_out_1, sstats_d_out_1, keybd_d_out_1 : reg32;

  signal counter_irq_1 : std_logic := '0';
  signal io_wait_1, not_waiting_1 : std_logic := '0';
  signal i_addr_1, d_addr_1, p_addr_1 : reg32;
  signal datrom_1, datram_inp_1, datram_out_1, cpu_instr_1 : reg32;
  signal cpu_data_inp_1, cpu_data_out_1, cpu_data_1 : reg32;
  signal mem_i_sel_1, mem_d_sel_1: std_logic := '1';
  signal mem_i_addr_1, mem_addr_1, mem_d_addr_1: reg32;
  signal cnt_i_ref_1, cnt_i_hit_1 : integer;
  signal cnt_d_ref_1, cnt_d_rd_hit_1, cnt_d_wr_hit_1, cnt_d_flush_1 : integer := 0;

  signal dump_ram_1 : std_logic := '0';

  -- UART
  signal txdat, rxdat, uart_irq, start_remota : std_logic;
  signal bit_rt : reg3;

  -- BCD
  signal read_bcdW_out : reg32; 
  signal read_bcdR_out : reg32; 

  -- BCD_W
  signal io_bcdW_sel,       io_bcdW_wait      : std_logic := '1';
  signal io_bcdR_sel_dumb,  io_bcdR_wait_dumb : std_logic := '1';
  -- BCD_R
  signal io_bcdW_sel_dumb,  io_bcdW_wait_dumb : std_logic := '1';
  signal io_bcdR_sel,       io_bcdR_wait      : std_logic := '1';

  -- DMA_USB
  -- RAM
  signal dmausb_d_sel_ram, dmausb_rdy_ram, dmausb_wr_ram : std_logic;
  signal dmausb_addr_ram, dmausb_datram_in_ram, dmausb_datram_out_ram : reg32;
  signal dmausb_xfer_ram : reg4;
  signal io_dmaUSB_sel,       io_dmaUSB_wait      : std_logic := '1';
  signal dmaUSB_d_out : reg32;
  signal io_dmaVGA_sel_dumb,       io_dmaVGA_wait_dumb : std_logic := '1';

  -- DMA_VGA
  -- RAM
  signal dmavga_d_sel_ram, dmavga_rdy_ram, dmavga_wr_ram : std_logic;
  signal dmavga_addr_ram, dmavga_datram_in_ram, dmavga_datram_out_ram : reg32;
  signal dmavga_xfer_ram : reg4;
  signal io_dmaVGA_sel,       io_dmaVGA_wait      : std_logic := '1';
  signal dmaVGA_d_out : reg32;
  signal io_dmaUSB_sel_dumb,       io_dmaUSB_wait_dumb : std_logic := '1';

  -- Macnica development board's peripherals
  signal dsp0,dsp1 : reg8;              -- 7 segment displays
  signal keys : reg12;                  -- 12key telephone keyboard
  signal switches : reg4;               -- 4 switches

begin  -- TB

  U_4PHASE_CLOCK: count4phases
    port map (clk4x, rst, phi0,phi1,phi2,phi3);

  async_reset <= rst and ic_reset;
  U_SYNC_RESET: FFD port map (clk, rst, '1', async_reset, cpu_reset);

  -- cMIPS_0 (Xeam_Zoom)
  cpu_i_wait <= inst_wait;
  cpu_d_wait <= data_wait; --  and io_wait;
  io_wait    <= '1'; -- io_print_wait and io_stdout_wait and io_stdin_wait and
                -- io_write_wait and io_read_wait and
                -- io_counter_wait and -- io_uart_wait and
                -- io_sstats_wait and --  io_fpu_wait 
                -- io_7seg_wait and  io_keys_wait and
                -- BCD 
                -- io_bcdW_wait_1;

  not_waiting <= (inst_wait and data_wait); --  and io_wait);

  -- irq <= b"000000"; -- NO interrupt requests
  -- irq <= b"0000" & uart_irq & counter_irq; -- uart+counter interrupts
  irq <= b"00000" & counter_irq; -- uart+counter interrupts
  nmi <= '0';

  -- cMIPS_1 (Xeam_Zoom)
  cpu_i_wait_1 <= inst_wait_1;
  cpu_d_wait_1 <= data_wait_1 and io_wait_1; 
  io_wait_1    <= '1'; -- io_print_wait_1 and io_stdout_wait_1 and io_stdin_wait_1 and
                  -- io_write_wait_1 and io_read_wait_1 and
                  -- io_counter_wait_1 and -- io_uart_wait and
                  -- io_sstats_wait_1 and --  io_fpu_wait 
                  -- io_7seg_wait_1 and io_keys_wait_1 and
                  -- BCD 
                  -- io_bcdR_wait_1;

  not_waiting_1 <= (inst_wait_1 and data_wait_1); -- and io_wait_1);

  -- irq <= b"000000"; -- NO interrupt requests
  -- irq <= b"0000" & uart_irq & counter_irq; -- uart+counter interrupts
  irq_1 <= b"00000" & counter_irq_1; -- uart+counter interrupts
  nmi_1 <= '0';

  -- cMIPS_0 (Xeam_Zoom)
  U_CORE: core  generic map (coreNumber => 0)
                port map (cpu_reset, clk, clk4x, phi0,phi1,phi2,phi3,
                         cpu_i_aVal, cpu_i_wait, i_addr, cpu_instr,
                         cpu_d_aVal, cpu_d_wait, d_addr, cpu_data_inp, cpu_data,
                         wr, cpu_xfer, nmi, irq);

  -- cMIPS_1 (Xeam_Contraste)
  U_CORE_1: core generic map (coreNumber => 1)
                 port map (cpu_reset, clk, clk4x, phi0,phi1,phi2,phi3,
                         cpu_i_aVal_1, cpu_i_wait_1, i_addr_1, cpu_instr_1,
                         cpu_d_aVal_1, cpu_d_wait_1, d_addr_1, cpu_data_inp_1, cpu_data_1,
                         wr_1, cpu_xfer_1, nmi_1, irq_1);

  -- cMIPS_0 (Xeam_Zoom)
  U_INST_ADDR_DEC: inst_addr_decode
    port map (rst, cpu_i_aVal, i_addr, inst_aVal, not_waiting);

  -- cMIPS_1 (Xeam_Contraste)
  U_INST_ADDR_DEC_1: inst_addr_decode
    port map (rst, cpu_i_aVal_1, i_addr_1, inst_aVal_1, not_waiting_1);

  -- cMIPS_0 (Xeam_Zoom)  
  U_I_CACHE: fake_i_cache   -- or i_cache
  -- U_I_CACHE: i_cache  -- or fake_i_cache
  -- U_I_CACHE: i_cache_fpga  -- or FPGA implementation 
    port map (rst, clk4x, ic_reset,
              inst_aVal, inst_wait, i_addr,      cpu_instr,
              mem_i_sel,  rom_rdy,   mem_i_addr, datrom, cnt_i_ref,cnt_i_hit);

  -- cMIPS_1 (Xeam_Contraste)
   U_I_CACHE_1: fake_i_cache   -- or i_cache
  -- U_I_CACHE_1: i_cache  -- or fake_i_cache
  -- U_I_CACHE_1: i_cache_fpga  -- or FPGA implementation 
    port map (rst, clk4x, ic_reset,
              -- cpu_i_aVal, inst_wait, i_addr,     cpu_instr,
              inst_aVal_1, inst_wait_1, i_addr_1,     cpu_instr_1,
              mem_i_sel_1,  rom_rdy_1,   mem_i_addr_1, datrom_1, cnt_i_ref_1, cnt_i_hit_1);

  -- cMIPS_0 (Xeam_Zoom)
  U_ROM: simul_ROM generic map ("prog.bin")
  -- U_ROM: fpga_ROM generic map ("prog.bin")
    port map (rst, clk, mem_i_sel, rom_rdy,phi3, mem_i_addr, datrom);

  -- cMIPS_1 (Xeam_Contraste)
  U_ROM_1: simul_ROM generic map ("prog1.bin")
  -- U_ROM: fpga_ROM generic map ("prog1.bin")
    port map (rst, clk, mem_i_sel_1, rom_rdy_1,phi3, mem_i_addr_1, datrom_1);

  -- cMIPS_0 (Xeam_Zoom)
  U_DATA_ADDR_DEC: data_addr_decode
    port map (rst, clk, cpu_d_aVal, d_addr, data_aVal, dev_select,
              io_print_sel, io_stdout_sel, io_stdin_sel,io_read_sel, 
              io_write_sel, io_counter_sel, io_fpu_sel, io_uart_sel,
              io_sstats_sel, io_7seg_sel, io_keys_sel,
              -- BCD_W
              io_bcdW_sel, io_bcdR_sel_dumb,
              -- DMA_USB
              io_dmaUSB_sel,
              -- DMA_VGA
              io_dmaVGA_sel_dumb,
              not_waiting);

  with dev_select select
    cpu_data_inp <= (others => 'X') when b"00000",
                    d_cache_d_out   when b"00001",
                    stdin_d_out     when b"00100",
                    read_d_out      when b"00101",
                    counter_d_out   when b"00111",
                    fpu_d_out       when b"01000",
                    uart_d_out      when b"01001",
                    sstats_d_out    when b"01010",
                    keybd_d_out     when b"01100",
                    -- BCD
                    read_bcdW_out   when b"01101",
  --                  read_bcdR_out   when b"01110", -- Não existe em MIPS_0
                    -- DMA_USB
                    dmaUSB_d_out when b"01111",
                    (others => 'X') when others;
  
  -- U_D_MMU: mem_d_addr <=        -- access Dcache with physical addresses
  --   std_logic_vector(unsigned(d_addr) - unsigned(x_DATA_BASE_ADDR));

  -- cMIPS_1 (Xeam_Contraste)
  U_DATA_ADDR_DEC_1: data_addr_decode
    port map (rst, clk, cpu_d_aVal_1, d_addr_1, data_aVal_1, dev_select_1,
              io_print_sel_1, io_stdout_sel_1, io_stdin_sel_1, io_read_sel_1, 
              io_write_sel_1, io_counter_sel_1, io_fpu_sel_1, io_uart_sel_1,
              io_sstats_sel_1, io_7seg_sel_1, io_keys_sel_1,
              -- BCD_W
              io_bcdW_sel_dumb, io_bcdR_sel,
              -- DMA_USB
              io_dmaUSB_sel_dumb,
              -- DMA_VGA
              io_dmaVGA_sel,
              not_waiting_1);

  with dev_select_1 select
    cpu_data_inp_1 <= (others => 'X') when b"00000",
                    d_cache_d_out_1   when b"00001",
                    stdin_d_out_1     when b"00100",
                    read_d_out_1      when b"00101",
                    counter_d_out_1   when b"00111",
                    fpu_d_out_1       when b"01000",
                    uart_d_out_1      when b"01001",
                    sstats_d_out_1    when b"01010",
                    keybd_d_out_1     when b"01100",
                    -- BCD
  --                read_bcdW_out   when b"01101", -- Não existe em MIPS_1
                    read_bcdR_out   when b"01110", 
                    -- DMA_VGA
                    dmaVGA_d_out  when b"10000",
                    (others => 'X') when others;

  -- cMIPS_0 (Xeam_Zoom)
  U_D_CACHE: fake_d_cache   -- or d_cache
  -- U_D_CACHE: d_cache   -- or fake_d_cache
    port map (rst, clk4x,
              data_aVal, data_wait, wr,
              d_addr, cpu_data, d_cache_d_out, cpu_xfer,
              mem_d_sel, ram_rdy,   mem_wr,
              mem_addr,  datram_inp, datram_out,   mem_xfer,
              cnt_d_ref, cnt_d_rd_hit, cnt_d_wr_hit, cnt_d_flush);

  -- cMIPS_1 (Xeam_Contraste)
  U_D_CACHE_1: fake_d_cache   -- or d_cache
  -- U_D_CACHE_1: d_cache   -- or fake_d_cache
    port map (rst, clk4x,
              data_aVal_1, data_wait_1, wr_1,
              d_addr_1, cpu_data_1, d_cache_d_out_1, cpu_xfer_1,
              mem_d_sel_1, ram_rdy_1,   mem_wr_1,
              mem_addr_1,  datram_inp_1, datram_out_1,   mem_xfer_1,
              cnt_d_ref_1, cnt_d_rd_hit_1, cnt_d_wr_hit_1, cnt_d_flush_1);

  -- cMIPS_0 (Xeam_Zoom)
  U_RAM: simul_RAM generic map ("data.bin", "dump.data")
  -- U_RAM: fpga_RAM generic map ("data.bin", "dump.data")
    port map (rst, clk, 
              dmausb_d_sel_ram, dmausb_rdy_ram, dmausb_wr_ram,phi3, dmausb_addr_ram, 
              dmausb_datram_in_ram,    -- Entrada de dados da RAM
              dmausb_datram_out_ram,   -- Saída de dados da RAM
              dmausb_xfer_ram, dump_ram);

  -- cMIPS_1 (Xeam_Contraste)
   U_RAM_1: simul_RAM generic map ("data1.bin", "dump1.data")
  -- U_RAM_1: fpga_RAM generic map ("data1.bin", "dump1.data")
    port map (rst, clk,
              dmavga_d_sel_ram, dmavga_rdy_ram, dmavga_wr_ram,phi3, dmavga_addr_ram, 
              dmavga_datram_in_ram,    -- Entrada de dados da RAM
              dmavga_datram_out_ram,   -- Saída de dados da RAM
              dmavga_xfer_ram, dump_ram_1);

  -- cMIPS_0 (Xeam_Zoom)  
  U_read_inp: read_data_file generic map ("input.data")
    port map (rst,clk, io_read_sel,io_read_wait,  wr,d_addr,read_d_out,
              cpu_xfer);

  -- cMIPS_1 (Xeam_Contraste)
  U_read_inp_1: read_data_file generic map ("input1.data")
    port map (rst,clk,  
              io_read_sel_1, io_read_wait_1, wr_1, d_addr_1, read_d_out_1, cpu_xfer_1);

  -- cMIPS_0 (Xeam_Zoom)
  U_write_out: write_data_file generic map ("output.data")
    port map (rst,clk, io_write_sel,io_write_wait, wr,d_addr,cpu_data,
              cpu_xfer, dump_ram);

  -- cMIPS_1 (Xeam_Contraste)
  U_write_out_1: write_data_file generic map ("output1.data")
    port map (rst,clk, 
              io_write_sel_1, io_write_wait_1, wr_1, d_addr_1, cpu_data_1,
              cpu_xfer_1, dump_ram_1);

  -- BCD
  U_BCD : circularBuffer
    port map(clk, clk4x, rst,                                        -- Gerais
             io_bcdW_sel, cpu_data, wr, read_bcdW_out, io_bcdW_wait, -- Write
             io_bcdR_sel, d_addr_1, read_bcdR_out, io_bcdR_wait);    -- Read

--ram_rdy <= '1';
--io_dmaUSB_wait <= '1';
------------------------
  -- USB_DMA
   U_dmaUSB : dma_usb_module
    port map( rst, clk, phi1, 
              io_dmaUSB_sel,    cpu_data,       dmaUSB_d_out,    d_addr,          wr,                    io_dmaUSB_wait,                                        
              dmausb_d_sel_ram, dmausb_rdy_ram, dmausb_wr_ram,   dmausb_addr_ram, dmausb_datram_in_ram,  dmausb_datram_out_ram, dmausb_xfer_ram,   -- RAM
              mem_d_sel,        ram_rdy,        mem_wr,          mem_addr,        datram_inp,            datram_out,            mem_xfer          -- DCACHE
    );


--ram_rdy_1 <= '1';
--io_dmaVGA_wait <= '1';
------------------------------------------
  -- USB_DMA
  U_dmaVGA : dma_vga_module
    port map( rst, clk, phi0, phi1, phi2,
              io_dmaVGA_sel,    cpu_data_1,     dmaVGA_d_out,    d_addr_1,        wr_1,                  io_dmaVGA_wait,                                        
              dmavga_d_sel_ram, dmavga_rdy_ram, dmavga_wr_ram,   dmavga_addr_ram, dmavga_datram_in_ram,  dmavga_datram_out_ram, dmavga_xfer_ram, -- RAM
              mem_d_sel_1,      ram_rdy_1,      mem_wr_1,        mem_addr_1,      datram_inp_1,          datram_out_1,          mem_xfer_1       -- DCACHE
   );

  -- cMIPS_0 (Xeam_Zoom)
  U_print_data: print_data
    port map (rst,clk, io_print_sel,io_print_wait, wr,d_addr,cpu_data);

  -- cMIPS_1 (Xeam_Contraste)
  U_print_data_1: print_data
    port map (rst,clk, 
              io_print_sel_1, io_print_wait_1, wr_1, d_addr_1, cpu_data_1);

  -- cMIPS_0 (Xeam_Zoom)
  U_to_stdout: to_stdout
    port map (rst,clk,io_stdout_sel,io_stdout_wait,wr,d_addr,cpu_data);

  -- cMIPS_1 (Xeam_Contraste)
  U_to_stdout_1: to_stdout
    port map (rst,clk,
              io_stdout_sel_1, io_stdout_wait_1, wr_1, d_addr_1, cpu_data_1);

  -- U_simple_uart: simple_uart
  --   port map (rst,clk, io_uart_sel, io_uart_wait,
  --             wr, d_addr(2), cpu_data, uart_d_out,
  --             txdat, rxdat, uart_irq, bit_rt);

  -- start_remota <= '0', '1' after 100*CLOCK_PER;
  
  -- U_uart_remota: remota generic map ("serial.out","serial.inp")
  --   port map (rst, clk, start_remota, txdat, rxdat, bit_rt);

  -- U_FPU: FPU
  --   port map (rst,clk, io_FPU_sel, io_FPU_wait,
  --             wr, d_addr, cpu_data);

  -- U_interrupt_counter: do_interrupt     -- external counter+interrupt
  --   port map (rst,clk, io_counter_sel, io_counter_wait,
  --             wr, d_addr, cpu_data, counter_d_out, counter_irq);

  -- U_sys_stats: sys_stats                -- CPU reads system counters
  --   port map (rst,clk, io_sstats_sel, io_sstats_wait,
  --             wr, d_addr, sstats_d_out,
  --             cnt_d_ref,cnt_d_rd_hit,cnt_d_wr_hit,cnt_d_flush,
  --             cnt_i_ref,cnt_i_hit);

  -- U_to_7seg: to_7seg
    --port map (rst,clk,io_7seg_sel,io_7seg_wait,wr,cpu_data,dsp0,dsp1);

  keys <= b"000000000000", b"000000000100" after 1 us, b"000000000000" after 2 us,  b"001000000000" after 3 us, b"000000000000" after 4 us, b"000001000000" after 5 us;
  switches <= b"0000";
          
  --U_read_keys: read_keys
   -- port map (rst,clk,
     --         io_keys_sel,io_keys_wait,keybd_d_out,keys,switches);


  
  U_clock: process    -- the two clocks MUST start in opposite phases
  begin
    clk <= '1';
    wait for CLOCK_PER / 2;
    clk <= '0';
    wait for CLOCK_PER / 2;
  end process;  -- -------------------------------------------------------
  
  U_clock4x: process  -- the two clocks MUST start in opposite phases
  begin
    clk4x <= '0';
    wait for CLOCK_PER / 8;
    clk4x <= '1';
    wait for CLOCK_PER / 8;
  end process;  -- -------------------------------------------------------
  
  U_reset: process
  begin
    rst <= '0';
    wait for CLOCK_PER;  -- reset pulse must end on the rising edge of clock
    rst <= '1';
    wait;
  end process;  -- -------------------------------------------------------

end architecture TB;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- --------------------------------------------------------------
configuration CFG_TB of TB_CMIPS is
	for TB
        end for;
end configuration CFG_TB;
-- --------------------------------------------------------------

