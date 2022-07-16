library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        clk, rst    : in std_logic;
        wr_bus_en   : in std_logic;
        --data_in     : in std_logic_vector(15 downto 0);
        
        hex0 : out std_logic_vector(7 downto 0);
        hex1 : out std_logic_vector(7 downto 0);
        hex2 : out std_logic_vector(7 downto 0);
        hex3 : out std_logic_vector(7 downto 0);
        hex4 : out std_logic_vector(7 downto 0);
        hex5 : out std_logic_vector(7 downto 0)
    );
end entity cpu;

architecture stimulus of cpu is
    signal data         : unsigned (15 downto 0);
    
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
    signal mem_addr     : unsigned (7 downto 0);
    signal immediate    : unsigned (7 downto 0);
    
    --ULA
    signal result_lsb   : signed (7 downto 0);
    signal result_msb   : signed (7 downto 0);
    
    --MUX
    signal muxSel       : std_logic_vector(2 downto 0);
    signal muxOut       : signed (7 downto 0);
    
    --ROM
    signal enbRom       : std_logic;
    signal count        : unsigned(7 downto 0);
    
    --RAM
    signal enbRamWr     : std_logic;
    signal ramOut       : unsigned (7 DOWNTO 0);

begin
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
                enbRom   => enbRom,
                enbRamWr => enbRamWr
            ) ;
            
        ALU : entity work.ALU
            port map(
                a          => signed(regAOut),
                b          => signed(regBOut),
                aluOp      => aluOp,
                result_lsb => result_lsb,
                result_msb => result_msb
            ) ;
            
        InstReg : entity work.InstReg
            port map(
                data      => data,
                clk       => clk,
                rst       => rst,
                enbIr     => enbIr,
                opCode    => opCode,
                immediate => immediate,
                mem_addr  => mem_addr
            ) ;
        
        mux : entity work.mux
            port map(
                muxInIR => signed(immediate),
                muxRegA => regAOut,
                muxInAluLsb => result_lsb,
                muxInRAM => signed(ramOut),
                muxSel  => muxSel,
                muxOut  => muxOut
            ) ;
        
        reg1 : entity work.reg
            generic map(
                regsize => 8
            ) 
            port map(
                regIn  => muxOut,
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
                datain  => mem_addr,
                dataout => count
            ) ;
            
        ROM : entity work.rom
            port map(
                clk    => clk,
                enbRom => enbRom,
                addr   => count,
                romOut => data
            ) ;
        
        RAM : entity work.ram
            generic map(
                size => 256
            ) 
            port map(
                clock         => clk,
                enbWr         => enbRamWr,
                data          => unsigned(regAOut),
                write_address => mem_addr,
                read_address  => mem_addr,
                data_out      => ramOut
            ) ;
        
        led_display_inst : entity work.led_display
            port map(
                clk          => clk,
                rst          => rst,
                wr_bus_en    => wr_bus_en,
                data         => std_logic_vector(data),
                mem_addr     => std_logic_vector(mem_addr),
                regA         => std_logic_vector(regAOut),
                hex0         => hex0,
                hex1         => hex1,
                hex2         => hex2,
                hex3         => hex3,
                hex4         => hex4,
                hex5         => hex5
            ) ;
        
    
end architecture stimulus;