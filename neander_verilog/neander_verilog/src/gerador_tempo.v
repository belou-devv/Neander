// gerador_tempo.v - contador de tempo t0..t7 (Membro 4)
// proximo = reset|goto_t0 ? 0 : (halt ? mantem : +1)
`timescale 1ns/1ps
module gerador_tempo(input clk, input reset, input goto_t0, input halt,
                     output [7:0] t);
  wire [2:0] q, inc, hold, nx;
  wire ngoto;
  // +1 em 3 bits
  not1 i0(q[0], inc[0]);
  xor2 i1(q[1], q[0], inc[1]);
  wire c1;
  and2 ac(q[1], q[0], c1);
  xor2 i2(q[2], c1, inc[2]);
  // halt mantem o valor
  genvar k;
  not1 ng(goto_t0, ngoto);
  generate for (k = 0; k < 3; k = k + 1) begin : b
    wire m;
    mux2_1 um(inc[k], q[k], halt, m);
    and2   ua(m, ngoto, nx[k]);
    ff_r   uf(clk, reset, nx[k], q[k]);
  end endgenerate
  // decodificador 3 -> 8
  wire [2:0] nq;
  not1 n0(q[0], nq[0]); not1 n1(q[1], nq[1]); not1 n2(q[2], nq[2]);
  and3 t0(nq[2], nq[1], nq[0], t[0]);
  and3 t1(nq[2], nq[1], q[0],  t[1]);
  and3 t2(nq[2], q[1],  nq[0], t[2]);
  and3 t3(nq[2], q[1],  q[0],  t[3]);
  and3 t4(q[2],  nq[1], nq[0], t[4]);
  and3 t5(q[2],  nq[1], q[0],  t[5]);
  and3 t6(q[2],  q[1],  nq[0], t[6]);
  and3 t7(q[2],  q[1],  q[0],  t[7]);
endmodule
