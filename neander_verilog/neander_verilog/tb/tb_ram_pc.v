`timescale 1ns/1ps
// Teste da RAM (escrita/leitura dos 16 enderecos, reset, read=0) e do PC (carga/incremento/wrap)
module tb_ram_pc;
  reg clk = 0, reset = 1, read = 0, write = 0; reg [3:0] addr = 0; reg [7:0] din = 0;
  wire [7:0] dout; wire [127:0] mem;
  ram16x8 #(.INIT(128'h0F0E_0D0C_0B0A_0908_0706_0504_0302_0100)) ram(clk, reset, addr, din, read, write, dout, mem);
  reg cpc = 0, ipc = 0; reg [7:0] dpc = 0; wire [7:0] pcq;
  pc8 pc(clk, reset, cpc, ipc, dpc, pcq);
  always #5 clk = ~clk;
  integer i, erros = 0;
  task chk(input cond, input [255:0] msg); begin if (!cond) begin erros = erros + 1; $display("ERRO: %0s", msg); end end endtask
  initial begin
    repeat (3) @(posedge clk); #1 reset = 0;
    chk(mem === 128'h0F0E_0D0C_0B0A_0908_0706_0504_0302_0100, "reset carrega programa");
    chk(pcq === 8'h00, "PC zerado");
    read = 1;
    for (i = 0; i < 16; i = i + 1) begin addr = i; #1 chk(dout === i[7:0], "leitura init"); end
    read = 0; #1 chk(dout === 8'h00, "read=0 -> dout=0");
    // escreve valor distinto em cada endereco
    for (i = 0; i < 16; i = i + 1) begin addr = i; din = 8'hA0 + i; write = 1; @(posedge clk); #1 write = 0; end
    read = 1;
    for (i = 0; i < 16; i = i + 1) begin addr = i; #1 chk(dout === 8'hA0 + i, "escrita/leitura"); end
    // reset tem prioridade sobre write
    reset = 1; write = 1; addr = 3; din = 8'hEE; @(posedge clk); #1 reset = 0; write = 0;
    chk(mem === 128'h0F0E_0D0C_0B0A_0908_0706_0504_0302_0100, "reset restaura programa");
    // PC
    ipc = 1; repeat (3) @(posedge clk); #1 ipc = 0; chk(pcq === 8'h03, "PC +3");
    dpc = 8'hFE; cpc = 1; @(posedge clk); #1 cpc = 0; chk(pcq === 8'hFE, "PC carga");
    ipc = 1; @(posedge clk); #1 chk(pcq === 8'hFF, "PC FF"); @(posedge clk); #1 chk(pcq === 8'h00, "PC wrap"); ipc = 0;
    @(posedge clk); #1 chk(pcq === 8'h00, "PC mantem");
    if (erros == 0) $display("tb_ram_pc: PASSOU"); else $display("tb_ram_pc: FALHOU (%0d erros)", erros);
    $finish;
  end
endmodule
