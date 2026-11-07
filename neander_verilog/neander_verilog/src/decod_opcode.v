// decod_opcode.v - Decodificador de instrucao (Membro 1)
// opcode invalido -> tratado como NOP (a FSM nunca trava)
`timescale 1ns/1ps
module decod_opcode(input [3:0] opcode,
  output i_nop, output i_sta, output i_lda, output i_add, output i_or,
  output i_and, output i_not, output i_jmp, output i_jn, output i_jz, output i_hlt);
  wire [3:0] o, no;
  genvar k;
  generate for (k = 0; k < 4; k = k + 1) begin : inv
    not1 u(opcode[k], no[k]);
    assign o[k] = opcode[k];
  end endgenerate

  and4 d_sta(no[3], no[2], no[1], o[0],  i_sta);  // 0001
  and4 d_lda(no[3], no[2], o[1],  no[0], i_lda);  // 0010
  and4 d_add(no[3], no[2], o[1],  o[0],  i_add);  // 0011
  and4 d_or (no[3], o[2],  no[1], no[0], i_or);   // 0100
  and4 d_and(no[3], o[2],  no[1], o[0],  i_and);  // 0101
  and4 d_not(no[3], o[2],  o[1],  no[0], i_not);  // 0110
  and4 d_jmp(o[3],  no[2], no[1], no[0], i_jmp);  // 1000
  and4 d_jn (o[3],  no[2], no[1], o[0],  i_jn);   // 1001
  and4 d_jz (o[3],  no[2], o[1],  no[0], i_jz);   // 1010
  and4 d_hlt(o[3],  o[2],  o[1],  o[0],  i_hlt);  // 1111

  wire a1, a2, a3, a4;
  or4 u1(i_sta, i_lda, i_add, i_or,  a1);
  or4 u2(i_and, i_not, i_jmp, i_jn,  a2);
  or2 u3(i_jz, i_hlt, a3);
  or3 u4(a1, a2, a3, a4);
  not1 u5(a4, i_nop);             // NOP + qualquer codigo invalido
endmodule
