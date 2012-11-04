module isr(input clk, input rst, input [29:0] addr, output reg [31:0] inst);
reg [29:0] addr_r;
always @(posedge clk)
begin
addr_r <= (rst) ? (30'b0) : (addr);
end
always @(*)
begin
case(addr_r)
30'h00000000: inst = 32'h401a6800;
30'h00000001: inst = 32'h401b6000;
30'h00000002: inst = 32'h08000004;
30'h00000003: inst = 32'h00000000;
30'h00000004: inst = 32'h401b6000;
30'h00000005: inst = 32'h00000000;
30'h00000006: inst = 32'h377b0001;
30'h00000007: inst = 32'h401a7000;
30'h00000008: inst = 32'h409b6000;
30'h00000009: inst = 32'h03400008;
30'h0000000a: inst = 32'h00000000;
default:      inst = 32'h00000000;
endcase
end
endmodule
