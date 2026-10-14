// 必做题目 1：向量翻转
// 将 8 bit 输入按位倒序输出：out_data[7] = in_data[0]，...，out_data[0] = in_data[7]
module user_module(
    input  wire [7:0]  in_data,
    output reg  [7:0]  out_data
);

always @(*) begin
    out_data = {in_data[0], in_data[1], in_data[2], in_data[3],
                in_data[4], in_data[5], in_data[6], in_data[7]};
end

endmodule
