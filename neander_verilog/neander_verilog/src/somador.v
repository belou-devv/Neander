// somador.v - meio somador, somador completo e somador 8 bits (Membro 1)
`timescale 1ns/1ps
module meio_somador(input a, input b, output s, output c);
  xor2 ux(a, b, s);
  and2 ua(a, b, c);
endmodule

module somador_completo(input a, input b, input cin, output s, output cout);
  wire s1, c1, c2;
  meio_somador h1(a, b, s1, c1);
  meio_somador h2(s1, cin, s, c2);
  or2 uo(c1, c2, cout);
endmodule

// Ripple-carry. O carry final e descartado (Neander nao tem flag C).
module somador8(input [7:0] a, input [7:0] b, output [7:0] s);
  wire [8:0] c;
  wire c0n;
  not (c0n, 1'b1);               // constante 0 obtida com porta
  assign c[0] = c0n;
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : fa
      somador_completo u(a[i], b[i], c[i], s[i], c[i+1]);
    end
  endgenerate
endmodule
