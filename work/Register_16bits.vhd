library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
    generic(
        regsize : natural := 16
    );
    port (
        regIn : in signed (regsize-1 downto 0);
        clear, w_flag, clk : in std_logic;
        regOut : out signed (regsize-1 downto 0)
    );
end entity reg;

architecture rtl of reg is
begin
    process (clk, clear)
    begin
        if clear = '1' then               -- Limpa a saida se rst eh alto
            regOut <= (others => '0');
        elsif rising_edge(clk) then     -- Verifica subida do Clock
            if w_flag = '1' then           -- Verifica se rd eh alto
                regOut <= regIn;      -- Registra a entrada na saida
            end if;  
        end if;    
    end process;
end architecture rtl;