module gpcode(input clk, input rst, input [29:0] addr, output reg [31:0] inst);
reg [29:0] addr_r;
always @(posedge clk)
begin
addr_r <= (rst) ? (30'b0) : (addr);
end
always @(*)
begin
case(addr_r)
30'h00000000: inst = 32'h3c1d1000;
30'h00000001: inst = 32'h37bd4000;
30'h00000002: inst = 32'h3c081780;
30'h00000003: inst = 32'h3c090100;
30'h00000004: inst = 32'had090000;
30'h00000005: inst = 32'h3c090200;
30'h00000006: inst = 32'h352900ff;
30'h00000007: inst = 32'had090004;
30'h00000008: inst = 32'h3c090010;
30'h00000009: inst = 32'h35290020;
30'h0000000a: inst = 32'had090008;
30'h0000000b: inst = 32'h3c09001a;
30'h0000000c: inst = 32'h3529002b;
30'h0000000d: inst = 32'had09000c;
30'h0000000e: inst = 32'h3c0902ff;
30'h0000000f: inst = 32'had090010;
30'h00000010: inst = 32'h3c090123;
30'h00000011: inst = 32'h35290124;
30'h00000012: inst = 32'had090014;
30'h00000013: inst = 32'h3c0900aa;
30'h00000014: inst = 32'h352900bb;
30'h00000015: inst = 32'had090018;
30'h00000016: inst = 32'had00001c;
30'h00000017: inst = 32'h3c0a1040;
30'h00000018: inst = 32'h3c011800;
30'h00000019: inst = 32'hac2a0004;
30'h0000001a: inst = 32'h3c0a010f;
30'h0000001b: inst = 32'h354a9b40;
30'h0000001c: inst = 32'h3c011800;
30'h0000001d: inst = 32'hac2a0000;
default:      inst = 32'h00000000;
endcase
end
endmodule
