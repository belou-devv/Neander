// =============================================================
// unidade_controle.v - Unidade de Controle (Membro 4)
// Equacoes das Tabelas 10.3 / 10.4 (organizacao do Neander).
// MEMOP  = STA+LDA+ADD+OR+AND      TOMADO  = JMP + JN.N + JZ.Z
// LDAOP  = LDA+ADD+OR+AND          NTOMADO = JN.N' + JZ.Z'
// Em t0,t1,t2 nenhuma equacao depende de i_* (RI so vale a partir de t3).
// =============================================================
`timescale 1ns/1ps
module unidade_controle(
  input [7:0] t,
  input i_nop, i_sta, i_lda, i_add, i_or, i_and, i_not, i_jmp, i_jn, i_jz, i_hlt,
  input n, input z,
  output sel, output cargaREM, output cargaRDM, output cargaRI, output cargaAC,
  output cargaNZ, output cargaPC, output incrementaPC, output read, output write,
  output [2:0] selUAL, output goto_t0, output halt);

  wire nn, nz;
  not1 un(n, nn);
  not1 uz(z, nz);

  // grupos
  wire m1, memop, ldaop, jn_n, jz_z, tomado, jn_nn, jz_nz, ntomado, mem_or_tom;
  or4  g1(i_sta, i_lda, i_add, i_or, m1);
  or2  g2(m1, i_and, memop);
  or4  g3(i_lda, i_add, i_or, i_and, ldaop);
  and2 g4(i_jn, n,  jn_n);
  and2 g5(i_jz, z,  jz_z);
  or3  g6(i_jmp, jn_n, jz_z, tomado);
  and2 g7(i_jn, nn, jn_nn);
  and2 g8(i_jz, nz, jz_nz);
  or2  g9(jn_nn, jz_nz, ntomado);
  or2  g10(memop, tomado, mem_or_tom);

  // cargaREM = t0 + t3.(MEMOP+TOMADO) + t5.MEMOP
  wire a1, a2;
  and2 c1(t[3], mem_or_tom, a1);
  and2 c2(t[5], memop, a2);
  or3  c3(t[0], a1, a2, cargaREM);

  // incrementaPC = t1 + t4.MEMOP + t3.NTOMADO
  wire b1, b2;
  and2 d1(t[4], memop, b1);
  and2 d2(t[3], ntomado, b2);
  or3  d3(t[1], b1, b2, incrementaPC);

  assign cargaRI = t[2];

  and2 e1(t[5], memop, sel);
  and2 e2(t[6], i_sta, cargaRDM);

  // read = t1 + t4.(MEMOP+TOMADO) + t6.LDAOP
  wire r1, r2;
  and2 f1(t[4], mem_or_tom, r1);
  and2 f2(t[6], ldaop, r2);
  or3  f3(t[1], r1, r2, read);

  and2 w1(t[7], i_sta, write);

  // UAL
  wire u_y, u_add, u_or, u_and, u_not, x1;
  and2 h1(t[7], i_lda, u_y);
  and2 h2(t[7], i_add, u_add);
  and2 h3(t[7], i_or,  u_or);
  and2 h4(t[7], i_and, u_and);
  and2 h5(t[3], i_not, u_not);
  assign selUAL[2] = u_y;
  or2  h6(u_or,  u_not, selUAL[1]);
  or2  h7(u_and, u_not, selUAL[0]);

  // cargaAC = cargaNZ = t7.LDAOP + t3.NOT
  wire k1;
  and2 k0(t[7], ldaop, k1);
  or2  k2(k1, u_not, cargaAC);
  assign cargaNZ = cargaAC;

  and2 p1(t[5], tomado, cargaPC);

  // goto_t0 = t7.MEMOP + t3.(NOP+NOT+NTOMADO) + t5.TOMADO
  wire g_a, g_b, g_c, g_d;
  and2 q1(t[7], memop, g_a);
  or3  q2(i_nop, i_not, ntomado, g_b);
  and2 q3(t[3], g_b, g_c);
  and2 q4(t[5], tomado, g_d);
  or3  q5(g_a, g_c, g_d, goto_t0);

  and2 s1(t[3], i_hlt, halt);
endmodule
