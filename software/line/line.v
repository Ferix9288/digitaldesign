module line(input clk, input rst, input [29:0] addr, output reg [31:0] inst);
reg [29:0] addr_r;
always @(posedge clk)
begin
addr_r <= (rst) ? (30'b0) : (addr);
end
always @(*)
begin
case(addr_r)
30'h00000000: inst = 32'h3c1d1000;
30'h00000001: inst = 32'h0c000006;
30'h00000002: inst = 32'h37bd4000;
30'h00000003: inst = 32'h3c0c4000;
30'h00000004: inst = 32'h01800008;
30'h00000005: inst = 32'h00000000;
30'h00000006: inst = 32'h27bdffe0;
30'h00000007: inst = 32'h3c021900;
30'h00000008: inst = 32'h3c030100;
30'h00000009: inst = 32'h3c0402ff;
30'h0000000a: inst = 32'h346500ff;
30'h0000000b: inst = 32'h34460000;
30'h0000000c: inst = 32'hafa00010;
30'h0000000d: inst = 32'h3487ff0f;
30'h0000000e: inst = 32'h34480004;
30'h0000000f: inst = 32'hacc50000;
30'h00000010: inst = 32'h3c050320;
30'h00000011: inst = 32'h24060060;
30'h00000012: inst = 32'h34490008;
30'h00000013: inst = 32'had070000;
30'h00000014: inst = 32'h3c070200;
30'h00000015: inst = 32'h34a80060;
30'h00000016: inst = 32'h344a000c;
30'h00000017: inst = 32'had260000;
30'h00000018: inst = 32'h34e6ffff;
30'h00000019: inst = 32'h34490010;
30'h0000001a: inst = 32'had480000;
30'h0000001b: inst = 32'h24080200;
30'h0000001c: inst = 32'h344a0014;
30'h0000001d: inst = 32'had260000;
30'h0000001e: inst = 32'h34a60200;
30'h0000001f: inst = 32'h34490018;
30'h00000020: inst = 32'had480000;
30'h00000021: inst = 32'h34e800ff;
30'h00000022: inst = 32'h344a001c;
30'h00000023: inst = 32'had260000;
30'h00000024: inst = 32'h2406012c;
30'h00000025: inst = 32'h34490020;
30'h00000026: inst = 32'had480000;
30'h00000027: inst = 32'h34a8012c;
30'h00000028: inst = 32'h344a0024;
30'h00000029: inst = 32'had260000;
30'h0000002a: inst = 32'h348600ff;
30'h0000002b: inst = 32'h34490028;
30'h0000002c: inst = 32'had480000;
30'h0000002d: inst = 32'h24080100;
30'h0000002e: inst = 32'h344a002c;
30'h0000002f: inst = 32'had260000;
30'h00000030: inst = 32'h34a60100;
30'h00000031: inst = 32'h34490030;
30'h00000032: inst = 32'had480000;
30'h00000033: inst = 32'h3c0801a0;
30'h00000034: inst = 32'h348aff00;
30'h00000035: inst = 32'h344b0034;
30'h00000036: inst = 32'had260000;
30'h00000037: inst = 32'h35060000;
30'h00000038: inst = 32'h34490038;
30'h00000039: inst = 32'had6a0000;
30'h0000003a: inst = 32'h35080258;
30'h0000003b: inst = 32'h344a003c;
30'h0000003c: inst = 32'had260000;
30'h0000003d: inst = 32'h3c0601b0;
30'h0000003e: inst = 32'h34890000;
30'h0000003f: inst = 32'h344b0040;
30'h00000040: inst = 32'had480000;
30'h00000041: inst = 32'h34c80000;
30'h00000042: inst = 32'h344a0044;
30'h00000043: inst = 32'had690000;
30'h00000044: inst = 32'h34c60258;
30'h00000045: inst = 32'h34490048;
30'h00000046: inst = 32'had480000;
30'h00000047: inst = 32'h34e7ff00;
30'h00000048: inst = 32'h3448004c;
30'h00000049: inst = 32'had260000;
30'h0000004a: inst = 32'h34660000;
30'h0000004b: inst = 32'h34490050;
30'h0000004c: inst = 32'had070000;
30'h0000004d: inst = 32'h34630258;
30'h0000004e: inst = 32'h34470054;
30'h0000004f: inst = 32'had260000;
30'h00000050: inst = 32'h3484ffff;
30'h00000051: inst = 32'h34460058;
30'h00000052: inst = 32'hace30000;
30'h00000053: inst = 32'h3443005c;
30'h00000054: inst = 32'hacc40000;
30'h00000055: inst = 32'h3c060205;
30'h00000056: inst = 32'h34a70000;
30'h00000057: inst = 32'h34480060;
30'h00000058: inst = 32'hac600000;
30'h00000059: inst = 32'h34c30fee;
30'h0000005a: inst = 32'h34460064;
30'h0000005b: inst = 32'had070000;
30'h0000005c: inst = 32'h24080258;
30'h0000005d: inst = 32'h34490068;
30'h0000005e: inst = 32'hacc30000;
30'h0000005f: inst = 32'h3c030299;
30'h00000060: inst = 32'h3446006c;
30'h00000061: inst = 32'had280000;
30'h00000062: inst = 32'h34638800;
30'h00000063: inst = 32'h34480070;
30'h00000064: inst = 32'hacc70000;
30'h00000065: inst = 32'h34460074;
30'h00000066: inst = 32'had030000;
30'h00000067: inst = 32'h34a30258;
30'h00000068: inst = 32'h34450078;
30'h00000069: inst = 32'hacc00000;
30'h0000006a: inst = 32'h3c060190;
30'h0000006b: inst = 32'h3447007c;
30'h0000006c: inst = 32'haca30000;
30'h0000006d: inst = 32'h34c30000;
30'h0000006e: inst = 32'h34450080;
30'h0000006f: inst = 32'hace40000;
30'h00000070: inst = 32'h3c0403ff;
30'h00000071: inst = 32'h34c60258;
30'h00000072: inst = 32'h34470084;
30'h00000073: inst = 32'haca30000;
30'h00000074: inst = 32'h3c036412;
30'h00000075: inst = 32'h3485ffff;
30'h00000076: inst = 32'h34480088;
30'h00000077: inst = 32'hace60000;
30'h00000078: inst = 32'h3466c032;
30'h00000079: inst = 32'h3447008c;
30'h0000007a: inst = 32'had050000;
30'h0000007b: inst = 32'h3485ff00;
30'h0000007c: inst = 32'h34480090;
30'h0000007d: inst = 32'hace60000;
30'h0000007e: inst = 32'h3466c064;
30'h0000007f: inst = 32'h34470094;
30'h00000080: inst = 32'had050000;
30'h00000081: inst = 32'h348500ff;
30'h00000082: inst = 32'h34480098;
30'h00000083: inst = 32'hace60000;
30'h00000084: inst = 32'h3466c096;
30'h00000085: inst = 32'h3447009c;
30'h00000086: inst = 32'had050000;
30'h00000087: inst = 32'h34840000;
30'h00000088: inst = 32'h344500a0;
30'h00000089: inst = 32'hace60000;
30'h0000008a: inst = 32'h3c060300;
30'h0000008b: inst = 32'h3467c0c8;
30'h0000008c: inst = 32'h344800a4;
30'h0000008d: inst = 32'haca40000;
30'h0000008e: inst = 32'h34c4ffff;
30'h0000008f: inst = 32'h344500a8;
30'h00000090: inst = 32'had070000;
30'h00000091: inst = 32'h3467c0fa;
30'h00000092: inst = 32'h344800ac;
30'h00000093: inst = 32'haca40000;
30'h00000094: inst = 32'h34c4ff00;
30'h00000095: inst = 32'h344500b0;
30'h00000096: inst = 32'had070000;
30'h00000097: inst = 32'h3467c12c;
30'h00000098: inst = 32'h344800b4;
30'h00000099: inst = 32'haca40000;
30'h0000009a: inst = 32'h34c400ff;
30'h0000009b: inst = 32'h344500b8;
30'h0000009c: inst = 32'had070000;
30'h0000009d: inst = 32'h3463c15e;
30'h0000009e: inst = 32'h344600bc;
30'h0000009f: inst = 32'haca40000;
30'h000000a0: inst = 32'h344400c0;
30'h000000a1: inst = 32'hacc30000;
30'h000000a2: inst = 32'h3c031780;
30'h000000a3: inst = 32'h3c0501ff;
30'h000000a4: inst = 32'h344200c4;
30'h000000a5: inst = 32'hac800000;
30'h000000a6: inst = 32'h34a4ffff;
30'h000000a7: inst = 32'h34650000;
30'h000000a8: inst = 32'hac400000;
30'h000000a9: inst = 32'h34620004;
30'h000000aa: inst = 32'haca40000;
30'h000000ab: inst = 32'hac400000;
30'h000000ac: inst = 32'h3c028000;
30'h000000ad: inst = 32'h34420020;
30'h000000ae: inst = 32'h8c430000;
30'h000000af: inst = 32'h00000000;
30'h000000b0: inst = 32'hafa30018;
30'h000000b1: inst = 32'h3c031040;
30'h000000b2: inst = 32'h8c420000;
30'h000000b3: inst = 32'h00000000;
30'h000000b4: inst = 32'h34630000;
30'h000000b5: inst = 32'h14430006;
30'h000000b6: inst = 32'h00000000;
30'h000000b7: inst = 32'h3c021800;
30'h000000b8: inst = 32'h3c031080;
30'h000000b9: inst = 32'h3c041780;
30'h000000ba: inst = 32'h080000bf;
30'h000000bb: inst = 32'h00000000;
30'h000000bc: inst = 32'h3c021800;
30'h000000bd: inst = 32'h3c031040;
30'h000000be: inst = 32'h3c041900;
30'h000000bf: inst = 32'h34630000;
30'h000000c0: inst = 32'h34450004;
30'h000000c1: inst = 32'h34840000;
30'h000000c2: inst = 32'h34420000;
30'h000000c3: inst = 32'haca30000;
30'h000000c4: inst = 32'hac440000;
30'h000000c5: inst = 32'h3c028000;
30'h000000c6: inst = 32'h34420020;
30'h000000c7: inst = 32'h8c420000;
30'h000000c8: inst = 32'h00000000;
30'h000000c9: inst = 32'h8fa30018;
30'h000000ca: inst = 32'h00000000;
30'h000000cb: inst = 32'h1043fff9;
30'h000000cc: inst = 32'h00000000;
30'h000000cd: inst = 32'h080000ac;
30'h000000ce: inst = 32'h00000000;
default:      inst = 32'h00000000;
endcase
end
endmodule
