`timescale 1ns / 1ps
module tb_mux2;
reg        sel;
reg  [7:0] data0, data1;
wire [7:0] out_data;
integer    step, errors;

user_module dut (
    .sel       (sel),
    .data0     (data0),
    .data1     (data1),
    .out_data  (out_data)
);

initial begin
    errors = 0;
    for (step = 0; step < 1000; step = step + 1) begin
        sel = $random; data0 = $random; data1 = $random;
        #1;
        if (out_data !== (sel ? data1 : data0)) errors = errors + 1;
    end
    if (errors == 0) $display("PASS"); else $display("FAILED %0d cases", errors);
    $finish;
end
endmodule
