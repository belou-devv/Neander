// mux2x8.v - Multiplexador 2:1 de 8 bits (Membro 1)
// sel = 0 -> a ; sel = 1 -> b
`timescale 1ns/1ps
module mux2x8(input [7:0] a, input [7:0] b, input sel, output [7:0] y);
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : g
      mux2_1 m(a[i], b[i], sel, y[i]);
    end
  endgenerate
endmodule
