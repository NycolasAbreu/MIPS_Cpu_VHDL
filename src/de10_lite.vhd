-------------------------------------------------------------------
-- Name        : de10_lite.vhd
-- Author      : Nycolas Coelho de Abreu
-- Version     : 0.1
-- Copyright   : Departamento de Eletronica, Florianopolis, IFSC
-- Description : Base de10_lite para o CPU
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity de10_lite is 
	port (
		---------- CLOCK ----------
		ADC_CLK_10:	in std_logic;
		
		----------- SEG7 ------------
		HEX0: out std_logic_vector(7 downto 0);
		HEX1: out std_logic_vector(7 downto 0);
		HEX2: out std_logic_vector(7 downto 0);
		HEX3: out std_logic_vector(7 downto 0);
		HEX4: out std_logic_vector(7 downto 0);
		HEX5: out std_logic_vector(7 downto 0);

		----------- KEY ------------
		KEY: in std_logic_vector(1 downto 0);

		----------- LED ------------
		LEDR: out std_logic_vector(9 downto 0);

		----------- SW ------------
		SW: in std_logic_vector(9 downto 0)
	);
end entity;


architecture rtl of de10_lite is
    --Declaracao dos sinais
    signal data_Out:    std_logic_vector (7 downto 0);
    signal data_in:     std_logic_vector (7 downto 0);
    signal mem_addr:    std_logic_vector (7 downto 0);
    signal clkPLL:      std_logic;             -- @suppress
    signal clk:         std_logic;
    signal rst:         std_logic;
    signal re_key_en:   std_logic;
    signal wr_mem_en:   std_logic;
    signal clkDiv:      std_logic;
begin

    -- Definindo as portas com seus sinais
    clk  <= KEY(0);                     --Botao 0 serve como clock
    rst  <= not(KEY(1));                --Botao 1 serve como reset
    LEDR(7 downto 0) <= SW(7 downto 0); --Acende os leds ao chavear um valor
    HEX2 <= (others => '1');
    HEX3 <= (others => '1');
    HEX4 <= (others => '1');            --Apaga os displays sem utilizacao
    HEX5 <= (others => '1');
    
    -- Declaracao das entidades
    PLL : entity work.PLL
        port map(
            inclk0 => ADC_CLK_10,
            c0     => clkPLL            -- Saida de 1k2 Hz
    );
    
    Clock_Divider_inst : entity work.Clock_Divider
        port map(
            clk       => clkPLL,
            reset     => rst,
            clock_out => clkDiv         --Divide o clock em 10X saida de 120Hz
        ) ;
    

	cpu1: entity work.cpu
	    port map (
            clk       => clkDiv,
            rst       => rst,
            wr_mem_en => wr_mem_en,
            mem_addr  => mem_addr,
            data_Out  => data_Out,
            data_in   => data_in,
            re_key_en => re_key_en
		);
	
    led_display : entity work.led_display
        port map(
            clk          => clkDiv,
            rst          => rst,
            wr_mem_en    => wr_mem_en,
            data_Out     => data_Out,
            mem_addr_bus => mem_addr,
            hex0         => HEX0,
            hex1         => HEX1
    );
	
	key_reg : entity work.key_reg
	    port map(
            clk          => clkDiv,
            rst          => rst,
            mem_addr     => mem_addr,
            data_key_in  => SW(7 downto 0), -- Entrada de dados pelas chaves
            data_out     => data_in,
            re_key_en    => re_key_en
	);
		
end;