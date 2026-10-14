`timescale 1ns / 1ps
module tb_count_ones;
reg  [2:0] in_data;
wire [1:0] out_count;
integer    value, errors;

user_module dut (
    .in_data    (in_data),
    .out_count  (out_count)
);

initial begin
    errors = 0;
    for (value = 0; value < 8; value = value + 1) begin
        in_data = value;
        #1;
        $display("in_data=%b out_count=%0d", in_data, out_count);
        if (out_count !== in_data[0] + in_data[1] + in_data[2]) errors = errors + 1;
    end
    if (errors == 0) $display("PASS"); else $display("FAILED %0d cases", errors);
    $finish;
end
endmodule
