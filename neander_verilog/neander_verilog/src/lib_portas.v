// =============================================================
// lib_portas.v - Biblioteca de portas (Membro 1)
// Tudo e construido SOMENTE com as primitivas nand, nor e not.
// Convencao: portas de entrada primeiro, saida por ultimo (y).
// =============================================================
`timescale 1ns/1ps

module not1(input a, output y);
  not (y, a);
endmodule

module nand2(input a, input b, output y);
  nand (y, a, b);
endmodule

module nor2(input a, input b, output y);
  nor (y, a, b);
endmodule

module and2(input a, input b, output y);
  wire n;
  nand (n, a, b);
  not  (y, n);
endmodule

module and3(input a, input b, input c, output y);
  wire n;
  nand (n, a, b, c);
  not  (y, n);
endmodule

module and4(input a, input b, input c, input d, output y);
  wire n;
  nand (n, a, b, c, d);
  not  (y, n);
endmodule

module or2(input a, input b, output y);
  wire n;
  nor (n, a, b);
  not (y, n);
endmodule

module or3(input a, input b, input c, output y);
  wire n;
  nor (n, a, b, c);
  not (y, n);
endmodule

module or4(input a, input b, input c, input d, output y);
  wire n;
  nor (n, a, b, c, d);
  not (y, n);
endmodule

// XOR com 4 NANDs
module xor2(input a, input b, output y);
  wire n1, n2, n3;
  nand (n1, a, b);
  nand (n2, a, n1);
  nand (n3, b, n1);
  nand (y,  n2, n3);
endmodule

// Multiplexador 2:1 de 1 bit: y = s ? b : a
module mux2_1(input a, input b, input s, output y);
  wire ns, n1, n2;
  not  (ns, s);
  nand (n1, a, ns);
  nand (n2, b, s);
  nand (y,  n1, n2);
endmodule

// z = 1 quando os 8 bits sao zero
module nor8(input [7:0] a, output y);
  wire lo, hi;
  or4 u0(a[0], a[1], a[2], a[3], lo);
  or4 u1(a[4], a[5], a[6], a[7], hi);
  nor (y, lo, hi);
endmodule

// OR de 16 entradas (arvore de or4)
module or16(input [15:0] a, output y);
  wire [3:0] g;
  or4 u0(a[0],  a[1],  a[2],  a[3],  g[0]);
  or4 u1(a[4],  a[5],  a[6],  a[7],  g[1]);
  or4 u2(a[8],  a[9],  a[10], a[11], g[2]);
  or4 u3(a[12], a[13], a[14], a[15], g[3]);
  or4 u4(g[0], g[1], g[2], g[3], y);
endmodule
