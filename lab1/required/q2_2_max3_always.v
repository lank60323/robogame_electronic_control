// 必做题目 2-2：使用 always 和 if-else 语句实现三数取最大值
module user_module(
    input  wire [7:0]  num1,
    input  wire [7:0]  num2,
    input  wire [7:0]  num3,
    output reg  [7:0]  max
);

always @(*) begin
    if (num1 >= num2 && num1 >= num3)
        max = num1;
    else if (num2 >= num3)
        max = num2;
    else
        max = num3;
end

endmodule
