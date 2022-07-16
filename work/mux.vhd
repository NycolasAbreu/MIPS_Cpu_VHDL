library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux is
    
port(
  muxInIR, muxRegA, muxInAluLsb, muxInRAM : in  signed(7 downto 0);
  muxSel            : in std_logic_vector (2 downto 0);
  muxOut            : out signed(7 downto 0));
end mux;

architecture rtl of mux is
begin
p_mux : process(muxInIR,muxRegA,muxInAluLsb,muxInRAM,muxSel)
begin
  case muxSel is
    when "000" =>
        muxOut <= muxInIR;
    when "001" =>
        muxOut <= muxRegA;
    when "010" =>
        muxOut <= muxInAluLsb;
    when "011" =>
        muxOut <= muxInRAM;   
    when others =>
        muxOut <= x"00";
  end case;
end process p_mux;
end rtl;