# Neander em Verilog estrutural (nivel de portas)

Todos os modulos do processador usam apenas as primitivas `nand`, `nor` e `not`
(`lib_portas.v`), com latches e flip-flops montados a partir delas (`sequenciais.v`).
Operadores (`+`, `&`, `?:`) e `always` aparecem somente nas testbenches. Dentro dos modulos,
`generate/for` e `assign` servem so para replicar instancias e dar nome a fios (ligacao, nao logica).

| Arquivo | Conteudo | Membro |
|---|---|---|
| `src/lib_portas.v` | not1, and2-4, or2-4, nand2, nor2, xor2, mux2_1, nor8, or16 | 1 |
| `src/mux2x8.v`, `src/somador.v`, `src/ual.v`, `src/decod_opcode.v` | MUX 8 bits, somador, UAL (5 ops, N, Z), decodificador | 1 |
| `src/sequenciais.v` | dlatch, dff, reg1, reg8 (AC/REM/RI), rdm, regnz, pc8 | 2 |
| `src/ram16x8.v` | RAM 16x8, decodificador 4->16, leitura AND-OR, reset carrega programa | 3 |
| `src/gerador_tempo.v`, `src/unidade_controle.v` | contador t0..t7 e equacoes dos sinais | 4 |
| `src/neander_top.v`, `tb/`, `gen_referencia.py` | top-level, testbenches, modelo de referencia | 5 |

## Rodar
    make test      # UAL, RAM/PC e 3 programas completos conferidos contra o modelo em Python
    make wave      # formas de onda (GTKWave)

## Trocar o programa
`neander_top` tem o parametro `MEM_INIT` (128 bits; byte i = `MEM_INIT[8*i +: 8]`).
Edite os programas em `gen_referencia.py` e rode `make test`: ele recalcula o trace esperado
e regera `tb/tb_neander.v`. **O P1 e so o exemplo do guia: cada grupo deve criar o seu programa.**

## Convencoes
Clock em borda de subida; reset sincrono ativo em 1 (segure 2+ ciclos); sinais ativos em 1;
`selUAL`: 000 ADD, 001 AND, 010 OR, 011 NOT, 100 Y; opcodes invalidos = NOP.
