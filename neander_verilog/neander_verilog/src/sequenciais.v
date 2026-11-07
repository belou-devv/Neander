// =============================================================
// sequenciais.v - latch, flip-flop e registradores (Membro 2)
// Apenas nand/not + modulos da lib_portas.v
// Clock: borda de subida.  Reset: SINCRONO, ativo em 1.
// =============================================================
`timescale 1ns/1ps

// Latch D transparente enquanto e = 1 (feito com NANDs)
module dlatch(input d, input e, output q, output qn);
  wire nd, s, r;
  not  (nd, d);
  nand (s, d,  e);
  nand (r, nd, e);
  nand (q,  s, qn);
  nand (qn, r, q);
endmodule

// Flip-flop D mestre-escravo, dispara na borda de subida
module dff(input clk, input d, output q);
  wire nclk, qm, qmn, qn;
  not (nclk, clk);
  dlatch master(d,  nclk, qm, qmn);   // transparente com clk = 0
  dlatch slave (qm, clk,  q,  qn);    // transparente com clk = 1
endmodule

// FF com reset sincrono: q <= reset ? 0 : d
module ff_r(input clk, input reset, input d, output q);
  wire nreset, def;
  not1 u0(reset, nreset);
  and2 u1(d, nreset, def);
  dff  u2(clk, def, q);
endmodule

// 1 bit com carga: q <= reset ? 0 : (load ? d : q)
module reg1(input clk, input reset, input load, input d, output q);
  wire m;
  mux2_1 um(q, d, load, m);
  ff_r   uf(clk, reset, m, q);
endmodule

// Registrador de 8 bits com carga paralela (AC, REM, RI)
module reg8(input clk, input reset, input load, input [7:0] d, output [7:0] q);
  genvar i;
  generate for (i = 0; i < 8; i = i + 1) begin : b
    reg1 r(clk, reset, load, d[i], q[i]);
  end endgenerate
endmodule

// RDM: carrega da RAM (read) ou do AC (cargaRDM)
module rdm(input clk, input reset, input read, input cargaRDM,
           input [7:0] mem_dout, input [7:0] ac, output [7:0] q);
  wire [7:0] din;
  wire load;
  mux2x8 um(mem_dout, ac, cargaRDM, din);
  or2    ul(read, cargaRDM, load);
  reg8   ur(clk, reset, load, din, q);
endmodule

// Flags N e Z
module regnz(input clk, input reset, input cargaNZ, input n_in, input z_in,
             output n, output z);
  reg1 rn(clk, reset, cargaNZ, n_in, n);
  reg1 rz(clk, reset, cargaNZ, z_in, z);
endmodule

// PC: contador de 8 bits com carga paralela e incremento
// prioridade: reset > cargaPC > incrementaPC
module pc8(input clk, input reset, input cargaPC, input incrementaPC,
           input [7:0] d, output [7:0] q);
  wire [8:0] c;           // c[i] = 1 se todos os bits abaixo de i valem 1
  assign c[0] = 1'b1;
  genvar i;
  generate for (i = 0; i < 8; i = i + 1) begin : b
    wire tg, nx, ld;
    and2   a (incrementaPC, c[i], tg);       // bit inverte?
    xor2   x (q[i], tg, nx);
    mux2_1 m (nx, d[i], cargaPC, ld);
    ff_r   f (clk, reset, ld, q[i]);
    and2   cc(c[i], q[i], c[i+1]);
  end endgenerate
endmodule
