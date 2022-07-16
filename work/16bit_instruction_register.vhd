-------------------------------------------------------------------
-- Name        : 16bit_instruction_register.vhd
-- Author      : Nycolas
-- Version     : 0.1
-- Description : Registrador de instrucoes de 16 bits
-------------------------------------------------------------------

-- Bibliotecas
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

-- Entidade e portas
ENTITY InstReg IS

    PORT (data: IN unsigned (15 downto 0);
          clk, rst, enbIr: IN std_logic;
          opCode, immediate, mem_addr: OUT unsigned (7 downto 0));

END ENTITY InstReg;

-- Arquitetura
ARCHITECTURE LOGIC OF InstReg IS

BEGIN
    process(rst,clk)
    begin
	
	if rst = '1' then 
		opCode            <= (others =>'0');
		immediate         <= (others =>'0');
		mem_addr          <= (others =>'0');
	elsif rising_edge(clk) then
		if enbIr = '1' then
			opCode       <= data (15 downto 8);
			immediate    <= data (7 downto 0);
			mem_addr     <= data (7 downto 0);
		end if;	
	end if;
    end process;

END ARCHITECTURE LOGIC;