`timescale 1ns / 1ps
module tb_reverse;
reg  [7:0] in_data;
wire [7:0] out_data;
reg  [7:0] expected;
integer    value, bit_index, errors;

user_module dut (
    .in_data   (in_data),
    .out_data  (out_data)
);

initial begin
    errors = 0;
    for (value = 0; value < 256; value = value + 1) begin
        in_data = value;
        #1;
        for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1)
            expected[bit_index] = in_data[7 - bit_index];
        if (out_data !== expected) begin
            $display("FAIL in=%b out=%b expected=%b", in_data, out_data, expected);
            errors = errors + 1;
        end
    end
    if (errors == 0) $display("PASS"); else $display("FAILED %0d cases", errors);
    $finish;
end
endmodule
