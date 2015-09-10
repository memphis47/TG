--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- File contains all 4 necessary modules for emulated-dma-usb
-- Module: dma_usb, usb_fake, muxram_dcache_dma and usb-module for cMIPS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- VGA
-- peripheral: vga
-- operation: Receive 3 components (bytes) RGB from modulo_VGA and write an output file
--    Needs a vga controller module
--    Result a file called vga.data 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.NUMERIC_STD.all;
use std.textio.all;
use work.p_wires.all;

entity vga is

	Generic(
		CLOCK_PERIOD     : integer := 20  --ns, periodo do CLOCK_50MHz_i em ns (50MHz)
	);
   port( 
      signal CLOCK_50MHz_i : in std_logic; 
      signal phi2          : in std_logic; -- não existe em vga real, usado apenas para escrever em arquivo
      signal closeFile     : in std_logic; -- não existe em vga real, usado apenas para fechar o arquivo  > '1' fecha e encerra
      signal R_in          : in reg8;
      signal G_in          : in reg8;
      signal B_in          : in reg8;
      signal A_in          : in reg8;
			signal VGA_HS_i      : in std_logic;   -- VGA_controlador; indica nova linha
      signal VGA_VS_i      : in std_logic);  -- VGA_controlador; indica novo frame
end vga;

architecture behavior of vga is

  type estado_tipo is (reset, clk1, clk2);
  signal estado : estado_tipo;

  type uint_file_type is file of integer;
  file output_file: uint_file_type open write_mode is "vga.data";

  signal wr : std_logic := '0'; -- '0' > não escreve em arquivo
                                -- '1' >     escreve em arquivo

  signal pixel : reg32;
  signal jmp   : std_logic := '1';  -- pula 1 ciclo de clock para evitar escrita dupla

begin

  pixel(31 downto 24) <= R_in;
  pixel(23 downto 16) <= G_in;
  pixel(15 downto  8) <= B_in;
  pixel( 7 downto  0) <= A_in;

  U_manager_vga : process (VGA_HS_i, VGA_VS_i)
  begin

    if (VGA_VS_i = '1' and VGA_HS_i = '1') then
      wr <= '1';
    else
      wr <= '0';
    end if;

  end process U_manager_vga;

  U_write_file : process(CLOCK_50Mhz_i, wr, phi2)
  begin

  if(CLOCK_50Mhz_i = '0') then
    if (wr = '1' and falling_edge(phi2) and closeFile = '0' and jmp = '0') then
      -- escreve no arquivo
        write( output_file, to_integer(signed(pixel)) );
        jmp <= '1';
    else
      if (closeFile = '1') then
      -- fecha arquivo
      file_close(output_file);
      assert false report "DMA_VGA_transfer: File Closed";
      end if;
      if (wr = '1' and falling_edge(phi2) and jmp = '1') then
        jmp <= '0';
      end if;
    end if; -- wr = 1 and falling_edge(phi1) / closeFile = '1'

  end if; -- CLOCK_50Mhz_i = '1'

  end process U_write_file;

  -- DEBUG
  U_dbg_state : process (CLOCK_50Mhz_i)
  begin
    if wr = '0' then
			estado <= reset;
		elsif (rising_edge(CLOCK_50Mhz_i)) then
      case estado is
      when reset => estado <= clk1;
      when clk1 => estado <= clk2;
      when clk2 => estado <= clk1;
      end case;
    end if;
  end process U_dbg_state;

end architecture behavior;


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--	Controlador VGA (Adaptado do site: http://fpgaparatodos.com.br)
--	Este componente faz o controle dos sinais necessários para a operaçao
-- da interface VGA.
--
-- PS: As unidades de tempo utilizadas no projeto para fins de calculo estão todas na escala de ns
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.NUMERIC_STD.all;
-- Alterado para remoção da lib IEEE.STD_LOGIC_UNSIGNED - 21/11/2014
--use  IEEE.STD_LOGIC_UNSIGNED.all;


entity VGA_controlador is

	Generic(
		CLOCK_PERIOD : integer := 20  --ns, periodo do CLOCK_50MHz_i em ns (50MHz)
	);
   port( 
      signal CLOCK_50MHz_i : in std_logic; 
      signal reset_n_i     : in std_logic;
			signal video_on_o    : out std_logic;
			signal pixels_o      :out std_logic_vector(10 downto 0);
      signal Linha_o       : out std_logic_vector(10 downto 0);
			signal VGA_HS_o      : out std_logic;   -- VGA
      signal VGA_VS_o      : out std_logic);  -- VGA
end VGA_controlador;

architecture comportamento of VGA_controlador is
	
	constant H_max : std_logic_vector(10 Downto 0) := std_logic_vector(to_unsigned((31770/CLOCK_PERIOD),11)); -- dividir pelo periodo é o mesmo que multiplicar pela frequencia. 
	--valor máximo da variável cont_x, valor encontrado a partir da analise dos tempos do sincronismo horizontal
	-- 31,77us periodo para varrer uma Linha_o
	constant V_max : std_logic_vector(10 Downto 0) := std_logic_vector(to_unsigned((16770000/31770),11));   	-- vertical só incrementado no fim de uma Linha_o 
	--valor maximo da variável cont_y, valor encontrado a partir da analise dos tempos do sincronismo vertical
	-- 16,77ms periodo para varrer a tela 
	constant COLUMNS : std_logic_vector(10 Downto 0) := std_logic_vector(to_unsigned(640,11));
	constant LINES : std_logic_vector(10 Downto 0) := std_logic_vector(to_unsigned(480,11));
	
	signal cont_x,cont_y: std_logic_vector(10 Downto 0);
	signal RESET : std_logic;

	signal video_on_H, video_on_V: std_logic;

  signal s_um : std_logic_vector(10 downto 0) := "00000000001";

begin           

	RESET <= NOT(reset_n_i);
	video_on_o <= video_on_H and video_on_V;

	--Generate Horizontal and Vertical Timing Signals for Video Signal
	VIDEO_DISPLAY: Process (CLOCK_50MHz_i, reset)
		Begin
		if RESET = '1' then
			cont_x <= std_logic_vector(to_unsigned(0,11));
			cont_y <= std_logic_vector(to_unsigned(0,11));
			Video_on_H <= '0';
			Video_on_V <= '0';
			VGA_HS_o <= '0';
			VGA_VS_o <= '0';
		elsif rising_edge (CLOCK_50MHz_i) then
				pixels_o <= "0" & cont_x(10 downto 1); 
				-- cont_x é utilizado para descartar o último bit para dividir por 2 a frequencia
            -- De forma com que o Clock seja semelhante ao do monitor.
				Linha_o 	<= cont_y;
				
				-- cont_x conta os pixels_o (espaço utilizado+espaço nao utilizado+tempo extra para o sinal de sincronismo)
				--
				--  Contagem de pixels_o:
				--   												  <-H Sync->
				--   ------------------------------------__________
				--   0        									  1400     


				 If (cont_x >= H_max) then
					cont_x <= "00000000000";
				 Else
					cont_x <= std_logic_vector(unsigned(cont_x) + unsigned(s_um)); --"00000000001";
				 End if;

				-- O VGA_HS_o deve permanecer em nível lógico alto por 26,11 us
				-- então em baixo por 3,77 us
				
				
--				 If  (unsigned(cont_x) >= (26110/CLOCK_PERIOD)) and (unsigned(cont_x) <= (27060 + 3770)/CLOCK_PERIOD) Then
				 If  (unsigned(cont_x) >= (25650/CLOCK_PERIOD)) and (unsigned(cont_x) <= (28000 + 3770)/CLOCK_PERIOD) Then
						VGA_HS_o <= '0';
				 ELSE
						VGA_HS_o <= '1';
				 End if;
				 
				-- Ajusta o tempo do Video_on_H
				-- video_on_H é 0 entre 25,17us até 31,77us (Periodo)
				
--				 If (unsigned(cont_x) <= (25170/CLOCK_PERIOD)) Then
				 If (unsigned(cont_x) <= (25629/CLOCK_PERIOD)) Then    
					video_on_H <= '1';
				 ELSE
					video_on_H <= '0';
				 End if;

				--  Contagem de linhas...
				--	 Linha_o conta as linhas de pixels_o (127 + tempo extra para sinais de sincronismo)
				--
				--  <-- 				linhas utilizadas				-->  ->V Sync<-
				--  -----------------------------------------------_______------------
				--  0                          			            495-494         528

				 If (unsigned(cont_y) >= unsigned(V_max)) and (unsigned(cont_x) >= 736) then
						cont_y <= "00000000000";
				 Elsif (cont_x = H_Max) Then
						  cont_y <= std_logic_vector(unsigned(cont_y) + unsigned(s_um));
				 End if;

				-- Generate Vertical Sync Signal (15,700ms até 15,764ms VGA_VS_o= '0')
--				 If (unsigned(cont_y) >= (15700000/31770)) and (unsigned(cont_y) <= (15764000/31770)) Then  
				 If (unsigned(cont_y) >= (15286840/31770)) and (unsigned(cont_y) <= (16754000/31770)) Then  
					VGA_VS_o <= '0';
				 ELSE
					VGA_VS_o <= '1';
				 End if;
				 
				-- Ajusta o tempo do Video_on_V
				If (unsigned(cont_y) <= (15250000/31770)) Then
					video_on_V <= '1';
				ELSE
					video_on_V <= '0';
				End if;
				
			End if;
			
		end process VIDEO_DISPLAY;

end comportamento;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DMA to RAM -> VGA
-- peripheral: dma_vga
-- operation: Reads 4 bytes from RAM and send to VGA
-- The transaction begins with a starter address from cMIPS
--    Each aditional transactions needs a starter address from cMIPS 
--    (can be the same initial address) 
-- cMIPS can read the current address, returns -1 when transactions are ended
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;

entity dma_vga is
  port (rst       : in  std_logic;
        clk       : in  std_logic;
        phi0      : in  std_logic;
        phi1      : in  std_logic;
        phi2      : in  std_logic;
        -- RAM
        sel_ram   : out std_logic;
        rdy_ram   : in  std_logic;
        wr_ram    : out std_logic;
        addr_ram  : out reg32;
        data_ram  : in  reg32;
        b_sel_ram : out reg4;
        -- cMIPS
		    c_sel 	   : in  std_logic;	  -- Sinal de seleção
		    c_data_in  : in  reg32;		    -- Dados para gravação / endereço inicial
		    c_data_out : out reg32;		    -- Dados de leitura / imagem completamente gravada
        c_addr     : in  reg32;
		    c_we 	     : in  std_logic;		-- Sinal de gravação (=1) ou leitura (=0)
		    c_rdy 	   : out std_logic 		-- iwait
          );
end dma_vga;

architecture behavioral of dma_vga is

  component VGA_controlador is
   port( 
      CLOCK_50MHz_i : in std_logic; 
      reset_n_i     : in std_logic;
			video_on_o    : out std_logic;
			pixels_o      :out std_logic_vector(10 downto 0);
      Linha_o       : out std_logic_vector(10 downto 0);
			VGA_HS_o      : out std_logic;   -- VGA
      VGA_VS_o      : out std_logic);  -- VGA
  end component VGA_controlador;

  component vga is
   port( 
      CLOCK_50MHz_i : in std_logic; 
      phi2          : in std_logic; -- não existe em vga real, usado apenas para escrever em arquivo
      closeFile     : in std_logic; -- não existe em vga real, usado apenas para fechar o arquivo  > '1' fecha e encerra
      R_in          : in reg8;
      G_in          : in reg8;
      B_in          : in reg8;
      A_in          : in reg8;
			VGA_HS_i      : in std_logic;   -- VGA_controlador; indica nova linha
      VGA_VS_i      : in std_logic);  -- VGA_controlador; indica novo frame
  end component vga;

  signal s_rst_interno : std_logic := '0';
  signal s_video_o : std_logic;
  signal s_pixel, s_linha : std_logic_vector(10 downto 0);
  signal s_VGA_HS, s_VGA_VS : std_logic;
  signal s_VGA_H,  s_VGA_V  : std_logic;
  signal s_VGA_HF, s_VGA_VF : std_logic; -- fake signal

  signal s_closeFile : std_logic := '0';
  signal s_r, s_g, s_b, s_a : reg8;

  signal initBycMips : std_logic; -- initBycMips = '0' = cMIPS não iniciou processo
                                  -- initBycMips = '1' = cMIPS     iniciou processo

  signal init : std_logic;

  signal sel_ram_internal : std_logic := '1';
  signal s_b_sel_ram        : reg4    := x"F";
  signal s_addr_ram         : reg32   := x"00000000";
  signal s_addr_ram_inicial : reg32   := x"00000000";
  signal s_addr_ram_size    : reg32   := x"00000000";
  signal s_addr_ram_final   : reg32   := x"00000000";

  type estado_tipo_rcv is (reset, waitcMIPS, leituraP1, leituraP2, escrita, leitura, fim);
  signal estado_rcv : estado_tipo_rcv;

  signal data     : reg32 := (others => '1');
  signal fakeData : reg32 := (others => '1'); -- pixel branco

begin
  sel_ram <= sel_ram_internal;

  U_vga_controler : VGA_controlador
    port map( clk, s_rst_interno, 
              s_video_o, s_pixel, s_linha, s_VGA_HS, s_VGA_VS);

  U_vga : vga
    port map( clk, phi2, s_closeFile, 
              s_r, s_g, s_b, s_a, s_VGA_HF, s_VGA_VF);

  -- ME Leitura de memória
	U_rcv_me: process (clk, rst)
	begin
    if rst = '0' then
			estado_rcv <= reset;
		elsif (rising_edge(clk)) then
      case estado_rcv is
        when reset =>
          estado_rcv <= waitcMIPS;
        when waitcMIPS =>
            if initBycMips = '0' then 
              estado_rcv <= waitcMIPS;
            else
              estado_rcv <= leituraP1;
            end if;
        when leituraP1 =>
            estado_rcv <= leituraP2;
        when leituraP2 =>
            estado_rcv <= escrita;
        when escrita =>
            if initBycMips = '1' then
              estado_rcv <= leitura;
            else
              estado_rcv <= fim;
            end if;
        when leitura =>
            estado_rcv <= escrita;
        when fim =>
            estado_rcv <= waitcMIPS;
      end case;
    end if;
  end process U_rcv_me;

  U_rcv : process (clk, rst)
  begin
    if (rising_edge(clk)) then
      case estado_rcv is
        when reset =>
            s_addr_ram <= (others => '0');
            s_addr_ram_final <= (others => '0');
            s_VGA_HF <= '0';
            s_VGA_VF <= '0';
        when waitcMIPS =>
            s_addr_ram <= s_addr_ram_inicial;
            s_addr_ram_final <= std_logic_vector(unsigned(s_addr_ram_inicial) + unsigned(s_addr_ram_size));
            addr_ram <= s_addr_ram;
        when leiturap1 =>
            sel_ram_internal <= '0';
            s_addr_ram <= std_logic_vector(unsigned(s_addr_ram) + 4); 
        when leituraP2 =>
            addr_ram  <= s_addr_ram;
            sel_ram_internal <= '1';
            s_VGA_HF <= '1';
            s_VGA_VF <= '1';
        when escrita =>
            sel_ram_internal <= '0';
--            assert false report "DMA_VGA_transfer_ADDR["&SLV32HEX(s_addr_ram)&"]";
            s_addr_ram <= std_logic_vector(unsigned(s_addr_ram) + 4);
        when leitura =>
            addr_ram  <= s_addr_ram;
            sel_ram_internal <= '1';
        when fim =>
            sel_ram_internal <= '1';
            s_VGA_HF <= '0';
            s_VGA_VF <= '0';
      end case;
    end if; -- rising_edge(clk)
  end process U_rcv;

  -- CMIPS
  -- Escrita de endereço inicial e # bytes a ser transferido (por cMIPS)
  s_addr_ram_inicial <= c_data_in when (c_sel = '0' and c_we = '0' and c_addr(2) = '0' and c_addr(3) = '0' and falling_edge(phi1));
  s_addr_ram_size    <= c_data_in when (c_sel = '0' and c_we = '0' and c_addr(2) = '1' and c_addr(3) = '0' and falling_edge(phi1));
  -- Inicialização
  init  <= '1' when (c_sel = '0' and c_we = '0' and c_addr(3) = '1' and c_addr(2) = '0') else '0';

  c_rdy <= '0' when (c_sel = '0' and phi1 = '1') else '1';

  -- closeFile
  s_closeFile <= '1' when (c_sel = '0' and c_we = '1' and c_addr(3) = '1' and c_addr(2) = '1') else '0';

  -- Leitura do pixel da RAM
  data <= data_ram when (sel_ram_internal = '0' and rdy_ram = '1' and falling_edge(phi2));-- else fakeData;

  s_r <= data(31 downto 24);
  s_g <= data(23 downto 16);
  s_b <= data(15 downto  8);
  s_a <= data( 7 downto  0);

  -- Leitura de initBycMIPS (por cMIPS)
  c_data_out(31 downto 4) <= x"0000000";
  c_data_out( 3 downto 1) <= b"000";
  c_data_out(0) <= initBycMips;

  b_sel_ram <= s_b_sel_ram;
  wr_ram <= '1';

  U_manager_dma: process(clk)
  begin
		if rst = '0' then
			initBycMips <= '0';
		elsif (rising_edge(clk)) then
      if init = '1' then
        if initBycMips = '0' then
          initBycMips <= '1';  
        end if;    
      elsif unsigned(s_addr_ram) >= (unsigned(s_addr_ram_final)) then
          initBycMips <= '0';
      end if; -- if init
    end if; -- if rst
  end process U_manager_dma;

  U_delay_rst: process(clk)
  begin
    if (rising_edge(clk)) then
		  if initBycMips = '0' then
          s_rst_interno <= '0';
      else
          s_rst_interno <= '1';
      end if; -- if iniBycMIPS
    end if;
  end process U_delay_rst;

  U_dma_times: process(initBycMips)
  begin

    if (rst = '1') then
      assert (initBycMips'event and initBycMips = '0') report "DMA_VGA_transfer: init";

--      assert (initBycMips'event and initBycMips = '0') report "DRAM_inicial["&SLV32HEX(s_addr_ram_inicial)&"]";
--      assert (initBycMips'event and initBycMips = '0') report "DRAM_size["&SLV32HEX(s_addr_ram_size)&"]";
--      assert (initBycMips'event and initBycMips = '0') report "DRAM_final["&SLV32HEX(s_addr_ram_final)&"]";

--      assert (s_addr_ram'event) report "Pixel_addr["&SLV32HEX(s_addr_ram)&"]";

      assert (initBycMips'event and initBycMips = '1') report "DMA_VGA_transfer: stop";

--      assert (s_addr_ram >= s_addr_ram_final) report "s_addr_ram >= s_addr_ram_final";

    end if; -- reset

  end process U_dma_times;

end architecture behavioral;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DMA to RAM > VGA
-- peripheral: dma_vga
-- operation: Reads 4 bytes from RAM and send to VGA
-- The transaction begins with a starter address from cMIPS
--    Each aditional transactions needs a starter address from cMIPS 
--    (can be the same initial address) 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;

entity dma_vga_module is
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
end entity dma_vga_module;

architecture behavioral of dma_vga_module is

  component dma_vga is
    port (rst       : in  std_logic;
          clk       : in  std_logic;
          phi0      : in  std_logic;
          phi1      : in  std_logic;
          phi2      : in  std_logic;
          -- RAM
          sel_ram   : out std_logic;
          rdy_ram   : in  std_logic;
          wr_ram    : out std_logic;
          addr_ram  : out reg32;
          data_ram  : in  reg32;
          b_sel_ram : out reg4;
          -- cMIPS
		      c_sel 	   : in  std_logic;	  -- Sinal de seleção
		      c_data_in  : in  reg32;		    -- Dados para gravação / endereço inicial
		      c_data_out : out reg32;		    -- Dados de leitura / imagem completamente gravada
          c_addr     : in  reg32;
		      c_we 	     : in  std_logic;		-- Sinal de gravação (=1) ou leitura (=0)
		      c_rdy 	   : out std_logic 		-- iwait
            );
  end component dma_vga;

  component muxram_dcache_dma is
    port(
      -- DMA
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

  -- DMA_USB to RAM
  signal mem_d_sel_dma, ram_rdy_dma, mem_wr_dma, dump_ram_dma : std_logic;
  signal mem_addr_dma, datram_in_dma, datram_out_dma : reg32;
  signal mem_xfer_dma : reg4;

begin

  U_dma_vga : dma_vga
    port map( rst, clk, phi0, phi1, phi2, 
              mem_d_sel_dma, ram_rdy_dma, mem_wr_dma, mem_addr_dma, datram_in_dma, mem_xfer_dma,
              dma_sel, dma_data_in, dma_data_out, dma_addr, dma_we, dma_rdy
    );

  -- MUX DMA vs DCACHE
  U_muxram : muxram_dcache_dma
    port map( mem_d_sel_dma, ram_rdy_dma, mem_wr_dma, mem_addr_dma, datram_in_dma, datram_out_dma, mem_xfer_dma,
              sel_dcache,    rdy_dcache,  wr_dcache,  addr_dcache,  datdcache_in,   datdcache_out, b_sel_dcache,
              sel_ram,       rdy_ram,     wr_ram,     addr_ram,     datram_out,     datram_in,     xfer_ram  -- portas para RAM
    );

end architecture behavioral;
