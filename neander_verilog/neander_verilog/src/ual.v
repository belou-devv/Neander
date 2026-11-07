// ual.v - Unidade Aritmetica e Logica (Membro 1)
// selUAL: 000 X+Y | 001 X AND Y | 010 X OR Y | 011 NOT X | 100 Y
// Codigos 101,110,111 -> saida 0.  X = AC, Y = RDM.
// n = out[7]; z = 1 se out == 0
`timescale 1ns/1ps
module ual(input [7:0] x, input [7:0] y, input [2:0] selUAL,
           output [7:0] out, output n, output z);
  wire [7:0] soma, r_and, r_or, r_not;
  wire s2n, s1n, s0n;
  wire en_add, en_and, en_or, en_not, en_y;

  somador8 uadd(x, y, soma);

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : bits
      wire t1, t2, t3, t4, t5, o1, o2;
      and2 ua(x[i], y[i], r_and[i]);
      or2  uo(x[i], y[i], r_or[i]);
      not1 un(x[i], r_not[i]);
      and2 a1(en_add, soma[i],  t1);
      and2 a2(en_and, r_and[i], t2);
      and2 a3(en_or,  r_or[i],  t3);
      and2 a4(en_not, r_not[i], t4);
      and2 a5(en_y,   y[i],     t5);
      or3  b1(t1, t2, t3, o1);
      or2  b2(t4, t5, o2);
      or2  b3(o1, o2, out[i]);
    end
  endgenerate

  not1 ns2(selUAL[2], s2n);
  not1 ns1(selUAL[1], s1n);
  not1 ns0(selUAL[0], s0n);
  and3 d0(s2n, s1n, s0n,          en_add);
  and3 d1(s2n, s1n, selUAL[0],    en_and);
  and3 d2(s2n, selUAL[1], s0n,    en_or);
  and3 d3(s2n, selUAL[1], selUAL[0], en_not);
  and3 d4(selUAL[2], s1n, s0n,    en_y);

  wire nn;
  // flags
  not1 un7(out[7], nn);          // nn = ~out[7]
  not1 un8(nn, n);               // n = out[7]
  nor8 uz(out, z);
endmodule
