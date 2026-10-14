// 选做题目 1：Verilog 数组 —— 16 个 32 bit 寄存器组成的寄存器堆
// rst 高电平有效，同步复位；we=1 时在 clk 上升沿写入；读为组合逻辑
module user_module(
    input  wire        clk,
    input  wire        rst,
    input  wire        we,
    input  wire [3:0]  waddr,
    input  wire [3:0]  raddr,
    input  wire [31:0] wdata,
    output wire [31:0] rdata
);

reg [31:0] reg_array [0:15];
integer    index;

// 复位时的 for 循环只是展开为 16 个寄存器的清零，不会产生组合环
always @(posedge clk) begin
    if (rst) begin
        for (index = 0; index < 16; index = index + 1)
            reg_array[index] <= 32'd0;
    end
    else if (we) begin
        reg_array[waddr] <= wdata;
    end
end

assign rdata = reg_array[raddr];

endmodule
