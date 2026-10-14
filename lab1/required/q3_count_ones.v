// 必做题目 3：统计 3 bit 输入中 1 的个数
module user_module(
    input  wire [2:0]  in_data,
    output reg  [1:0]  out_count
);

// 左侧为 2 bit，加法在 2 bit 位宽下进行，最大结果 3 不会溢出
always @(*) begin
    out_count = in_data[0] + in_data[1] + in_data[2];
end

endmodule
