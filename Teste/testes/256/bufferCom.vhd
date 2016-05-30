-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Package para CircularBuffer
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;
library std;


package p_cb is

--  constant t_clock_period : time := 50 ns; -- trocado por CLOCK_PER de p_WIRES

  constant NUM_WORDS_CB   : integer := 256;  -- Height of CircularBuffer
  constant NUM_LINES_ADDR : integer := integer(floor(log2(real(NUM_WORDS_CB))));
  constant SIZE_WORDS_CB  : integer := 32; -- Width of each word in CircularBuffer
 
  subtype regLine  is std_logic_vector((NUM_LINES_ADDR - 1) downto 0);

end p_cb;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Dual-port RAM for CommunicationBuffer of Xeam
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee;
use ieee.std_logic_1164.all;
use work.p_WIRES.all;
use work.p_cb.all; 

entity ram_dualBCD is
  generic (N_WORDS : integer := NUM_WORDS_CB);
  port (
    data  : in reg32;
    raddr : in natural range 0 to N_WORDS - 1;	-- read address
    waddr : in natural range 0 to N_WORDS - 1;	-- write address
    we	  : in std_logic;
    rclk  : in std_logic;
    wclk  : in std_logic;
    rd	  : in std_logic;
    q	    : out reg32
    );
end ram_dualBCD;

architecture rtl of ram_dualBCD is

  -- Build a 2-D array type for the RAM
  subtype word_t    is reg32;
  type    memory_t  is array(N_WORDS - 1 downto 0) of word_t;
  
  -- Declare the RAM signal.
  signal ram : memory_t;

begin

  process(wclk)
  begin
    if(rising_edge(wclk)) then 
      if(we = '0') then
        assert false report "BCD_write["&SLV32HEX(data)&"]";
        ram(waddr) <= data;
      end if;
    end if;
  end process;
	
  process(rclk)
  begin
    if(rising_edge(rclk)) then
      if(rd = '0') then
        assert false report "BCD_read ["&SLV32HEX(ram(raddr))&"]";
        q <= ram(raddr);
      end if;
    end if;
  end process;
  
end rtl;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Buffer de Comunicação de Dados -> BCD
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.p_WIRES.all;
use work.p_cb.all;

entity circularBuffer is
	port (
		clk	  : in std_logic;
    clk4x : in std_logic;
		rst   : in std_logic;
		-- cLupaWrite
		w_sel 	  : in  std_logic;	-- Sinal de seleção
		w_data_in : in  reg32;		  -- Dados para gravação
		w_we 	    : in  std_logic;		-- Sinal de gravação (=1) ou leitura de estado (=0)
		w_out_st  : out reg32;			  -- Dados de estado (capacidade restante)
		w_rdy 	  : out std_logic;		-- iwait
		-- cLUPARead
		r_sel 	  : in std_logic;	-- Sinal de seleção
    r_addr    : in  reg32;         -- Endereço para leitura de dados ou estado
		r_out	    : out reg32;			  -- Dados de estado (palavras)
		r_rdy 	  : out std_logic		  -- iwait
	);
end entity;

architecture behavior of circularBuffer is

  -- Memória dual-port
  component ram_dualBCD is
  generic (N_WORDS : integer := NUM_WORDS_CB);
  port (
    data  : in reg32;
    raddr : in natural range 0 to N_WORDS - 1;	-- read address
    waddr : in natural range 0 to N_WORDS - 1;	-- write address
    we	  : in std_logic;
    rclk  : in std_logic;
    wclk  : in std_logic;
    rd	  : in std_logic;
    q	    : out reg32);
  end component;

  -- Contador de endereços
  component counterAddrNat is
    generic (INITIAL_VALUE: regLine := (others => '0'));
    port(clk, rst, en: in   std_logic;
          Q:           out  natural range 0 to NUM_WORDS_CB - 1);
  end component;

  -- Contador de palavras
  component counterUD is
    generic (INITIAL_VALUE: reg32 := (others => '0'));
    port(clk, rst, inc, en: in  std_logic;
          Q:                out reg32);
  end component;

	-- Contador de PHIs
  component count4phases is
    generic (CNT_LATENCY: time := 3 ns);
    port(clk, rst    : in  std_logic;
         p0,p1,p2,p3 : out std_logic);
--    attribute ASYNC_SET_RESET of rst : signal is true;
--    attribute CLOCK_SIGNAL of clk : signal is "yes";
  end component;

  -- Sinais genéricos
  signal base_clk, base_clk4x, base_rst : std_logic;
  signal gs_counter2b                   : reg2;

	signal wc_en : std_logic;

  -- Sinais de gravação (Xeam Zoom)
  signal ws_sel, ws_we1, ws_we2 : std_logic;
  signal ws_d_in, ws_d_out      : reg32;
  signal ws_canw_addr           : natural range 0 to (NUM_WORDS_CB - 1);
  signal base_phi1, base_phi2   : std_logic; 
  signal base_phi3, base_phi4   : std_logic;
	signal ws_wc_inc							: std_logic;
	signal ws_wc_word							: reg32;
	signal ws_i_wait							: std_logic;

  -- Sinais de leitura (Xeam Contraste)
  signal rs_sel       : std_logic;
  signal rs_addr      : reg32;
  signal rs_cout      : reg32;
  signal rs_rd        : std_logic;
  signal rs_canr_addr : natural range 0 to (NUM_WORDS_CB - 1);
  signal rs_d_outA    : reg32;
  signal rs_d_outB    : reg32;
  signal rs_sm        : std_logic;
  signal rs_canr_en   : std_logic;
	signal rs_wc_inc		: std_logic;
	signal rs_wc_word		: reg32;
	signal rs_i_wait		: std_logic;

begin

  -- Conponentes genéricos -----------------------------------------------------
  -- Contador de fases clk4x
  U_CPHI : count4phases
    port map(
      clk => base_clk4x,
      rst => base_rst,
      p0  => base_phi1,
      p1  => base_phi2,
      p2  => base_phi3,
      p3  => base_phi4
    );

	-- Sinais genéricos
	wc_en <= '1' when (
		( ws_sel = '0' and ws_we1 = '0' and rs_sel = '0' and rs_sm = '0') or 
		((ws_sel = '1' or ws_we1 = '1') and (rs_sel = '1'  or rs_sm = '1'))
		) else '0';

	base_clk 	 <= clk;
	base_clk4x <= clk4x;
	base_rst 	 <= rst;

  -- Memória dual-port
  U_RAM : ram_dualBCD 
  port map(
    data  => ws_d_in,
    raddr => rs_canr_addr,
    waddr => ws_canw_addr,
    we	  => ws_we2,
    rclk  => base_phi3,
    wclk  => base_phi4,
    rd	  => rs_rd,
    q	  	=> rs_d_outA
  );

  -- Componentes WRITE ---------------------------------------------------------
  -- Componente contador de endereços natural
  U_CANW : counterAddrNat
  port map(
    clk => base_phi4,
    rst => base_rst,
    en  => ws_we2,
    Q   => ws_canw_addr
  );
  
	-- Componente INC/DEC status
	U_WordCW : counterUD
	generic map(INITIAL_VALUE => (std_logic_vector(to_unsigned(NUM_WORDS_CB,SIZE_WORDS_CB))))
	port map(
		clk	=> base_phi3,
		rst	=> base_rst,
		inc	=> ws_wc_inc,
		en	=> wc_en,
		Q 	=> ws_wc_word
	);

	-- Sinais combinacionais
  ws_d_in <= w_data_in;

  ws_sel <= w_sel;
  ws_we1 <= w_we;
  ws_we2 <= '0' when (ws_we1 = '0' and ws_sel = '0' ) else '1';
  
	ws_wc_inc <= '1' when (w_sel = '1' or ws_we1 = '1') else '0';	
	w_out_st  <= ws_wc_word;
	
	ws_i_wait <= '0' when (ws_sel = '0' and base_phi2 = '1') else '1';
	w_rdy     <= ws_i_wait;

	w_out_st  <= ws_wc_word;
--	w_out_st  <= ws_wc_word when (ws_sel = '0' and ws_we1 = '1') else (others => 'Z');

  -- Componentes READ ----------------------------------------------------------
  -- Componente contador de endereços natural
  U_CANR : counterAddrNat
  port map(
    clk => base_phi3,
    rst => base_rst,
    en  => rs_rd,
    Q   => rs_canr_addr
  );
  
	-- Componente INC/DEC status
	U_WordCR : counterUD
	generic map(INITIAL_VALUE => (others => '0'))
	port map(
		clk	=> base_phi3,
		rst	=> base_rst,
		inc	=> rs_wc_inc,
		en	=> wc_en,
		Q 	=> rs_wc_word
	);

	-- Sinais combinacionais
  rs_sel     <= r_sel;
  rs_addr    <= r_addr;
  rs_rd      <= '0' when (rs_sel = '0' and rs_sm = '0' ) else '1';
  rs_sm      <= r_addr(2);
  rs_d_outB  <= rs_d_outA when (rs_sm = '0') else rs_cout;
  r_out 		 <= rs_d_outB;

	rs_wc_inc <= '1' when (w_sel = '0' and ws_we1 = '0') else '0';
	rs_cout   <= rs_wc_word;

	rs_i_wait <= '0' when (rs_sel = '0' and base_phi2 = '1') else '1';
	r_rdy 	  <= rs_i_wait;

	r_out <= rs_d_outB;
--	r_out <= rs_d_outB when (rs_sel = '0') else (others => 'Z');
end architecture;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- log2(NUM_WORDS_CB)bits UP counter, {load,enable} synchronous, active in '0'
-- Address counter for read/write for Xeam circularBuffer
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_WIRES.all;
use work.p_cb.all; 

entity counterAddrNat is
  generic (INITIAL_VALUE: regLine := (others => '0'));
  port(clk, rst, en: in  std_logic;
        Q:           out  natural range 0 to (NUM_WORDS_CB - 1));
  attribute ASYNC_SET_RESET of rst : signal is true;
end counterAddrNat;

architecture functional of counterAddrNat is
  signal count: regLine := INITIAL_VALUE;
begin

  process(clk, rst)
  begin
    if rst = '0' then
      count <= INITIAL_VALUE;
    elsif rising_edge(clk) then
      if en = '0' then 
        count <= std_logic_vector(unsigned(count) + 1);
      end if;
    end if;
  end process;

  Q <= to_integer(unsigned(count));

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- log2(NUM_WORDS_CB)bits UP/DOWN counter, {inc/dec,enable} synchronous, active in '0'
-- counter words left|available for Xeam circularBuffer
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_WIRES.all;
use work.p_cb.all; 

entity counterUD is
  generic (INITIAL_VALUE: reg32 := (others => '0'));
  port(clk, rst, inc, en: in  std_logic;
        Q:                out reg32);
  attribute ASYNC_SET_RESET of rst : signal is true;
end counterUD;

architecture functional of counterUD is
  signal count: reg32 := INITIAL_VALUE;
begin

  process(clk, rst)
  begin
    if rst = '0' then
      count <= INITIAL_VALUE;
    elsif rising_edge(clk) then
      if en = '0' then 
	      if inc = '1' then
	        count <= std_logic_vector(unsigned(count) + 1);
	      else
	        count <= std_logic_vector(unsigned(count) - 1);
	      end if;	-- inc = '0'
      end if; 	-- en  = '0'
    end if; 	-- rst = '0'
  end process;

  Q <= count;

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ring-counter, generates four-phase internal clock, on falling-edge
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_WIRES.all;
entity count4phases is
  generic (CNT_LATENCY: time := 3 ns);
  port(clk, rst    : in  std_logic;
       p0,p1,p2,p3 : out std_logic);
  attribute ASYNC_SET_RESET of rst : signal is true;
  attribute CLOCK_SIGNAL of clk : signal is "yes";
end count4phases;

architecture functional of count4phases is
  signal count: reg4 := b"1000";
begin

  process(clk, rst)
  begin
    if rst = '0' then
      count <= b"1000";
    elsif falling_edge(clk) then
      count <= count(2 downto 0) & count(3);
    end if;
  end process;

  p0 <= count(0);
  p1 <= count(1);
  p2 <= count(2);
  p3 <= count(3);

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- log2(NUM_WORDS_CB)bits UP counter, {load,enable} synchronous, active in '0'
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_WIRES.all;
use work.p_cb.all; 

entity counterAddr is
  generic (INITIAL_VALUE: regLine := (others => '0'));
  port(clk, rst, ld, en: in  std_logic;
        D:               in  regLine;
        Q:               out regLine);
  attribute ASYNC_SET_RESET of rst : signal is true;
end counterAddr;

architecture functional of counterAddr is
  signal count: regLine := INITIAL_VALUE;
begin

  process(clk, rst)
  begin
    if rst = '0' then
      count <= INITIAL_VALUE;
    elsif rising_edge(clk) then
      if ld = '0' then 
        count <= D;
      elsif en = '0' then
        count <= std_logic_vector(unsigned(count) + 1);
      end if;
    end if;
  end process;

  Q <= count;

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 32-bit UP/DOWN counter, {inc/dec,enable} synchronous, active in '0'
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_WIRES.all;

entity counter32id is
  generic (INITIAL_VALUE: reg32 := x"00000000");
  port(clk, rst, inc, en: in  std_logic;
        Q:                out reg32);
  attribute ASYNC_SET_RESET of rst : signal is true;
end counter32id;

architecture functional of counter32id is
  signal count: reg32;
begin

  process(clk, rst)
  begin
    if rst = '0' then
      count <= INITIAL_VALUE;
    elsif rising_edge(clk) then
      if en = '0' then 
	if inc = '1' then
	  count <= std_logic_vector(unsigned(count) + 1);
	else
	  count <= std_logic_vector(unsigned(count) - 1);
	end if;	-- inc = '0'
      end if; 	-- en  = '0'
    end if; 	-- rst = '0'
  end process;

  Q <= count;

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
