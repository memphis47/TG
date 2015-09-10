--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- File contains all 4 necessary modules for emulated-dma-usb
-- Module: dma_usb, usb_fake, muxram_dcache_dma and usb-module for cMIPS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DMA to usb -> RAM
-- peripheral: dma_usb
-- operation: Reads 4 bytes from USB and storage in RAM
-- The transaction begins with a starter address from cMIPS
--    Each aditional transactions needs a starter address from cMIPS 
--    (can be the same initial address) 
-- cMIPS can read the current address, returns -1 when transactions are ended
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;

entity dma_usb is
  port (rst       : in  std_logic;
        clk       : in  std_logic;
        phi1      : in  std_logic;
        -- USB
	      usb_rd_n  : out std_logic;	-- Sinal de leitura de dados    -- act = '0'
        usb_rfx_n : in  std_logic;	-- Sinal de "dados disponíveis" -- act = '0'
        data      : in  reg8;       -- Dados
        -- RAM
        sel_ram   : out std_logic;
        rdy_ram   : in  std_logic;
        wr_ram    : out std_logic;
        addr_ram  : out reg32;
        data_ram  : out reg32;
        b_sel_ram : out reg4;
        -- cMIPS
		    c_sel 	   : in  std_logic;	  -- Sinal de seleção
		    c_data_in  : in  reg32;		    -- Dados para gravação / endereço inicial
		    c_data_out : out reg32;		    -- Dados de leitura / imagem completamente gravada
        c_addr     : in  reg32;
		    c_we 	     : in  std_logic;		-- Sinal de gravação (=1) ou leitura (=0)
		    c_rdy 	   : out std_logic 		-- iwait
          );
end dma_usb;

architecture behavioral of dma_usb is

  component FFT is
  port(clk, rst : in std_logic;
        T : in  std_logic;
        Q : out std_logic);
  end component FFT;

  signal rdata1  : reg32 := (others => '0'); -- Registrador para pixel lido
  signal rdata2  : reg32 := (others => '0'); -- Registrador para pixel lido

  signal rdata2free : std_logic;  -- rdata2free = '0' = não disponível para reescrita de rdata2
                                  -- rdata2free = '1' =     disponível para reescrita de rdata2

  signal rdata2send : std_logic;  -- rdata2send = '0' = dado em rdata2 não disponível para escrita em RAM
                                  -- rdata2send = '1' = dado em rdata2     disponível para escrita em RAM

  type estado_tipo_rcv is (reset, waitcMIPS, esperaRFX, enviaRD, delayslot1, delayslot2, T0, T1, T2, T3, cpdata1, cpdata2);
  signal estado_rcv : estado_tipo_rcv;

  type estado_tipo_wrRAM is(reset, waitcMIPS, esperaRDATA, enviaRAM, E1, E2);
  signal estado_wrRAM : estado_tipo_wrRAM;
  
  signal initBycMips : std_logic; -- initBycMips = '0' = cMIPS não iniciou processo
                                  -- initBycMips = '1' = cMIPS     iniciou processo

  signal init, init0, init1, control, control_final : std_logic;

  signal s_b_sel_ram        : reg4;
  signal s_addr_ram         : reg32;
  signal s_addr_ram_inicial : reg32;
  signal s_addr_ram_size    : reg32;
  signal s_addr_ram_final   : reg32;

begin

  -- ME para transferência USB
	U_rcv_me: process (clk, rst)
	begin
		if rst = '0' then
			estado_rcv <= reset;
		elsif (rising_edge(clk)) then
			case estado_rcv is
				when reset =>
						estado_rcv <= waitcMIPS;
        when waitcMIPS =>
            if initBycMips = '1' then 
              estado_rcv <= esperaRFX;
            else
              estado_rcv <= waitcMIPS;
            end if;
				when esperaRFX =>
					if usb_rfx_n = '0' then
						estado_rcv <= enviaRD;
					else
						estado_rcv <= esperaRFX;
					end if;
        when enviaRD =>
            estado_rcv <= T0;
            estado_rcv <= delayslot1;
        when delayslot1 =>
            estado_rcv <= delayslot2;
        when delayslot2 =>
            estado_rcv <= T0;
				when T0 =>
						estado_rcv <= T1;
				when T1 =>
						estado_rcv <= T2;
				when T2 =>
						estado_rcv <= T3;
				when T3 =>
              estado_rcv <= cpdata1;
        when cpdata1 =>
              if rdata2send = '1' then   
                estado_rcv <= cpdata1;  -- não disponível
              else
                estado_rcv <= cpdata2;  -- disponível
              end if;
        when cpdata2 =>
              if s_addr_ram >= s_addr_ram_final then
                estado_rcv <= waitcMIPS;
              else
                estado_rcv <= esperaRFX;
              end if;
			end case;
		end if;
	end process U_rcv_me;

  -- Transferencia USB
  U_rcv_usb: process(clk)
  begin
    if (rising_edge(clk)) then
		  case estado_rcv is
			  when reset =>
					  -- do nothing;
            rdata2free <= '1';
        when waitcMIPS =>
          -- do nothing for now
        when esperaRFX =>
					  -- do nothing;
            rdata2free <= '1';
        when enviaRD =>
             usb_rd_n <= '0';
        when delayslot1 =>
            -- do nothing
        when delayslot2 =>
            -- do nothing
			  when T0 =>
            rdata1( 7 downto  0) <= data;
			  when T1 =>
            rdata1(15 downto  8) <= data;
			  when T2 =>
            rdata1(23 downto 16) <= data;
			  when T3 =>
            rdata1(31 downto 24) <= data;
            usb_rd_n <= '1';
        when cpdata1 =>
            -- do nothing
        when cpdata2 =>
            rdata2 <= rdata1;
            rdata2free <= '0';
		  end case;
    end if;
  end process U_rcv_usb;

  -- ME para escrita na RAM
  U_RAM_me: process (clk)
  begin

		if rst = '0' then
			estado_wrRAM <= reset;
		elsif (rising_edge(clk)) then
			case estado_wrRAM is
				when reset =>
						estado_wrRAM <= waitcMIPS;
        when waitcMIPS =>
            if initBycMips = '1' then 
              estado_wrRAM <= esperaRDATA;
            else
              estado_wrRAM <= waitcMIPS;
            end if;
        when esperaRDATA =>
            if rdata2free = '0' then
              estado_wrRAM <= enviaRAM;
            else
              estado_wrRAM <= esperaRDATA;
            end if;
        when enviaRAM =>
            estado_wrRAM <= E1;
        when E1 =>
            if rdy_ram = '1' then
              if s_addr_ram >= s_addr_ram_final then
                estado_wrRAM <= waitcMIPS;
              else
                estado_wrRAM <= E2;
              end if;
            else
              estado_wrRAM <= enviaRAM; 
            end if;
        when E2 =>
          estado_wrRAM <= esperaRDATA;
			end case;
		end if;

  end process U_RAM_me;

  -- Escrita para RAM
  U_RAM_wr: process(clk)
  begin

    if (rising_edge(clk)) then
      case estado_wrRAM is
        when reset =>
          rdata2send <= '0';
        when waitcMIPS =>
          s_addr_ram <= s_addr_ram_inicial;
          s_addr_ram_final <= std_logic_vector(unsigned(s_addr_ram_inicial) + unsigned(s_addr_ram_size));
        when esperaRDATA =>
          addr_ram <= s_addr_ram;
        when enviaRAM =>
          rdata2send <= '1';
          sel_ram <= '0';
          data_ram <= rdata2;                
        when E1 =>
          sel_ram <= '1';
        when E2 =>
          rdata2send <= '0';
--          assert false report "DMA_USB_transfer_ADDR["&SLV32HEX(s_addr_ram)&"]";
          s_addr_ram <= std_logic_vector(unsigned(s_addr_ram) + 4);
      end case;
    end if; -- rising_edge(clk)

  end process U_RAM_wr;

  -- sinais fixos para ram
  b_sel_ram <= "1111";
  wr_ram <= '0';

  -- CMIPS
  -- Escrita de endereço inicial e # bytes a ser transferido (por cMIPS)
  s_addr_ram_inicial <= c_data_in when (c_sel = '0' and c_we = '0' and c_addr(2) = '0' and c_addr(3) = '0' and falling_edge(phi1));
  s_addr_ram_size    <= c_data_in when (c_sel = '0' and c_we = '0' and c_addr(2) = '1' and c_addr(3) = '0' and falling_edge(phi1));

  init <= '1' when (c_sel = '0' and c_we = '0' and c_addr(3) = '1') else '0';
  
  -- Leitura do # de pixels da imagem transferidos (por cMIPS)
--  c_data_out <= s_addr_ram when (c_sel = '0' and c_we = '1') else (others => '1');
    c_data_out(31 downto 4) <= x"0000000";
    c_data_out( 3 downto 1) <= b"000";
    c_data_out(0) <= initBycMips;

  -- Comum a Escrita e Leitura
  c_rdy      <= '0' when (c_sel = '0' and phi1 = '1') else '1';

  U_manager_dma: process(clk)
  begin

		if rst = '0' then
			initBycMips <= '0';
		elsif (rising_edge(clk)) then
      if init = '1' then
        if initBycMips = '0' then
          initBycMips <= '1';  
        end if;    
      elsif s_addr_ram >= s_addr_ram_final then
          initBycMips <= '0';  
      end if; -- if init
  end if; -- if rst

  end process U_manager_dma;

  U_dma_times: process(initBycMips)
  begin

    if (rst = '1') then
      assert (initBycMips'event and initBycMips = '0') report "DMA_USB_transfer: init";

--      assert (initBycMips'event and initBycMips = '0') report "DRAM_inicial["&SLV32HEX(s_addr_ram_inicial)&"]";
--      assert (initBycMips'event and initBycMips = '0') report "DRAM_size["&SLV32HEX(s_addr_ram_size)&"]";
--      assert (initBycMips'event and initBycMips = '0') report "DRAM_final["&SLV32HEX(s_addr_ram_final)&"]";

      assert (initBycMips'event and initBycMips = '1') report "DMA_USB_transfer: stop";

    end if; -- reset

  end process U_dma_times;

end behavioral;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- MUX DCACHE vs DMA_USB > RAM
-- peripheral: muxram_dcache_dma
-- operation: DMA_USB only access RAM when DCACHE don't
--            DCACHE has priority 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;

entity muxram_dcache_dma is
  port(
    -- DMA_USB
    mem_d_sel_dma  : in  std_logic;
    ram_rdy_dma    : out std_logic;
    mem_wr_dma     : in  std_logic;
    mem_addr_dma   : in  reg32;
    datram_in_dma  : out reg32;
    datram_out_dma : in  reg32;
    mem_xfer_dma   : in  reg4;
    -- DCACHE
    mem_d_sel_dcache  : in  std_logic;
    ram_rdy_dcache    : out std_logic;
    mem_wr_dcache     : in  std_logic;
    mem_addr_dcache   : in  reg32;
    datram_in_dcache  : out reg32;
    datram_out_dcache : in  reg32;
    mem_xfer_dcache   : in  reg4;   
    -- RAM
    mem_d_sel_ram  : out std_logic;
    ram_rdy_ram    : in  std_logic;
    mem_wr_ram     : out std_logic;
    mem_addr_ram   : out reg32;
    datram_in_ram  : in  reg32;
    datram_out_ram : out reg32;
    mem_xfer_ram   : out reg4
  );
end muxram_dcache_dma; 


architecture behavioral of muxram_dcache_dma is

  -- Controle
  signal mux_dev_select : std_logic;  -- '0' dma_usb
                                      -- '1' dcache

begin

  -- DCACHE Priority
--  mux_dev_select <= '0' when mem_d_sel_dma = '0' and mem_d_sel_dcache = '1' else '1';
  -- DMA Priority
  mux_dev_select <= '1' when mem_d_sel_dma = '1' and mem_d_sel_dcache = '0' else '0';

  -- mem_d_sel_ram
  with mux_dev_select select
    mem_d_sel_ram <= mem_d_sel_dma    when '0',
                     mem_d_sel_dcache when others;

  -- ram_rdy_ram > dma
  with mux_dev_select select
    ram_rdy_dma <= ram_rdy_ram when '0',
                   '0' when others;

  -- ram_rdy_ram > dcache
  with mux_dev_select select
    ram_rdy_dcache <= ram_rdy_ram when '1',
                      '0' when others;

  -- mem_wr_ram
  with mux_dev_select select
    mem_wr_ram <= mem_wr_dma when '0',
                  mem_wr_dcache when others;

  -- mem_addr_ram
  with mux_dev_select select
    mem_addr_ram <= mem_addr_dma when '0', 
                    mem_addr_dcache when others;

  -- datram_in_ram > dma
  with mux_dev_select select
    datram_in_dma <= datram_in_ram when '0',
                     (others => 'X') when others;

  -- datram_in_ram > dcache
  with mux_dev_select select
    datram_in_dcache <= datram_in_ram when '1',
                        (others => 'X') when others;

  -- datram_out_ram
  with mux_dev_select select
    datram_out_ram <= datram_out_dma when '0',
                      datram_out_dcache when others;

  -- mem_xfer_ram
  with mux_dev_select select
    mem_xfer_ram <= mem_xfer_dma when '0',
                    mem_xfer_dcache when others;

end behavioral;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Emulates an usb isochronous transfer
-- peripheral: usb_fake
-- operation: Reads 32bits from file and send in 4 steps to host
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity usb_fake is
  generic (INPUT_FILE_NAME : string := "img.data");
  port (rst       : in  std_logic;
        clk       : in  std_logic;
	      usb_rd_n  : in  std_logic;	-- Sinal de leitura de dados    -- act = '0'
        usb_rfx_n : out std_logic;	-- Sinal de "dados disponíveis" -- act = '0'
        data      : out reg8);      -- Dados
end usb_fake;

architecture behavioral of usb_fake is

  type uint_file_type is file of integer;
  file input_file: uint_file_type open read_mode is INPUT_FILE_NAME;

  signal rdata  : reg32 := (others => '0'); -- Registrador para pixel lido

  type estado_tipo is (reset, readFile, waitDMA, T0, T1, T2, T3);
  signal estado : estado_tipo;

begin

  -- Máquina de Estados para leitura e transferência
	U_me: process (clk, rst)
	begin
		if rst = '0' then
			estado <= reset;
		elsif (rising_edge(clk)) then
			case estado is
				when reset =>
						estado <= readFile;
				when readFile =>
						estado <= waitDMA;
				when waitDMA =>
					if usb_rd_n = '0' then
						estado <= T0;
					else
						estado <= waitDMA;
					end if;
				when T0 =>
						estado <= T1;
				when T1 =>
						estado <= T2;
				when T2 =>
						estado <= T3;
				when T3 =>
              estado <= readFile;
			end case;
		end if;
	end process U_me;

  U_usb : process (clk)
    variable datum : integer := 0;
  begin
    if (rising_edge(clk)) then
		  case estado is
			  when reset =>
					  -- do nothing;
			  when readFile =>
          if not endfile(input_file) then
              read( input_file, datum );
              rdata <= std_logic_vector(to_signed(datum, 32));
              usb_rfx_n <= '0';
          end if; 
			  when waitDMA =>
            -- do nothing
			  when T0 =>
            data <= rdata(7 downto 0);
			  when T1 =>
            data <= rdata(15 downto 8);
			  when T2 =>
            data <= rdata(23 downto 16);
			  when T3 =>
            data <= rdata(31 downto 24);
            usb_rfx_n <= '1';
		  end case;
    end if;
  end process U_usb;

end behavioral;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DMA_USB module for cMIPS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity dma_usb_module is
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
end dma_usb_module;

architecture behavioral of dma_usb_module is

  component usb_fake is
    generic (INPUT_FILE_NAME : string := "img.data");
    port (rst       : in  std_logic;
          clk       : in  std_logic;
	        usb_rd_n  : in  std_logic;	-- Sinal de leitura de dados    -- act = '0'
          usb_rfx_n : out std_logic;	-- Sinal de "dados disponíveis" -- act = '0'
          data      : out reg8);      -- Dados
  end component usb_fake;

  component dma_usb is
    port (rst       : in  std_logic;
          clk       : in  std_logic;
          phi1      : in  std_logic;
          -- USB
	        usb_rd_n  : out std_logic;	-- Sinal de leitura de dados    -- act = '0'
          usb_rfx_n : in  std_logic;	-- Sinal de "dados disponíveis" -- act = '0'
          data      : in  reg8;       -- Dados
          -- RAM
          sel_ram   : out std_logic;
          rdy_ram   : in  std_logic;
          wr_ram    : out std_logic;
          addr_ram  : out reg32;
          data_ram  : out reg32;
          b_sel_ram : out reg4;
          -- cMIPS
  		    c_sel 	   : in  std_logic;	  -- Sinal de seleção
	  	    c_data_in  : in  reg32;		    -- Dados para gravação / endereço inicial
	  	    c_data_out : out reg32;		    -- Dados de leitura / imagem completamente gravada
          c_addr     : in  reg32;
	  	    c_we 	     : in  std_logic;		-- Sinal de gravação (=1) ou leitura (=0)
	  	    c_rdy 	   : out std_logic 		-- iwait
        );
  end component dma_usb;

  component muxram_dcache_dma is
    port(
      -- DMA_USB
      mem_d_sel_dma  : in  std_logic;
      ram_rdy_dma    : out std_logic;
      mem_wr_dma     : in  std_logic;
      mem_addr_dma   : in  reg32;
      datram_in_dma  : out reg32;
      datram_out_dma : in  reg32;
      mem_xfer_dma   : in  reg4;
      -- DCACHE
      mem_d_sel_dcache  : in  std_logic;
      ram_rdy_dcache    : out std_logic;
      mem_wr_dcache     : in  std_logic;
      mem_addr_dcache   : in  reg32;
      datram_in_dcache  : out reg32;
      datram_out_dcache : in  reg32;
      mem_xfer_dcache   : in  reg4;   
      -- RAM
      mem_d_sel_ram  : out std_logic;
      ram_rdy_ram    : in  std_logic;
      mem_wr_ram     : out std_logic;
      mem_addr_ram   : out reg32;
      datram_in_ram  : in  reg32;
      datram_out_ram : out reg32;
      mem_xfer_ram   : out reg4
    );
  end component muxram_dcache_dma;

  -- FT245R
  signal s_usb_rd_n  : std_logic;
  signal s_usb_rfx_n : std_logic;
  signal s_data      : reg8;

  -- DMA_USB to RAM
  signal mem_d_sel_dma, ram_rdy_dma, mem_wr_dma, dump_ram_dma : std_logic;
  signal mem_addr_dma, datram_in_dma, datram_out_dma : reg32;
  signal mem_xfer_dma : reg4;

begin

  -- FT245R
  U_usb_fake : usb_fake
    port map( rst, clk, s_usb_rd_n, s_usb_rfx_n, s_data);

  -- DMA_SUB
  U_dma_usb : dma_usb
    port map (rst, clk, phi1, 
              s_usb_rd_n, s_usb_rfx_n, s_data,  -- usb_fake
              mem_d_sel_dma, ram_rdy_dma, mem_wr_dma, mem_addr_dma, datram_in_dma, mem_xfer_dma, -- para RAM/MUX
              dma_sel, dma_data_in, dma_data_out, dma_addr, dma_we, dma_rdy -- Portas do cMIPS
    );

  -- MUX DMA vs DCACHE
  U_muxram : muxram_dcache_dma
    port map( mem_d_sel_dma,    ram_rdy_dma,    mem_wr_dma,    mem_addr_dma,    datram_out_dma, datram_in_dma,    mem_xfer_dma,
              sel_dcache, rdy_dcache, wr_dcache, addr_dcache, datdcache_in,  datdcache_out, b_sel_dcache,
              sel_ram,    rdy_ram,    wr_ram,    addr_ram,    datram_out,     datram_in,    xfer_ram  -- portas para RAM
    );

end behavioral;
