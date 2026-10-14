`timescale 1ns / 1ps
module tb_max3;
reg  [7:0] num1, num2, num3;
wire [7:0] max;
reg  [7:0] expected;
integer    a, b, c, errors;

user_module dut (
    .num1  (num1),
    .num2  (num2),
    .num3  (num3),
    .max   (max)
);

// 穷举 256^3 种输入
initial begin
    errors = 0;
    for (a = 0; a < 256; a = a + 1)
        for (b = 0; b < 256; b = b + 1)
            for (c = 0; c < 256; c = c + 1) begin
                num1 = a; num2 = b; num3 = c;
                #1;
                expected = a;
                if (b > expected) expected = b;
                if (c > expected) expected = c;
                if (max !== expected) errors = errors + 1;
            end
    if (errors == 0) $display("PASS"); else $display("FAILED %0d cases", errors);
    $finish;
end
endmodule
