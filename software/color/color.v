module color(input clk, input rst, input [29:0] addr, output reg [31:0] inst);
reg [29:0] addr_r;
always @(posedge clk)
begin
addr_r <= (rst) ? (30'b0) : (addr);
end
always @(*)
begin
case(addr_r)
30'h00000000: inst = 32'h3c1d1000;
30'h00000001: inst = 32'h0c000054;
30'h00000002: inst = 32'h37bd4000;
30'h00000003: inst = 32'h27bdffe0;
30'h00000004: inst = 32'hafa00010;
30'h00000005: inst = 32'h24020257;
30'h00000006: inst = 32'h8fa30010;
30'h00000007: inst = 32'h00000000;
30'h00000008: inst = 32'h0043102a;
30'h00000009: inst = 32'h14400021;
30'h0000000a: inst = 32'h00000000;
30'h0000000b: inst = 32'hafa00014;
30'h0000000c: inst = 32'h2402031f;
30'h0000000d: inst = 32'h8fa30014;
30'h0000000e: inst = 32'h00000000;
30'h0000000f: inst = 32'h0043102a;
30'h00000010: inst = 32'h14400014;
30'h00000011: inst = 32'h00000000;
30'h00000012: inst = 32'h8fa20010;
30'h00000013: inst = 32'h00000000;
30'h00000014: inst = 32'h8fa30014;
30'h00000015: inst = 32'h00000000;
30'h00000016: inst = 32'h00021280;
30'h00000017: inst = 32'h00621021;
30'h00000018: inst = 32'h3c031040;
30'h00000019: inst = 32'h3c0400ff;
30'h0000001a: inst = 32'h00021080;
30'h0000001b: inst = 32'h34630000;
30'h0000001c: inst = 32'h34840000;
30'h0000001d: inst = 32'h00431021;
30'h0000001e: inst = 32'hac440000;
30'h0000001f: inst = 32'h8fa20014;
30'h00000020: inst = 32'h00000000;
30'h00000021: inst = 32'h24420001;
30'h00000022: inst = 32'hafa20014;
30'h00000023: inst = 32'h0800000c;
30'h00000024: inst = 32'h00000000;
30'h00000025: inst = 32'h8fa20010;
30'h00000026: inst = 32'h00000000;
30'h00000027: inst = 32'h24420001;
30'h00000028: inst = 32'hafa20010;
30'h00000029: inst = 32'h08000005;
30'h0000002a: inst = 32'h00000000;
30'h0000002b: inst = 32'hafa00018;
30'h0000002c: inst = 32'h3404ff00;
30'h0000002d: inst = 32'h24020257;
30'h0000002e: inst = 32'h8fa30018;
30'h0000002f: inst = 32'h00000000;
30'h00000030: inst = 32'h0043102a;
30'h00000031: inst = 32'h1440001f;
30'h00000032: inst = 32'h00000000;
30'h00000033: inst = 32'hafa0001c;
30'h00000034: inst = 32'h2402031f;
30'h00000035: inst = 32'h8fa3001c;
30'h00000036: inst = 32'h00000000;
30'h00000037: inst = 32'h0043102a;
30'h00000038: inst = 32'h14400012;
30'h00000039: inst = 32'h00000000;
30'h0000003a: inst = 32'h8fa20018;
30'h0000003b: inst = 32'h00000000;
30'h0000003c: inst = 32'h8fa3001c;
30'h0000003d: inst = 32'h00000000;
30'h0000003e: inst = 32'h00021280;
30'h0000003f: inst = 32'h00621021;
30'h00000040: inst = 32'h3c031080;
30'h00000041: inst = 32'h00021080;
30'h00000042: inst = 32'h34630000;
30'h00000043: inst = 32'h00431021;
30'h00000044: inst = 32'hac440000;
30'h00000045: inst = 32'h8fa2001c;
30'h00000046: inst = 32'h00000000;
30'h00000047: inst = 32'h24420001;
30'h00000048: inst = 32'hafa2001c;
30'h00000049: inst = 32'h08000034;
30'h0000004a: inst = 32'h00000000;
30'h0000004b: inst = 32'h8fa20018;
30'h0000004c: inst = 32'h00000000;
30'h0000004d: inst = 32'h24420001;
30'h0000004e: inst = 32'hafa20018;
30'h0000004f: inst = 32'h0800002d;
30'h00000050: inst = 32'h00000000;
30'h00000051: inst = 32'h27bd0020;
30'h00000052: inst = 32'h03e00008;
30'h00000053: inst = 32'h00000000;
30'h00000054: inst = 32'h27bdffd0;
30'h00000055: inst = 32'hafbf002c;
30'h00000056: inst = 32'hafa00020;
30'h00000057: inst = 32'h0c000003;
30'h00000058: inst = 32'h00000000;
30'h00000059: inst = 32'h24020000;
30'h0000005a: inst = 32'h8fbf002c;
30'h0000005b: inst = 32'h00000000;
30'h0000005c: inst = 32'h27bd0030;
30'h0000005d: inst = 32'h03e00008;
30'h0000005e: inst = 32'h00000000;
default:      inst = 32'h00000000;
endcase
end
endmodule
