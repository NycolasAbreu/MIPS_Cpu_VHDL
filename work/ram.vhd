-------------------------------------------------------------------
-- Name        : Ram.vhd
-- Version     : 0.1
-- Copyright   : Nycolas Abreu
-- Description : Memoria RAM (single clk)
-------------------------------------------------------------------

-- Bibliotecas
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Entidade
ENTITY ram IS
    GENERIC (size : integer);	-- Valor generico para tamanho da ram
    PORT (
        clock, enbWr: IN STD_LOGIC;
        data: IN unsigned (7 DOWNTO 0);
        write_address, read_address: IN unsigned (7 downto 0);
        data_out: OUT unsigned (7 DOWNTO 0)
    );
END ram;

-- Arquitetura do funcionamento
ARCHITECTURE rtl OF ram IS
    TYPE MEM IS ARRAY(0 TO size-1) OF unsigned (7 DOWNTO 0);
    SIGNAL ram_block: MEM;
BEGIN
    PROCESS (clock)
    BEGIN
        IF (clock'event AND clock = '1') THEN
            IF (enbWr = '1') THEN
                ram_block(to_integer(write_address)) <= data;
            END IF;
            data_out <= ram_block(to_integer(read_address)); 
        END IF;
    END PROCESS;
END rtl;