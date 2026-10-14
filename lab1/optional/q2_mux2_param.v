// 选做题目 2：带参数例化 —— 参数化二选一选择器
module MUX2 #(
    parameter WIDTH = 8
)(
    input  wire              sel,
    input  wire [WIDTH-1:0]  data0,
    input  wire [WIDTH-1:0]  data1,
    output wire [WIDTH-1:0]  out_data
);

assign out_data = sel ? data1 : data0;

endmodule

module user_module(
    input  wire        sel,
    input  wire [7:0]  data0,
    input  wire [7:0]  data1,
    output wire [7:0]  out_data
);

MUX2 #(
    .WIDTH     (8)
) mux2_8bit (
    .sel       (sel),
    .data0     (data0),
    .data1     (data1),
    .out_data  (out_data)
);

endmodule
