-------------------------------------------------------------------
-- Name        : Rom.vhd
-- Author      : Nycolas
-- Version     : 0.1
-- Description : Memoria Rom de 16bits
-------------------------------------------------------------------

-- Bibliotecas
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
	port (
		clk, enbRom : 	in std_logic;
		addr : 		    in unsigned(7 downto 0);
		romOut : 		out unsigned(15 downto 0)
	);
end entity;

architecture rtl of rom is
	
	-- Build a 2-D array type for the RAM
	subtype word_t is unsigned(15 downto 0);
	type memory_t is array(0 to 31) of word_t;
		
	-- Initialize memory with constant values
	-- Does work with Quartus
	signal rom : memory_t := 
					(x"6005", x"7000", x"6005", x"1000", x"02FF",x"0500",
					 others => (others => '0')); 
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if enbRom = '1' then 
			    romOut <= rom(to_integer(addr));
			end if;
		end if;
	end process;	
end rtl;