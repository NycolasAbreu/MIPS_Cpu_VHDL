-------------------------------------------------------------------
-- Name        : CPU.vhd
-- Author      : Nycolas
-- Version     : 0.1
-- Description : Entidade da cpu, unindo todos os componentes.
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        clk, rst    : in std_logic;                     -- Controle da CPU
        
        wr_mem_en   : out std_logic;
        mem_addr    : out std_logic_vector(7 downto 0);
        data_Out    : out std_logic_vector(7 downto 0);
        data_in     : in  std_logic_vector(7 downto 0);
        re_key_en   : out std_logic
    );
end entity cpu;

architecture stimulus of cpu is
    signal data         : std_logic_vector(15 downto 0);
    signal mem_add      : unsigned (7 downto 0);
    signal ram_select   : std_logic_vector(7 DOWNTO 0);
    
    --controller
    signal opCode       : unsigned (7 downto 0);
    signal enbRegA      : std_logic;
    signal enbRegB      : std_logic;
    signal enbIr        : std_logic;
    signal pcLoad       : std_logic;
    signal pcUp         : std_logic;
    signal aluOp        : std_logic_vector(7 downto 0);
    
    --regAB
    signal regAOut      : signed (7 downto 0);
    signal regBOut      : signed (7 downto 0);
    
    --instReg
    signal immediate    : unsigned (7 downto 0);
    
    --ULA
    signal result_lsb   : signed (7 downto 0);
    signal result_msb   : signed (7 downto 0);
    
    --MUX
    signal muxSel       : std_logic_vector(2 downto 0);
    signal muxOut       : signed (7 downto 0);
    
    --ROM
    signal count        : unsigned(7 downto 0);
    
    --RAM
    signal enbRamWr     : std_logic;
    signal ramOut       : unsigned (7 DOWNTO 0);

begin
    
    --Declaracao das entidades da CPU
    
    controller : entity work.controller
            port map(
                clk      => clk,
                rst      => rst,
                opCode   => std_logic_vector(opCode),
                aluOp    => aluOp,
                aluIn    => std_logic_vector(result_lsb),
                enbIr    => enbIr,
                enbRegA  => enbRegA,
                enbRegB  => enbRegB,
                muxSel   => muxSel,
                pcLoad   => pcLoad,
                pcUp     => pcUp,
                enbRamWr => enbRamWr
            ) ;
            
        ALU : entity work.ALU
            port map(
                a          => regAOut,
                b          => regBOut,
                aluOp      => aluOp,
                result_lsb => result_lsb,
                result_msb => result_msb
            ) ;
            
        InstReg : entity work.InstReg
            port map(
                data      => unsigned(data),
                clk       => clk,
                rst       => rst,
                enbIr     => enbIr,
                opCode    => opCode,
                immediate => immediate,
                mem_addr  => mem_add
            ) ;
        
        mux : entity work.mux
            port map(
                muxInIR     => signed(immediate),
                muxRegA     => regAOut,
                muxInAluLsb => result_lsb,
                muxInRAM    => signed(ram_select),
                muxSel      => muxSel,
                muxOut      => muxOut
            ) ;
        
        reg1 : entity work.reg
            generic map(
                regsize => 8
            ) 
            port map(
                regIn  => signed(muxOut),
                clear  => rst,
                w_flag => enbRegA,
                clk    => clk,
                regOut => regAOut
            ) ;
        
        reg2 : entity work.reg
            generic map(
                regsize => 8
            ) 
            port map(
                regIn  => result_msb,
                clear  => rst,
                w_flag => enbRegB,
                clk    => clk,
                regOut => regBOut
            ) ;
            
        counter : entity work.counter
            port map(
                clk     => clk,
                pcLoad  => pcLoad,
                rst     => rst,
                pcUp    => pcUp,
                datain  => mem_add,
                dataout => count
            ) ;
            
        rom_inst : entity work.rom
            port map(
                address => std_logic_vector(count),
                clock   => clk,
                q       => data
            ) ;
            
        RAM : entity work.ram
            generic map(
                size => 256
            ) 
            port map(
                clock         => clk,
                enbWr         => enbRamWr,
                data          => unsigned(regAOut),
                write_address => mem_add,
                read_address  => mem_add,
                data_out      => ramOut
            ) ;
            
    mem_addr <= std_logic_vector(mem_add);
    data_Out <= std_logic_vector(regAOut);
        
    with mem_add select -- opera��o de MUX para a entrada de dados
        ram_select <=  std_logic_vector(data_in)    when x"FE",
                       std_logic_vector(ramOut)     when others;
    
process(mem_add, opCode)
  begin
      wr_mem_en <= '0';
      re_key_en <= '0';
      
      if opCode = x"02" then        -- Estado MEM_WR mostra na tela 
        if mem_add = "11111111" then   -- x"02FF"
            wr_mem_en <= '1';
        end if;
      end if;
      
      if opCode = x"01" then        -- Estado MEM_RD recebe valor das chaves
        if mem_add = "11111110" then   -- x"01FE"
            re_key_en <= '1';
        end if;
      end if;
  end process;
  
end architecture stimulus;