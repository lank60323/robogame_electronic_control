`timescale 1ns / 1ps
module tb_max2;
reg  [7:0] num1, num2;
wire [7:0] max;
integer    a, b, errors;

user_module dut (
    .num1  (num1),
    .num2  (num2),
    .max   (max)
);

initial begin
    errors = 0;
    for (a = 0; a < 256; a = a + 1)
        for (b = 0; b < 256; b = b + 1) begin
            num1 = a; num2 = b;
            #1;
            if (max !== (a > b ? a : b)) errors = errors + 1;
        end
    if (errors == 0) $display("PASS"); else $display("FAILED %0d cases", errors);
    $finish;
end
endmodule
