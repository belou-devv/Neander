// =============================================================
// neander_top.v - Processador Neander completo (Membro 5)
// MEM_INIT: conteudo inicial da RAM (byte i = MEM_INIT[8*i +: 8]).
// Padrao: programa de exemplo do guia (ver tb/).
// =============================================================
`timescale 1ns/1ps
module neander_top #(parameter [127:0] MEM_INIT =
    128'h0105_F000_6060_0F10_F008_900F_3060_0E20)
  (input clk, input reset,
   // depuracao
   output [7:0] pc, output [7:0] ac, output [7:0] ri, output n, output z,
   output [7:0] t, output halt, output [127:0] dbg_mem);

  wire [7:0] rdm_q, rem_in, rem_q, mem_dout, ual_out;
  wire ual_n, ual_z;
  wire sel, cargaREM, cargaRDM, cargaRI, cargaAC, cargaNZ, cargaPC, incrementaPC;
  wire read, write, goto_t0;
  wire [2:0] selUAL;
  wire i_nop, i_sta, i_lda, i_add, i_or, i_and, i_not, i_jmp, i_jn, i_jz, i_hlt;

  pc8     u_pc  (clk, reset, cargaPC, incrementaPC, rdm_q, pc);
  mux2x8  u_mux (pc, rdm_q, sel, rem_in);
  reg8    u_rem (clk, reset, cargaREM, rem_in, rem_q);
  ram16x8 #(.INIT(MEM_INIT)) u_ram (clk, reset, rem_q[3:0], rdm_q, read, write, mem_dout, dbg_mem);
  rdm     u_rdm (clk, reset, read, cargaRDM, mem_dout, ac, rdm_q);
  reg8    u_ac  (clk, reset, cargaAC, ual_out, ac);
  ual     u_ual (ac, rdm_q, selUAL, ual_out, ual_n, ual_z);
  regnz   u_nz  (clk, reset, cargaNZ, ual_n, ual_z, n, z);
  reg8    u_ri  (clk, reset, cargaRI, rdm_q, ri);
  decod_opcode u_dec(ri[7:4], i_nop, i_sta, i_lda, i_add, i_or, i_and, i_not, i_jmp, i_jn, i_jz, i_hlt);

  gerador_tempo u_t(clk, reset, goto_t0, halt, t);
  unidade_controle u_uc(t, i_nop, i_sta, i_lda, i_add, i_or, i_and, i_not, i_jmp, i_jn, i_jz, i_hlt,
                        n, z, sel, cargaREM, cargaRDM, cargaRI, cargaAC, cargaNZ, cargaPC,
                        incrementaPC, read, write, selUAL, goto_t0, halt);
endmodule
