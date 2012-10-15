module asmtest(input clk, input rst, input [29:0] addr, output reg [31:0] inst);
reg [29:0] addr_r;
always @(posedge clk)
begin
addr_r <= (rst) ? (30'b0) : (addr);
end
always @(*)
begin
case(addr_r)
30'h00000000: inst = 32'h3c083000;
30'h00000001: inst = 32'h35080101;
30'h00000002: inst = 32'h3c173000;
30'h00000003: inst = 32'h36f70100;
30'h00000004: inst = 32'ha2e80000;
30'h00000005: inst = 32'h00000000;
30'h00000006: inst = 32'h82ee0000;
30'h00000007: inst = 32'h00000000;
default:      inst = 32'h00000000;
endcase
end
endmodule
