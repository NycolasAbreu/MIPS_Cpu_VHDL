-------------------------------------------------------------------
-- Name        : Controller.vhd
-- Author      : Nycolas
-- Version     : 0.1
-- Description : Controlador da cpu
-- Controla os sinais de enable da memória ram, rom, dos registradores,
-- do mux e operacoes da ALU
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
        --Entrada de controle
        clk : in std_logic;
        rst : in std_logic;
        
        --Entrada instrucao
        opCode : in std_logic_vector(7 downto 0);

        --ALU instrucao
        aluOp : out std_logic_vector(7 downto 0);
        aluIn : in std_logic_vector(7 downto 0);
        
        --Registrador de instrucao
        enbIr : out std_logic;
        
        --Registradores enable
        enbRegA : out std_logic;
        enbRegB : out std_logic;
        
        --Mux selecao
        muxSel : out std_logic_vector(2 downto 0);
        
        --PC
        pcLoad : out std_logic;
        pcUp : out std_logic;
        
        --RAM
        enbRamWr : out std_logic
    );
end entity controller;

architecture RTL of controller is
    type state_type is (                -- Estados da maquina de estados
        STOP, HALT, FETCH, DECODE, ALU_EXE, ID_IMED,
        MEM_CALC, MEM_RD, MEM_WR, WR_BK_MEM, BRANCH_COMPL,
        JUMP_COMPL, WR_BK_REG1, WR_BK_REG2, ERROR, WAIT_STATE
    );
    
    signal state : state_type;
    
begin
    
    -- Processo repsons�vel apenas pela transi��o de estados
    state_transation: process(clk, rst) is
    begin
        if rst = '1' then
            state <= STOP;
        elsif rising_edge(clk) then
            case state is
                when STOP =>        --Inicio da cpu
                    if rst = '0' then
                        state <= FETCH;
                    end if;
                
                when HALT =>        --Estado morto --@suppress
                    state <= HALT;
                
                when FETCH =>       --Busca a proxima instrucao
                    state <= DECODE;
                
                when DECODE =>      --Decodificando as instrucoes
                    if opCode = x"ff"
                        then state <= HALT;
                    
                    elsif  opCode = x"10" or opCode = x"20"     --Funcoes da ALU
                        or opCode = x"30" or opCode = x"40"
                        or opCode = x"50" or opCode = x"70"
                        then state <= ALU_EXE;
                    
                    elsif opCode = x"60"                        --Operacao de carga
                        then state <= ID_IMED;
                    
                    elsif opCode = x"01" or opCode = x"02"      --Operacao de memoria
                        then state <= MEM_CALC;
                        
                    elsif opCode = x"03" or opCode = x"04"      --Branch
                        then state <= BRANCH_COMPL;
                        
                    elsif opCode = x"05"                        --Jump
                        then state <= JUMP_COMPL;
                    
                    else
                        state <= ERROR;                         --Erro
                    end if;
                
                when ALU_EXE =>                                 --Execucao da intrucao da ALU
                    if opCode = x"20" or opCode = x"70"
                        then state <= WR_BK_REG1;
                    else
                        state <= WR_BK_REG2;
                    end if;
                
                when WR_BK_REG1 =>                              --Executa operacao e salva em regB
                    state <= FETCH;
                    
                when WR_BK_REG2 =>                              --Executa operacao e salva em regA
                    state <= FETCH;
                    
                when ID_IMED =>                                 -- Carrega valor em regA
                    state <= WAIT_STATE;
                    
                when MEM_CALC =>
                    if opCode = x"01"
                        then state <= MEM_RD;
                    elsif opCode = x"02"
                        then state <= MEM_WR;
                    end if;
                    
                when MEM_WR =>                  --Escreve na memoria valor de regA
                    state <= FETCH;
                    
                when MEM_RD =>                  --Le valor presente na memoria
                    state <= WR_BK_MEM;
                    
                when WR_BK_MEM =>               --Grava em regA valor da memoria
                    state <= FETCH;
                    
                when BRANCH_COMPL =>            --Branch
                    state <= WAIT_STATE;
                    
                when JUMP_COMPL =>              --Jump
                    state <= FETCH;
                    
                when WAIT_STATE =>              --Estado de espera para situacoes onde a operacao
                    state <= FETCH;             --ainda nao terminou
                    
                when ERROR =>                   --Erro
                    state <= FETCH;
            end case;
        end if;
    end process;
    
    -- Sa�da(s) tipo Moore
    -- Apenas relacionadas com o estado
    moore: process(state, opCode, aluIn)
    begin
        aluOp       <= x"00";
        muxSel      <= "111";   -- Saida zero=
        enbIr       <= '0';
        enbRegA     <= '0';
        enbRegB     <= '0';
        pcLoad      <= '0';
        pcUp        <= '0';
        enbRamWr    <= '0';
        
        case state is
            when STOP =>                -- Nao faz nada
                
            when HALT =>                -- Termina o programa
                
            when FETCH =>               -- Busca as novas instrucoes
                enbIr   <= '1';
                pcLoad  <= '0';
                
            when DECODE =>
                
            when ALU_EXE =>             -- Execu��o da ALU
                pcUp        <= '1';     -- Incrementa o contador
                aluOp       <= opCode;  -- Envia para a ALU a operacao

            when WR_BK_REG1 =>
                enbRegB     <= '1';     -- Ativa o REGB para receber o valor de lsb
                enbRegA     <= '1';     -- Ativa o REGA para receber o valor de msb
                muxSel      <= "010";   -- Saida LSB ALU
                aluOp       <= opCode;  -- Envia para a ALU a opercao
                
            when WR_BK_REG2 =>
                muxSel      <= "010";   -- Saida LSB ALU
                enbRegA     <= '1';     -- Ativa o REGA para receber o valor de lsb
                aluOp       <= opCode;  -- Envia para a ALU a opercao
                
            when ID_IMED =>
                muxSel      <= "000";   -- Saida IR
                enbRegA     <= '1';     -- Ativa o REGA para receber o valor de IR
                pcUp        <= '1';     -- Enable do contador
                
            when MEM_RD =>
                enbRamWr    <= '0';     -- Le a memoria RAM
                
            when MEM_WR =>
                enbRamWr    <= '1';     -- Escreve na memoria RAM conteudo de REGA
                
            when WR_BK_MEM =>
                muxSel      <= "011";   -- Saida da RAM
                enbRegA     <= '1';     -- Grava conteudo em REGA
                
            when JUMP_COMPL =>
                pcUp        <= '0';     -- Pausa o contador
                pcLoad      <= '1';     -- Carrega para PC novo endereco absoluto

            when BRANCH_COMPL =>        -- Branch se A < B           
                aluOp       <= opCode;  -- Envia para a ALU a opercao
                pcUp        <= '1';     -- Enable do contador
                if(aluIn = x"01") then  -- Se resultado A < B e A == B for correto carrega o novo endere�o
                    pcLoad  <= '1';     -- Carrega endereco novo
                end if;
                
            when MEM_CALC =>            -- Sem funcao
                pcUp    <= '1';         -- Enable do contador
                
            when ERROR =>               -- Estados sem funcao
            when WAIT_STATE =>
                    
        end case;
    end process;
    
end architecture RTL;