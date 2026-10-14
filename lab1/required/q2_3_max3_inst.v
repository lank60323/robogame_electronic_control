// 必做题目 2-3：例化两个 MAX2 实现三数取最大值
// FPGAOL NEXT 要求两个模块在同一个文件中一同提交
module MAX2(
    input  wire [7:0]  num1,
    input  wire [7:0]  num2,
    output wire [7:0]  max
);

assign max = (num1 > num2) ? num1 : num2;

endmodule

module user_module(
    input  wire [7:0]  num1,
    input  wire [7:0]  num2,
    input  wire [7:0]  num3,
    output wire [7:0]  max
);

wire [7:0] max_of_num1_num2;

// 先比较 num1 与 num2
MAX2 max2_first (
    .num1  (num1),
    .num2  (num2),
    .max   (max_of_num1_num2)
);

// 再将上一级结果与 num3 比较
MAX2 max2_second (
    .num1  (max_of_num1_num2),
    .num2  (num3),
    .max   (max)
);

endmodule
