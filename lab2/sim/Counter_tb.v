`timescale 1ns / 1ps
// 必做 3 仿真文件：激励与题目给出的 q3_tb.v 相同，另外打印每个时钟沿后的状态
module Counter_tb();
reg  clk, rst, en;
wire out;

initial begin
    clk = 0; rst = 1; en = 0;
    #10;
    rst = 0;
    #10;
    en = 1;
    #20;
    en = 0;
    #20;
    en = 1;
    #20;
    rst = 1;
    #20;
    rst = 0;
    #200;
    en = 0;
    #20;
    $finish;
end

always #5 clk = ~clk;

Counter #(
    .MIN_VALUE (8'd10),
    .MAX_VALUE (8'd13)
) counter (
    .clk    (clk),
    .rst    (rst),
    .enable (en),
    .out    (out)
);

always @(posedge clk) begin
    #1;
    $display("Time %0t: rst=%b en=%b counter=%0d out=%b",
             $time, rst, en, counter.counter, out);
end

initial begin
    $dumpfile("Counter_tb.vcd");
    $dumpvars(0, Counter_tb);
end
endmodule
