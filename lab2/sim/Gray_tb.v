`timescale 1ns / 1ps
// 选择性必做 2 仿真文件：复位后连续计数两轮以上，并自动检查格雷码与 out
module Gray_tb();
reg        clk, rst;
wire [3:0] gray;
wire       out;
reg  [3:0] expect_bin;
integer    errors;

user_module dut (
    .clk  (clk),
    .rst  (rst),
    .gray (gray),
    .out  (out)
);

always #5 clk = ~clk;

initial begin
    clk = 0; rst = 1; errors = 0; expect_bin = 0;
    #12;
    rst = 0;
    repeat (36) begin
        @(posedge clk);
        #1;
        expect_bin = expect_bin + 1;
        $display("Time %0t: gray=%b out=%b", $time, gray, out);
        if (gray !== (expect_bin ^ (expect_bin >> 1)) || out !== (expect_bin == 0)) begin
            $display("  ERROR: expected gray=%b out=%b", expect_bin ^ (expect_bin >> 1), expect_bin == 0);
            errors = errors + 1;
        end
    end
    $display("Errors: %0d", errors);
    $finish;
end

initial begin
    $dumpfile("Gray_tb.vcd");
    $dumpvars(0, Gray_tb);
end
endmodule
