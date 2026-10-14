`timescale 1ns / 1ps
module tb_operators;
reg  [7:0] a, b;
wire [7:0] c, d, e, f, g, h, i, j, k, l;

test dut (
    .a (a), .b (b),
    .c (c), .d (d), .e (e), .f (f), .g (g),
    .h (h), .i (i), .j (j), .k (k), .l (l)
);

initial begin
    a = 8'b0011_0011;
    b = 8'b1111_0000;
    #1;
    $display("c=%b d=%b e=%b f=%b g=%b", c, d, e, f, g);
    $display("h=%b i=%b j=%b k=%b l=%b", h, i, j, k, l);
    if (c === 8'b0011_0000 && d === 8'b0000_0001 && e === 8'b1100_0011 &&
        f === 8'b1100_1100 && g === 8'b0110_0001 && h === 8'b0001_1110 &&
        i === 8'b0000_0000 && j === 8'b1111_0000 && k === 8'b0100_0011 &&
        l === 8'b0000_0000)
        $display("PASS");
    else
        $display("FAILED");
    $finish;
end
endmodule
