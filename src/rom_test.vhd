-------------------------------------------------------------------
-- Name        : rom_test.vhd
-- Author      : Nycolas
-- Version     : 0.1
-- Description : Memoria Rom de 16bits
-------------------------------------------------------------------

-- Bibliotecas
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_test is
	port (
		clk : 	 in std_logic;
		addr : 	 in unsigned(7 downto 0);
		romOut : out unsigned(15 downto 0)
	);
end entity;

architecture rtl of rom_test is
	
	-- Build a 2-D array type for the RAM
	subtype word_t is unsigned(15 downto 0);
	type memory_t is array(0 to 31) of word_t;
		
	-- Initialize memory with constant values
	-- Does work with Quartus
	signal rom : memory_t := 
					(x"6064", x"0200", x"60FF", x"7000",
					    x"0100", x"02FF", x"1000", x"0200",
					    x"7000", x"6000" ,x"0302", x"FF00",
					 others => (others => '0')); 
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			    romOut <= rom(to_integer(addr));
		end if;
	end process;	
end rtl;