module asmtest(input clk, input rst, input [29:0] addr, output reg [31:0] inst);
reg [29:0] addr_r;
always @(posedge clk)
begin
addr_r <= (rst) ? (30'b0) : (addr);
end
always @(*)
begin
case(addr_r)
30'h00000000: inst = 32'h3c088000;
30'h00000001: inst = 32'h35080004;
30'h00000002: inst = 32'h8d090000;
30'h00000003: inst = 32'h00000000;
30'h00000004: inst = 32'h3c088000;
30'h00000005: inst = 32'h3508000c;
30'h00000006: inst = 32'h8d0a0000;
30'h00000007: inst = 32'h00000000;
30'h00000008: inst = 32'h3c088000;
30'h00000009: inst = 32'h8d0b0000;
30'h0000000a: inst = 32'h00000000;
30'h0000000b: inst = 32'h3c088000;
30'h0000000c: inst = 32'h35080008;
30'h0000000d: inst = 32'h240200bf;
30'h0000000e: inst = 32'had020000;
default:      inst = 32'h00000000;
endcase
end
endmodule
