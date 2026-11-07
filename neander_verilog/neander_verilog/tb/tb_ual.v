`timescale 1ns/1ps
// Teste da UAL contra modelo comportamental (so na testbench) - 5 ops x 65536 pares amostrados
module tb_ual;
  reg [7:0] x, y; reg [2:0] s; wire [7:0] o; wire n, z;
  ual dut(x, y, s, o, n, z);
  reg [7:0] exp; integer i, j, erros = 0, op;
  initial begin
    for (op = 0; op < 8; op = op + 1)
      for (i = 0; i < 256; i = i + 1)
        for (j = 0; j < 256; j = j + 7) begin
          s = op; x = i; y = j; #1;
          case (op)
            0: exp = x + y; 1: exp = x & y; 2: exp = x | y; 3: exp = ~x; 4: exp = y; default: exp = 0;
          endcase
          if (o !== exp || n !== exp[7] || z !== (exp == 0)) begin
            erros = erros + 1;
            if (erros < 5) $display("ERRO sel=%0d x=%h y=%h out=%h n=%b z=%b (esp %h)", op, x, y, o, n, z, exp);
          end
        end
    if (erros == 0) $display("tb_ual: PASSOU"); else $display("tb_ual: FALHOU (%0d erros)", erros);
    $finish;
  end
endmodule
