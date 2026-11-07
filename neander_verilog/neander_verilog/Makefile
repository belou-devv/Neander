# Uso: make test   (requer iverilog)  |  make wave  (abre neander.vcd no GTKWave)
SRC = $(wildcard src/*.v)
test:
	python3 gen_referencia.py > /dev/null
	iverilog -g2005 -o sim_ual   $(SRC) tb/tb_ual.v     && vvp sim_ual   | grep -v finish
	iverilog -g2005 -o sim_ram   $(SRC) tb/tb_ram_pc.v  && vvp sim_ram   | grep -v finish
	iverilog -g2005 -o sim_top   $(SRC) tb/tb_neander.v && vvp sim_top   | grep -v finish
wave:
	gtkwave neander.vcd
clean:
	rm -f sim_* neander.vcd
