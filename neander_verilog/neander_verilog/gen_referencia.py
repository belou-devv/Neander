#!/usr/bin/env python3
"""Modelo de referencia do Neander (nivel de instrucao) + gerador de tb/tb_neander.v.
Executa cada programa, gera o trace esperado (PC, AC, N, Z no inicio de cada instrucao)
e escreve a testbench auto-verificavel."""
OP = {'NOP':0x0,'STA':0x1,'LDA':0x2,'ADD':0x3,'OR':0x4,'AND':0x5,'NOT':0x6,'JMP':0x8,'JN':0x9,'JZ':0xA,'HLT':0xF}
ONE = {'NOP','NOT','HLT'}

def montar(prog, dados):
    mem = [0]*16; a = 0
    for ins in prog:
        mem[a] = OP[ins[0]] << 4; a += 1
        if ins[0] not in ONE:
            mem[a] = ins[1]; a += 1
    for end, v in dados.items(): mem[end] = v
    assert a <= 16
    return mem

def executar(mem):
    mem = mem[:]; pc = ac = 0; n = z = 0; trace = []; ciclos = 0
    while True:
        trace.append((pc, ac, n, z))
        op = mem[pc] >> 4; pc = (pc + 1) & 0xFF
        if op == 0xF: ciclos += 4; break
        if op == 0x0: ciclos += 4; continue
        if op == 0x6:
            ac = (~ac) & 0xFF; n = ac >> 7; z = int(ac == 0); ciclos += 4; continue
        end = mem[pc] & 0xF; pc = (pc + 1) & 0xFF
        if op in (0x8, 0x9, 0xA):
            tom = op == 0x8 or (op == 0x9 and n) or (op == 0xA and z)
            if tom: pc = end; ciclos += 6
            else: ciclos += 4
            continue
        ciclos += 8
        if op == 0x1: mem[end] = ac; continue
        v = mem[end]
        ac = {0x2: v, 0x3: (ac+v) & 0xFF, 0x4: ac | v, 0x5: ac & v}[op]
        n = ac >> 7; z = int(ac == 0)
    return mem, pc, ac, n, z, trace, ciclos

def hex128(mem): return '128\'h' + '_'.join('%02X%02X' % (mem[i+1], mem[i]) for i in range(14, -1, -2))

PROGRAMAS = {
 'P1_exemplo_do_guia': ([('LDA',0x0E),('NOT',),('ADD',0x0F),('JN',0x08),('HLT',),('STA',0x0F),('NOT',),('NOT',),('NOP',),('HLT',)],
                        {0x0E:0x05, 0x0F:0x01}),
 'P2_AND_OR_JZ_tomado': ([('LDA',0x0E),('AND',0x0F),('JZ',0x08),('NOP',),('NOP',),('OR',0x0F),('JN',0x0D),('HLT',)] ,
                        {0x0E:0xF0, 0x0F:0x0F}),
 'P3_ADD_JMP_JZ_nao_tomado': ([('LDA',0x0E),('ADD',0x0F),('JMP',0x08),('HLT',),('STA',0x0F),('NOT',),('JZ',0x0D),('HLT',)],
                        {0x0E:0xFF, 0x0F:0x01}),
}
# P2/P3 precisam de enderecos exatos: ajustar posicoes manualmente (ver montagem abaixo)

def montar_p2():
    m = [0]*16
    m[0:2]=[0x20,0x0E]; m[2:4]=[0x50,0x0F]; m[4:6]=[0xA0,0x08]; m[6]=0xF0; m[7]=0xF0
    m[8:10]=[0x40,0x0F]; m[10:12]=[0x90,0x0D]; m[12]=0xF0; m[14]=0xF0; m[15]=0x0F
    m[14]=0xF0; m[15]=0x0F
    return m
def montar_p3():
    m = [0]*16
    m[0:2]=[0x20,0x0E]; m[2:4]=[0x30,0x0F]; m[4:6]=[0x80,0x08]; m[6]=0xF0; m[7]=0xF0
    m[8:10]=[0x10,0x0F]; m[10]=0x60; m[11:13]=[0xA0,0x0D]; m[13]=0xF0; m[14]=0xFF; m[15]=0x01
    return m

if __name__ == '__main__':
    p1 = montar([('LDA',0x0E),('NOT',),('ADD',0x0F),('JN',0x08),('HLT',),('STA',0x0F),('NOT',),('NOT',),('NOP',),('HLT',)],{0x0E:0x05,0x0F:0x01})
    # P2: dados em E (F0) e F (0F) -> reposiciona
    p2 = montar_p2(); p2[14]=0xF0; p2[15]=0x0F
    p3 = montar_p3()
    progs = [('P1 exemplo do guia', p1), ('P2 AND/OR/JZ tomado/JN nao tomado', p2), ('P3 ADD/JMP/STA/JZ nao tomado', p3)]
    out = []
    out.append('// GERADO por gen_referencia.py - testbench auto-verificavel (comportamental, so para teste)')
    out.append('`timescale 1ns/1ps')
    out.append('''module tb_prog #(parameter [127:0] PROG = 0, parameter [7:0] EXP_AC = 0, parameter EXP_N = 0,
  parameter EXP_Z = 0, parameter [7:0] EXP_PC = 0, parameter [127:0] EXP_MEM = 0,
  parameter integer NTRACE = 0, parameter [511:0] EXP_TRACE = 0, parameter integer MAXCYC = 300,
  parameter integer EXP_CICLOS = 0, parameter integer ID = 0, parameter VERBOSE = 1)
  (output reg done, output reg pass);
  reg clk = 0, reset = 1;
  wire [7:0] pc, ac, ri, t; wire n, z, halt; wire [127:0] mem;
  neander_top #(.MEM_INIT(PROG)) dut(clk, reset, pc, ac, ri, n, z, t, halt, mem);
  always #5 clk = ~clk;
  integer k = 0, erros = 0, ciclos = 0;
  reg [23:0] e;
  reg rodando = 0;
  // trace: em cada t0 (meio do ciclo) compara PC, AC, N, Z
  always @(negedge clk) if (rodando && t[0] && !halt) begin
    e = EXP_TRACE[24*k +: 24];
    if (VERBOSE) $display("  [%0d] t0 #%0d: PC=%02h AC=%02h N=%b Z=%b", ID, k, pc, ac, n, z);
    if (k >= NTRACE || {pc, ac, n, z} !== {e[23:16], e[15:8], e[1], e[0]}) begin
      erros = erros + 1;
      $display("  [%0d] ERRO no trace #%0d: obtido PC=%02h AC=%02h N=%b Z=%b | esperado PC=%02h AC=%02h N=%b Z=%b",
               ID, k, pc, ac, n, z, e[23:16], e[15:8], e[1], e[0]);
    end
    k = k + 1;
  end
  always @(posedge clk) if (rodando) ciclos = ciclos + 1;
  initial begin
    done = 0; pass = 0;
    repeat (3) @(posedge clk);
    #1 reset = 0; rodando = 1;
    while (!halt && ciclos < MAXCYC) @(posedge clk);
    repeat (4) @(posedge clk);          // halt deve manter tudo estavel
    #1;
    if (!halt) begin erros = erros + 1; $display("  [%0d] ERRO: nao chegou ao HLT (timeout)", ID); end
    if (k !== NTRACE) begin erros = erros + 1; $display("  [%0d] ERRO: %0d instrucoes no trace, esperado %0d", ID, k, NTRACE); end
    if (ac !== EXP_AC || n !== EXP_N || z !== EXP_Z || pc !== EXP_PC) begin
      erros = erros + 1; $display("  [%0d] ERRO final: AC=%02h N=%b Z=%b PC=%02h | esperado AC=%02h N=%b Z=%b PC=%02h", ID, ac, n, z, pc, EXP_AC, EXP_N, EXP_Z, EXP_PC);
    end
    if (mem !== EXP_MEM) begin erros = erros + 1; $display("  [%0d] ERRO na memoria final: %h | esperado %h", ID, mem, EXP_MEM); end
    pass = (erros == 0); done = 1;
  end
endmodule
''')
    inst = []; names = []
    for i, (nome, mem) in enumerate(progs):
        m, pc, ac, n, z, trace, ciclos = executar(mem)
        names.append(nome)
        tr = 0
        for k, (a, b, c, d) in enumerate(trace): tr |= ((a << 16) | (b << 8) | (c << 1) | d) << (24*k)
        print(nome, '| instrucoes:', len(trace), '| ciclos:', ciclos, '| AC=%02X N=%d Z=%d PC=%02X' % (ac, n, z, pc))
        print('  MEM_INIT =', hex128(mem), ' final =', hex128(m))
        inst.append('  tb_prog #(.PROG(%s), .EXP_AC(8\'h%02X), .EXP_N(%d), .EXP_Z(%d), .EXP_PC(8\'h%02X), .EXP_MEM(%s),\n'
                    '            .NTRACE(%d), .EXP_TRACE(512\'h%x), .ID(%d), .VERBOSE(%d)) t%d(d[%d], p[%d]);'
                    % (hex128(mem), ac, n, z, pc, hex128(m), len(trace), tr, i+1, 1 if i == 0 else 0, i, i, i))
    out.append('module tb_neander;')
    out.append('  wire [2:0] d, p;')
    out += inst
    out.append('  integer i;')
    out.append('  initial begin')
    out.append('    $dumpfile("neander.vcd"); $dumpvars(0, tb_neander.t0);')
    out.append('    wait (d === 3\'b111);')
    out.append('    #1;')
    for i, nm in enumerate(names):
        out.append('    $display("%s: %%s", p[%d] ? "PASSOU" : "FALHOU");' % (nm, i))
    out.append('    if (p === 3\'b111) $display("\\n*** TODOS OS PROGRAMAS PASSARAM ***"); else $display("\\n*** HA FALHAS ***");')
    out.append('    $finish;')
    out.append('  end')
    out.append('  initial begin #200000; $display("TIMEOUT GLOBAL"); $finish; end')
    out.append('endmodule')
    open('tb/tb_neander.v', 'w').write('\n'.join(out) + '\n')
