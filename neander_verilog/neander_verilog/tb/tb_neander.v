// GERADO por gen_referencia.py - testbench auto-verificavel (comportamental, so para teste)
`timescale 1ns/1ps
module tb_prog #(parameter [127:0] PROG = 0, parameter [7:0] EXP_AC = 0, parameter EXP_N = 0,
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

module tb_neander;
  wire [2:0] d, p;
  tb_prog #(.PROG(128'h0105_F000_6060_0F10_F008_900F_3060_0E20), .EXP_AC(8'hFB), .EXP_N(1), .EXP_Z(0), .EXP_PC(8'h0E), .EXP_MEM(128'hFB05_F000_6060_0F10_F008_900F_3060_0E20),
            .NTRACE(9), .EXP_TRACE(512'hdfb020cfb020b04000afb0208fb0205fb0203fa02020500000000), .ID(1), .VERBOSE(1)) t0(d[0], p[0]);
  tb_prog #(.PROG(128'h0FF0_00F0_0D90_0F40_F0F0_08A0_0F50_0E20), .EXP_AC(8'h0F), .EXP_N(0), .EXP_Z(0), .EXP_PC(8'h0D), .EXP_MEM(128'h0FF0_00F0_0D90_0F40_F0F0_08A0_0F50_0E20),
            .NTRACE(6), .EXP_TRACE(512'hc0f000a0f0008000104000102f002000000), .ID(2), .VERBOSE(0)) t1(d[1], p[1]);
  tb_prog #(.PROG(128'h01FF_F00D_A060_0F10_F0F0_0880_0F30_0E20), .EXP_AC(8'hFF), .EXP_N(1), .EXP_Z(0), .EXP_PC(8'h0E), .EXP_MEM(128'h00FF_F00D_A060_0F10_F0F0_0880_0F30_0E20),
            .NTRACE(7), .EXP_TRACE(512'hdff020bff020a000108000104000102ff02000000), .ID(3), .VERBOSE(0)) t2(d[2], p[2]);
  integer i;
  initial begin
    $dumpfile("neander.vcd"); $dumpvars(0, tb_neander.t0);
    wait (d === 3'b111);
    #1;
    $display("P1 exemplo do guia: %s", p[0] ? "PASSOU" : "FALHOU");
    $display("P2 AND/OR/JZ tomado/JN nao tomado: %s", p[1] ? "PASSOU" : "FALHOU");
    $display("P3 ADD/JMP/STA/JZ nao tomado: %s", p[2] ? "PASSOU" : "FALHOU");
    if (p === 3'b111) $display("\n*** TODOS OS PROGRAMAS PASSARAM ***"); else $display("\n*** HA FALHAS ***");
    $finish;
  end
  initial begin #200000; $display("TIMEOUT GLOBAL"); $finish; end
endmodule
