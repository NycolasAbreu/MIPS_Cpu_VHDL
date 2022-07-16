library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------
ENTITY testbench IS
END ENTITY testbench;
------------------------------

ARCHITECTURE stimulus OF testbench IS
    component cpu
        port(
            clk, rst : in  std_logic;
            ledWr    : in  std_logic;
            ledOut   : out std_logic_vector(9 downto 0)
        );
    end component cpu;

    -- declaracao de sinais
    signal clk, rst: std_logic;
    signal ledOut: std_logic_vector(9 downto 0);

BEGIN
    
    cpu1: cpu port map (
        clk => clk,
        rst => rst,
        ledWr => '1',
        ledOut => ledOut
    );
    
    --gera um clk
    process
    begin
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';    
    end process;
    
    --gera rst
    process
    begin
        rst <= '1';
        wait for 5 ns;
        rst <= '0';
        wait for 10000 ns;
        rst <= '1';    
    end process;
    
END ARCHITECTURE stimulus;