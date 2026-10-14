`timescale 1ns / 1ps
module tb_regfile;
reg         clk, rst, we;
reg  [3:0]  waddr, raddr;
reg  [31:0] wdata;
wire [31:0] rdata;
reg  [31:0] model [0:15];
integer     index, step, errors;

user_module dut (
    .clk    (clk),
    .rst    (rst),
    .we     (we),
    .waddr  (waddr),
    .raddr  (raddr),
    .wdata  (wdata),
    .rdata  (rdata)
);

always #5 clk = ~clk;

task check_all;
    begin
        for (index = 0; index < 16; index = index + 1) begin
            raddr = index;
            #1;
            if (rdata !== model[index]) begin
                $display("FAIL addr=%0d rdata=%h expected=%h", index, rdata, model[index]);
                errors = errors + 1;
            end
        end
    end
endtask

initial begin
    clk = 0; errors = 0;
    rst = 1; we = 1; waddr = 0; wdata = 32'hdead_beef; raddr = 0;
    for (index = 0; index < 16; index = index + 1) model[index] = 0;
    @(negedge clk);
    @(negedge clk);
    rst = 0; we = 0;
    check_all;
    // 随机读写，并与软件模型对比
    for (step = 0; step < 500; step = step + 1) begin
        @(negedge clk);
        we = $random; waddr = $random; wdata = $random;
        @(posedge clk);
        if (we) model[waddr] = wdata;
        #1;
        we = 0;
        check_all;
    end
    // 再次复位应清空全部数据（rst 优先于 we）
    @(negedge clk);
    rst = 1; we = 1;
    @(negedge clk);
    rst = 0; we = 0;
    for (index = 0; index < 16; index = index + 1) model[index] = 0;
    check_all;
    if (errors == 0) $display("PASS"); else $display("FAILED %0d checks", errors);
    $finish;
end
endmodule
