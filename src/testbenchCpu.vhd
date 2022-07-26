-------------------------------------------------------------------
-- Name        : testbenchCpu.vhd
-- Author      : Nycolas
-- Version     : 0.1
-- Description : testbench da cpu, editar o assembly na rom_test.vhd
-------------------------------------------------------------------

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
            clk, rst  : in  std_logic;
            wr_mem_en : out std_logic;
            mem_addr  : out std_logic_vector (7 downto 0);
            data_out  : out std_logic_vector(7 downto 0);
            data_in   : in  std_logic_vector(7 downto 0);
            re_key_en : out std_logic
        );
    end component cpu;

    -- declaracao de sinais
    signal clk, rst: std_logic;
    signal wr_mem_en : std_logic;
    signal mem_addr : std_logic_vector(7 downto 0);
    signal data_out : std_logic_vector(7 downto 0);
    signal re_key_en : std_logic;
    signal data_in : std_logic_vector(7 downto 0);
    signal data_key_in : std_logic_vector(7 downto 0);
    signal hex0 : std_logic_vector(7 downto 0); -- @suppress "signal hex0 is never read"
    signal hex1 : std_logic_vector(7 downto 0); -- @suppress "signal hex1 is never read"

BEGIN
    cpu1 : entity work.cpu_test
        port map(
            clk       => clk,
            rst       => rst,
            wr_mem_en => wr_mem_en,
            mem_addr  => mem_addr,
            data_out  => data_out,
            data_in   => data_in,
            re_key_en => re_key_en
        ) ;
    
    key_reg_inst : entity work.key_reg
        port map(
            clk         => clk,
            rst         => rst,
            mem_addr    => std_logic_vector(mem_addr),
            data_key_in => data_key_in,
            data_out    => data_in,
            re_key_en   => re_key_en
        ) ;
        
    led_display_inst : entity work.led_display
        port map(
            clk          => clk,
            rst          => rst,
            wr_mem_en    => wr_mem_en,
            data_Out       => data_out,
            mem_addr_bus => mem_addr,
            hex0         => hex0,
            hex1         => hex1
        ) ;
            
    
    --gera um clk
    process
    begin
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';    
    end process;
    
    --process 
    --begin
    --    wait for 80 ns;
    --    data_key_in <= x"01";
    --    wait for 80 ns;
    --    data_key_in <= x"0F";
    --end process;
    
    --gera rst
    process
    begin
        rst <= '1';
        wait for 5 ns;
        rst <= '0';
        wait for 100000 ns;
        rst <= '1';    
    end process;
    
END ARCHITECTURE stimulus;