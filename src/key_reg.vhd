-------------------------------------------------------------------
-- Name        : key_reg.vhd
-- Author      : Nycolas
-- Version     : 0.1
-- Description : Registrador para entrada de dados na cpu.
-- Eh ativado quando for utilizado o endereco x"FE".
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity key_reg is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        mem_addr    : in std_logic_vector(7 downto 0);
        data_key_in : in std_logic_vector(7 downto 0);
        data_out    : out std_logic_vector(7 downto 0);     
        re_key_en   : in std_logic
    );
end entity key_reg;

architecture RTL of key_reg is
    
begin
    process(clk, rst)
    begin       
        if rst = '1' then
            data_out <= (others => '0'); 
        else
            if rising_edge(clk) then
                if (re_key_en = '1' and mem_addr = "11111110") then
                    data_out <= data_key_in;
                end if;
            end if;
        end if;
    end process;
end architecture RTL;