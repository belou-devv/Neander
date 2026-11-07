// =============================================================
// ram16x8.v - Memoria RAM 16 x 8 (Membro 3)
// Banco de 16 registradores, decodificador 4->16 e seletor AND-OR.
// RESET (sincrono) grava o programa inicial INIT (byte i = INIT[8*i +: 8]).
// Escrita sincrona (borda de subida) quando write = 1.
// Leitura combinacional; dout = 0 quando read = 0.
// =============================================================
`timescale 1ns/1ps

// Bit de memoria: d_ef = reset ? INIT : (we ? din : q)
module bit_ram #(parameter INIT = 0)
  (input clk, input reset, input we, input din, output q);
  wire m, def, nreset;
  mux2_1 um(q, din, we, m);
  generate
    if (INIT == 0) begin : z
      not1 un(reset, nreset);
      and2 ua(m, nreset, def);
    end else begin : u
      or2  uo(m, reset, def);
    end
  endgenerate
  dff uf(clk, def, q);
endmodule

module ram16x8 #(parameter [127:0] INIT = 128'h0)
  (input clk, input reset, input [3:0] addr, input [7:0] din,
   input read, input write, output [7:0] dout, output [127:0] dbg_mem);

  wire [3:0] a, na;
  genvar i, b;
  generate for (i = 0; i < 4; i = i + 1) begin : inv
    not1 u(addr[i], na[i]);
    assign a[i] = addr[i];
  end endgenerate

  // decodificador 4 -> 16
  wire [15:0] sel;
  generate for (i = 0; i < 16; i = i + 1) begin : dec
    and4 u(i[3] ? a[3] : na[3], i[2] ? a[2] : na[2],
           i[1] ? a[1] : na[1], i[0] ? a[0] : na[0], sel[i]);
  end endgenerate

  // 16 bytes
  wire [7:0] q [0:15];
  wire [15:0] we;
  generate for (i = 0; i < 16; i = i + 1) begin : byte_i
    and2 uw(write, sel[i], we[i]);
    for (b = 0; b < 8; b = b + 1) begin : bit_b
      bit_ram #(.INIT(INIT[8*i+b])) c(clk, reset, we[i], din[b], q[i][b]);
    end
    assign dbg_mem[8*i +: 8] = q[i];
  end endgenerate

  // leitura: AND-OR por bit, habilitada por read
  generate for (b = 0; b < 8; b = b + 1) begin : rd
    wire [15:0] t;
    wire o;
    for (i = 0; i < 16; i = i + 1) begin : tt
      and2 u(sel[i], q[i][b], t[i]);
    end
    or16 uo(t, o);
    and2 ur(o, read, dout[b]);
  end endgenerate
endmodule
