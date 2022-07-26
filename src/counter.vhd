-------------------------------------------------------------------
-- Name        : counter.vhd
-- Author      : Nycolas
-- Version     : 0.1
-- Description : contador de programa
-- Se reset � n�vel alto, data recebe 0 assincronamente;
-- Se load � n�vel alto, data recebe data_in;
-- Se up � n�vel alto, data � incrementado em 1;
-- Se up e load s�o n�vel alto, load tem prioridade.
-------------------------------------------------------------------

-- Bibliotecas
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

-- Entidade e portas
ENTITY counter IS

    PORT (clk, pcLoad, rst, pcUp: IN std_logic;
	      datain: IN unsigned (7 downto 0);
          dataout: OUT unsigned (7 downto 0));

END ENTITY counter;

-- Arquitetura
ARCHITECTURE LOGIC OF counter IS

BEGIN
    process(rst,clk)
	variable dataTemp : unsigned (7 downto 0);
    begin
	
	if rst = '1' then 
		dataout <= (others =>'0'); 
		dataTemp := (others =>'0');
	elsif rising_edge(clk) then
		if pcLoad = '1' then
			dataout <= datain;
			dataTemp := datain;
		elsif pcUp = '1' then
			dataout <= dataTemp + To_unsigned(1,dataout'length);	
			dataTemp := dataTemp + To_unsigned(1,dataout'length);
		end if;
	end if;	

    end process;

END ARCHITECTURE LOGIC;