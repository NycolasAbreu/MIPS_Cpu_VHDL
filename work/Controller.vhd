library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
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
                
        --ROM
        enbRom : out std_logic;
        
        --RAM
        enbRamWr : out std_logic
    );
end entity controller;

architecture RTL of controller is
    type state_type is (
        STOP, HALT, FETCH, DECODE, ALU_EXE, ID_IMED,
        MEM_CALC, MEM_RD, MEM_WR, WR_BK_MEM, BRANCH_COMPL,
        JUMP_COMPL, WR_BK_REG1, WR_BK_REG2, ERROR, WAIT_STATE
    );
    
    signal state : state_type;
    
begin
    
    -- Processo repsonsável apenas pela transição de estados
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
                
                when HALT =>        --Estado morto -- @suppress "Dead state 'HALT': state does not have outgoing transitions"
                    state <= HALT;
                
                when FETCH =>
                    state <= DECODE;
                
                when DECODE =>      --Decodificando as instrucoes
                    if opCode = x"ff"
                        then state <= HALT;
                    
                    elsif  opCode = x"10" or opCode = x"20"
                        or opCode = x"30" or opCode = x"40"
                        or opCode = x"50" or opCode = x"70"
                        then state <= ALU_EXE;
                    
                    elsif opCode = x"60"
                        then state <= ID_IMED;
                    
                    elsif opCode = x"01" or opCode = x"02"
                        then state <= MEM_CALC;
                        
                    elsif opCode = x"03" or opCode = x"04"
                        then state <= BRANCH_COMPL;
                        
                    elsif opCode = x"05"
                        then state <= JUMP_COMPL;
                    
                    else
                        state <= ERROR;   
                    end if;
                
                when ALU_EXE =>
                    if opCode = x"20" or opCode = x"70"
                        then state <= WR_BK_REG1;
                    else
                        state <= WR_BK_REG2;
                    end if;
                
                when WR_BK_REG1 =>
                    state <= FETCH;
                    
                when WR_BK_REG2 =>
                    state <= FETCH;
                    
                when ID_IMED =>
                    state <= WAIT_STATE;
                    
                when MEM_CALC =>
                    if opCode = x"01"
                        then state <= MEM_RD;
                    elsif opCode = x"02"
                        then state <= MEM_WR;
                    end if;
                    
                when MEM_WR =>
                    state <= FETCH;
                    
                when MEM_RD =>
                    state <= WR_BK_MEM;
                    
                when WR_BK_MEM =>
                    state <= FETCH;
                    
                when BRANCH_COMPL =>
                    state <= WAIT_STATE;
                    
                when JUMP_COMPL =>
                    state <= FETCH;
                    
                when WAIT_STATE =>
                    state <= FETCH;
                    
                when ERROR =>
                    state <= FETCH;
            end case;
        end if;
    end process;
    
    -- Saída(s) tipo Moore
    -- Apenas relacionadas com o estado
    moore: process(state, opCode, aluIn)
    begin
        aluOp       <= x"00";
        muxSel      <= "111";   -- Saida zero
        enbRom      <= '1';     -- Rom sempre abilitada
        enbIr       <= '0';
        enbRegA     <= '0';
        enbRegB     <= '0';
        pcLoad      <= '0';
        pcUp        <= '0';
        enbRamWr    <= '0';
        
        case state is
            when STOP =>                -- Nao faz nada
                
            when HALT =>                -- Termina o programa
                
            when FETCH =>
                enbRom  <= '1';
                enbIr   <= '1';
                pcLoad  <= '0';
                
            when DECODE =>
                
            when ALU_EXE =>             -- Execução da ALU
                pcUp        <= '1';     -- Incrementa o contador
                aluOp       <= opCode;  -- Envia para a ALU a operacao

            when WR_BK_REG1 =>
                enbRegB     <= '1';     -- Ativa o REGB para receber o valor de lsb
                enbRegA     <= '1';     -- Ativa o REGA para receber o valor de msb
                muxSel      <= "010";   -- Saida LSB ALU
                aluOp       <= opCode;    
                
            when WR_BK_REG2 =>
                muxSel      <= "010";   -- Saida LSB ALU
                enbRegA     <= '1';     -- Ativa o REGA para receber o valor de lsb
                aluOp       <= opCode;
                
            when ID_IMED =>
                muxSel      <= "000";   -- Saida IR
                enbRegA     <= '1';     -- Ativa o REGA para receber o valor de IR
                pcUp        <= '1';
                
            when MEM_RD =>
                enbRamWr    <= '0';     -- Apenas le a memoria
                
            when MEM_WR =>
                enbRamWr    <= '1';     -- Escreve na memoria conteudo de REGA
                
            when WR_BK_MEM =>
                muxSel      <= "011";   -- Saida da RAM
                enbRegA     <= '1';     -- Grava conteudo em REGA
                
            when JUMP_COMPL =>
                pcUp        <= '0';     -- Pausa o contador
                pcLoad      <= '1';     -- Carrega para PC novo endereco absoluto

            when BRANCH_COMPL =>        -- Branch se A < B           
                aluOp       <= opCode;
                pcUp        <= '1';
                if(aluIn = x"01") then
                    pcLoad  <= '1';
                end if;
                
            when MEM_CALC =>            -- Sem funcao
                pcUp    <= '1';
                
            when ERROR =>
            when WAIT_STATE =>
                    
        end case;
    end process;
    
end architecture RTL;