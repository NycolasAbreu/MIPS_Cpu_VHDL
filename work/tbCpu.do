#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivos. Ordem é importante
vcom key_reg.vhd
vcom led.vhd
vcom led_display.vhd
vcom counter.vhd
vcom rom.vhd
VCOM ram.vhd
vcom 16bit_instruction_register.vhd
vcom mux.vhd
vcom Register_16bits.vhd
vcom ALU.vhd
vcom Controller.vhd
vcom CPU.vhd 
vcom testbenchCpu.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -radix binary  -label Clock    /cpu1/clk
add wave -radix binary  -label Reset    /cpu1/rst
add wave -radix dec     -label PC       /cpu1/count
add wave -radix dec     -label PCLoad   /cpu1/pcLoad
add wave -radix hex     -label DATA     /cpu1/data
add wave -radix hex     -label OpCode   /cpu1/opCode
add wave -radix hex     -label immediate /cpu1/immediate
add wave -radix hex     -label mem_addr /cpu1/mem_addr
add wave -radix bin     -label muxSel   /cpu1/muxSel
add wave -radix hex     -label muxOut   /cpu1/muxOut
add wave -radix hex     -label enbRegA  /cpu1/enbRegA
add wave -radix hex     -label regAOut  /cpu1/regAOut
add wave -radix hex     -label enbRegB  /cpu1/enbRegB
add wave -radix hex     -label regBOut  /cpu1/regBOut
add wave -radix hex     -label lsb      /cpu1/result_lsb
add wave -radix hex     -label msb      /cpu1/result_msb
add wave -radix hex     -label aluOp    /cpu1/aluOp
add wave -radix bin     -label ledOut   /cpu1/ledOut
#pegar o sinal de dentro do componente
add wave -radix dec -label state   /cpu1/controller/state
run 1000ns

wave zoomfull
write wave wave.ps
