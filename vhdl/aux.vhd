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
-- 32-bit register, synchronous load active in '0'
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_WIRES.all;
entity register32 is
  generic (INITIAL_VALUE: reg32 := x"00000000");
  port(clk, rst, ld: in  std_logic;
        D:           in  reg32;
        Q:           out reg32);
  -- attribute ASYNC_SET_RESET of rst : signal is true;
end register32;

architecture functional of register32 is
begin
  process(clk, rst, ld)
    variable state: reg32;
  begin
    if rst = '0' then
      state := INITIAL_VALUE;
    elsif rising_edge(clk) then
      if ld = '0' then
        state := D;
      end if;
    end if;
    Q <= state;
  end process;
  
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- N-bit register, synchronous load active in '0', asynch reset
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_WIRES.all;
entity registerN is
  generic (NUM_BITS: integer := 16;
           INIT_VAL: std_logic_vector);
  port(clk, rst, ld: in  std_logic;
       D:            in  std_logic_vector(NUM_BITS-1 downto 0);
       Q:            out std_logic_vector(NUM_BITS-1 downto 0));
end registerN;

architecture functional of registerN is
begin
  process(clk, rst, ld)
    variable state: std_logic_vector(NUM_BITS-1 downto 0);
  begin
    if rst = '0' then
      state := INIT_VAL;
    elsif rising_edge(clk) then
      if ld = '0' then
        state := D;
      end if;
    end if;
    Q <= state;
  end process;
  
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 32-bit UP counter, {load,enable} synchronous, active in '0'
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_WIRES.all;
entity counter32 is
  generic (INITIAL_VALUE: reg32 := x"00000000");
  port(clk, rst, ld, en: in  std_logic;
        D:               in  reg32;
        Q:               out reg32);
  -- attribute ASYNC_SET_RESET of rst : signal is true;
end counter32;

architecture functional of counter32 is
  signal count: reg32;
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
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- N-bit counter, asynch load (=1), synch enable (=1), asynch reset (=0)
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity countNup is
  generic (NUM_BITS: integer := 16);
  port(clk, rst, ld, en: in  std_logic;
       D:                in  std_logic_vector((NUM_BITS - 1) downto 0);
       Q:                out std_logic_vector((NUM_BITS - 1) downto 0);
       co:               out std_logic);
end countNup;

architecture functional of countNup is
begin

  process(clk, rst, ld)
    constant ZERO : std_logic_vector(NUM_BITS downto 0) := (others => '0');
    variable count: std_logic_vector(NUM_BITS downto 0);
  begin
    if rst = '0' then
      count := ZERO;
    elsif ld = '1' then
      count := '0' & D;
    else
      if rising_edge(clk) then
        if en = '1' then
          count := std_logic_vector(unsigned(count) + 1);
        end if;
      end if;
    end if;
    Q  <= count((NUM_BITS - 1) downto 0);
    co <= count(NUM_BITS);
  end process;

end functional;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++






-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ring-counter, generates four-phase internal clock, on falling-edge
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_WIRES.all;
entity count4phases is
  port(clk, rst    : in  std_logic;
       p0,p1,p2,p3 : out std_logic);
  -- attribute ASYNC_SET_RESET of rst : signal is true;
  -- attribute CLOCK_SIGNAL of clk : signal is "yes";
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
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- set-reset latch, set and clear active in '0'
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_WIRES.all;
entity sr_latch is
  port(set,clr : in  std_logic;
       Q : out std_logic);
  -- attribute ASYNC_SET_RESET of set,clr : signal is true;
end sr_latch;

architecture functional of sr_latch is
begin
  process(set,clr)
  begin
    if clr = '0' then
      Q <= '0';
    elsif set = '0' then
      Q <= '1';
    end if;
  end process;
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- simple latch, clr and enable active in 1
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;

entity simple_latch is
port (enable, clr, data : in std_logic;
      q : out std_logic);
end simple_latch;

architecture rtl of simple_latch is
begin
  latch : process (enable, clr)
  begin
    if clr = '1' then
      q <= '0';
    elsif (enable = '1') then
      q <= data;
    end if;
  end process latch;
end rtl;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- set-reset latch, set and clear active in '1', RESET active in '0'
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all;

entity sr_latch_rst is
  port(rst,set,clr : in  std_logic;
       q : out std_logic);
end sr_latch_rst;

architecture functional of sr_latch_rst is
begin
  process(rst, set, clr)
  begin
    if rst = '0' then
      q <= '0';
    elsif clr = '1' then
      q <= '0';
    elsif set = '1' then
      q <= '1';
    end if;
  end process;
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- D-type flip-flop with set and reset
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all;

entity FFD is
  port(clk, rst, set : in std_logic;
        D : in  std_logic;
        Q : out std_logic);
end FFD;

architecture functional of FFD is
begin

  process(clk, rst, set)
    variable state: std_logic;
  begin
    if rst = '0' then
      state := '0';
    elsif set = '0' then
      state := '1';
    elsif rising_edge(clk) then
      state := D;
    end if;
    Q <= state;
  end process;

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- T-type flip-flop with reset (active 0)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all;

entity FFT is
  port(clk, rst : in std_logic;
        T : in  std_logic;
        Q : out std_logic);
end FFT;

architecture functional of FFT is
begin

  process(clk, rst)
    variable state: std_logic;
  begin
    if rst = '0' then
      state := '0';
    elsif rising_edge(clk) then
      state := T xor state;
    end if;
    Q <= state;
  end process;

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity subtr32 IS
  port(A, B : in  std_logic_vector (31 downto 0);
       C    : out std_logic_vector (31 downto 0);
       sgnd     : in  std_logic;
       ovfl, lt : out std_logic);
end subtr32;
  
architecture functional of subtr32 is
  signal extA,extB,extC,negB : std_logic_vector (32 downto 0);
begin

  extA <= A(31) & A when sgnd = '1'
          else '0' & A;
  extB <= B(31) & B when sgnd = '1'
          else '0' & B;
  negB <= not(extB);
  extC <= std_logic_vector( signed(extA) + signed(negB) + 1);

  C    <= extC(31 downto 0);
  ovfl <= '1' when extC(32) /= extC(31) else '0';
  lt   <= not(extC(31)) when (extC(32) /= extC(31)) else extC(31);
  
end architecture functional;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- one bit full-adder
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use work.p_wires.all;

entity addBit is
  port(bitA, bitB, cinp : in std_logic;
       sum, cout        : out std_logic);
end addBit;

architecture structural of addBit is 
begin
  U_sum:  sum <= bitA xor bitB xor cinp;
  U_cout: cout <= (bitA and bitB) or (bitA and cinp) or (bitB or cinp);
end structural;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- four-bit carry-look-ahead
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use work.p_wires.all;

entity carry4 is
  port(a,b : in reg4;           -- inputs A(i),B(i)
       cinp : in std_logic;            -- carry-in
       c: out reg4);            -- carry-out(i)
end carry4;

architecture functional of carry4 is 
  signal p,g : reg4;
begin

  PandG: for i in 0 to 3 generate
   begin
     U_gen:  g(i) <= a(i) and b(i);
     U_prop: p(i) <= a(i) or b(i);
   end generate PandG;

  c(0) <= g(0) or (p(0) and cinp);
  c(1) <= g(1) or (p(1) and g(0)) or (p(1) and p(0) and cinp);
  c(2) <= g(2) or (p(2) and g(1)) or (p(2) and p(1) and g(0)) or
          (p(2) and p(1) and p(0) and cinp);
  c(3) <= g(3) or (p(3) and g(2)) or (p(3) and p(2) and g(1)) or
          (p(3) and p(2) and p(1) and g(0)) or
          (p(3) and p(2) and p(1) and p(0) and cinp);

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 16-bit carry look-ahead
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use work.p_wires.all;

entity carry16 is
  port(a,b : in reg16;          -- entradas A(i),B(i)
       cinp : in std_logic;            -- vem-um
       c: out reg4);            -- vai(i), de 4 em 4 bits
end carry16;

architecture functional of carry16 is 
  signal p,g : reg16;
  signal pp,gg,cc : reg4;
begin

  gen: for i in 15 downto 0 generate
    g(i) <= a(i) and b(i);
    p(i) <= a(i) or  b(i);
  end generate gen;

  pp(0) <= p(3) and p(2) and p(1) and p(0);
  pp(1) <= p(7) and p(6) and p(5) and p(4);
  pp(2) <= p(11) and p(10) and p(9) and p(8);
  pp(3) <= p(15) and p(14) and p(13) and p(12);

  gg(0) <= g(3) or (p(3) and g(2)) or (p(3) and p(2) and g(1)) or
           (p(3) and p(2) and p(1) and g(0));

  gg(1) <= g(7) or (p(7) and g(6)) or (p(7) and p(6) and g(5)) or
           (p(7) and p(6) and p(5) and g(4));

  gg(2) <= g(11) or (p(11) and g(10)) or (p(11) and p(10) and g(9)) or
           (p(11) and p(10) and p(9) and g(8));

  gg(3) <= g(15) or (p(15) and g(14)) or (p(15) and p(14) and g(13)) or
           (p(15) and p(14) and p(13) and g(12));

  cc(0) <= gg(0) or (pp(0) and cinp);
  cc(1) <= gg(1) or (pp(1) and gg(0)) or (pp(1) and pp(0) and cinp);
  cc(2) <= gg(2) or (pp(2) and gg(1)) or (pp(2) and pp(1) and gg(0)) or
           (pp(2) and pp(1) and pp(0) and cinp);
  cc(3) <= gg(3) or (pp(3) and gg(2)) or (pp(3) and pp(2) and gg(1)) or
           (pp(3) and pp(2) and pp(1) and gg(0)) or
           (pp(3) and pp(2) and pp(1) and pp(0) and cinp);

  c <= cc;

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 16-bit carry look-ahead adder
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use work.p_wires.all;

entity adderCarry16 is
  port(inpA, inpB : in reg16;
       outC : out reg16;
       cinp  : in std_logic;
       cout  : out std_logic);
end adderCarry16;

architecture functional of adderCarry16 is 
  component addBit port(bitA, bitB, cinp : in std_logic;
                        sum, cout       : out std_logic);       
  end component addBit;

  component carry4 port(a,b : in reg4;
                          cinp : in std_logic;
                          c: out reg4);
  end component carry4;
  
  component carry16 port(a,b : in reg16;
                          cinp : in std_logic;
                          c: out reg4);
  end component carry16;
  
  signal v,r,c : reg16;
  signal cc : reg4;
begin


  
  U_a15_0:
    carry16 port map (inpA,inpB,cinp,cc); 
  
  U_a3_0: carry4 port map
    (inpA(3 downto 0),inpB(3 downto 0),cinp,c(3 downto 0)); 

  U_b0: addBit port map ( inpA(0),inpB(0),cinp,r(0),v(0) );
  U_b1: addBit port map ( inpA(1),inpB(1),c(0),r(1),v(1) );
  U_b2: addBit port map ( inpA(2),inpB(2),c(1),r(2),v(2) );
  U_b3: addBit port map ( inpA(3),inpB(3),c(2),r(3),v(3) );

  U_a4_7: carry4 port map
    (inpA(7 downto 4),inpB(7 downto 4),cc(0),c(7 downto 4));

  U_b4: addBit port map ( inpA(4),inpB(4),cc(0),r(4),v(4) );
  U_b5: addBit port map ( inpA(5),inpB(5), c(4),r(5),v(5) );
  U_b6: addBit port map ( inpA(6),inpB(6), c(5),r(6),v(6) );
  U_b7: addBit port map ( inpA(7),inpB(7), c(6),r(7),v(7) );

  U_a8_11: carry4 port map
    (inpA(11 downto 8),inpB(11 downto 8),cc(1),c(11 downto 8)); 

  U_b8: addBit port map ( inpA(8), inpB(8), cc(1), r(8), v(8) );
  U_b9: addBit port map ( inpA(9), inpB(9),  c(8), r(9), v(9) );
  U_ba: addBit port map ( inpA(10),inpB(10), c(9),r(10),v(10) );
  U_bb: addBit port map ( inpA(11),inpB(11),c(10),r(11),v(11) );

  U_a12_15: carry4 port map
    (inpA(15 downto 12),inpB(15 downto 12),cc(2),c(15 downto 12)); 

  U_bc: addBit port map ( inpA(12),inpB(12),cc(2),r(12),v(12) );
  U_bd: addBit port map ( inpA(13),inpB(13),c(12),r(13),v(13) );
  U_be: addBit port map ( inpA(14),inpB(14),c(13),r(14),v(14) );
  U_bf: addBit port map ( inpA(15),inpB(15),c(14),r(15),v(15) );
  
  cout <= cc(3);
  outC <= r;
  
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 32-bit carry-select adder
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use work.p_wires.all;

entity adder32 is
  port(A, B : in reg32;
       C  : out reg32;
       cinp  : in  std_logic;
       cout  : out std_logic);
end adder32;

architecture functional of adder32 is 
  component adderCarry16 is
    port(inpA, inpB : in reg16;
         outC : out reg16;
         cinp : in  std_logic;
         cout : out std_logic);
  end component adderCarry16;

  signal r_lo, r0, r1, r_hi : reg16;             -- partial results
  signal c_low, c_hi_0, c_hi_1 : std_logic;
  signal cc : reg4;
begin

  U_add_0_15: adderCarry16
    port map ( A(15 downto 0),  B(15 downto 0), r_lo, cinp, c_low);

  U_add_16_31_0: adderCarry16
    port map ( A(31 downto 16), B(31 downto 16), r0, '0', c_hi_0);

  U_add_16_31_1: adderCarry16
    port map ( A(31 downto 16), B(31 downto 16), r1, '1', c_hi_1);
  
  cout <= (c_hi_0 or c_low) and c_hi_1;
  
  r_hi <= r1 when c_low = '1' else r0;
  
  C <= r_hi & r_lo;
  
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
