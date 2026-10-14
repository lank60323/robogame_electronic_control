// 必做题目 2-1：使用 assign 语句实现两数取最大值
module user_module(
    input  wire [7:0]  num1,
    input  wire [7:0]  num2,
    output wire [7:0]  max
);

assign max = (num1 > num2) ? num1 : num2;

endmodule
