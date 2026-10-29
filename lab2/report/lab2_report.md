# Lab2 实验报告：测试与仿真

姓名：【填写】　　学号：【填写】

## 一、实验目的

1. 进一步熟悉 Verilog 语法，理解组合逻辑中锁存器的成因及避免方法。
2. 学习编写仿真测试文件（Testbench）。
3. 学习使用 Vivado 进行 RTL 分析与行为仿真。

## 二、必做内容

### 题目 1：if 语句与锁存器

```verilog
module user_module (
    input                       cpu_overheated,
    output  reg                 shut_off_computer,
    input                       arrived,
    input                       gas_tank_empty,
    output  reg                 keep_driving
);
    always @(*) begin
        if (cpu_overheated)
            shut_off_computer = 1'b1;
        else shut_off_computer = 1'b0;
    end
    always @(*) begin
        if (~arrived)
            keep_driving = ~gas_tank_empty;
        else keep_driving = 1'b0;
    end
endmodule
```

**说明：** 原代码在 `always @(*)` 中只写了 if、没有写 else。条件不成立时输出没有被赋值，只能保持原来的值，组合逻辑因此需要「记忆」，会被综合成锁存器。我给两个 if 都补上了 else，让输出在任何条件下都有确定的值：`cpu_overheated` 为假时输出 0，`arrived` 为真时输出 0，这样就消除了锁存器。

另一种办法是在 always 块开头先给输出赋默认值。时序逻辑 `always @(posedge clk)` 中 if 不完整不会产生锁存器，因为寄存器本来就应该在时钟沿之间保持原值。

【FPGAOL NEXT 通过截图】

### 题目 2：case 语句与锁存器

```verilog
module user_module (
    input       [15:0]  scancode,
    output reg          left,
    output reg          down,
    output reg          right,
    output reg          up
);
always @(*) begin
    up = 1'b0; down = 1'b0; left = 1'b0; right = 1'b0;
    case (scancode)
        16'he06b: left = 1'b1;
        16'he072: down = 1'b1;
        16'he074: right = 1'b1;
        16'he075: up = 1'b1;
    endcase
end
endmodule
```

**说明：** 这是一个译码电路。PS/2 键盘的方向键是扩展键，扫描码以 `E0` 开头，再接各自的编码，最后两个字节组成 16 位输入。scancode 等于 `16'he06b`、`16'he072`、`16'he074`、`16'he075` 时，分别把 left、down、right、up 置为 1。

在 case 之前先把四个输出全部赋为 0，所以无论匹配到哪个分支，或者一个都没匹配上，四个输出都有确定的值。因此不需要 `default`，也不会产生锁存器。如果去掉这行默认赋值，例如匹配到 `16'he06b` 时只给 left 赋了值，另外三个输出就会保持旧值，从而产生锁存器。

【FPGAOL NEXT 通过截图】

### 题目 3：计数器 Pro

```verilog
module Counter #(
    parameter MIN_VALUE = 8'd10,
    parameter MAX_VALUE = 8'd13
)(
    input wire clk,
    input wire rst,
    input wire enable,
    output wire out
);
reg [7:0] counter;

always @(posedge clk) begin
    if(rst)
        counter <= 0;
    else if(enable == 0)
        counter <= 0;
    else if(counter < MIN_VALUE || counter >= MAX_VALUE)
        counter <= MIN_VALUE;
    else
        counter <= counter + 8'b1;
end

assign out = (counter == MAX_VALUE);

endmodule

module user_module(
    input wire clk,
    input wire rst,
    input wire enable,
    output wire out
);
Counter #(
    .MIN_VALUE(8'd10),
    .MAX_VALUE(8'd13)
) u_counter(
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .out(out)
);
endmodule
```

**说明：** 计数器在每个时钟上升沿更新一次，各条件按 `if / else if` 的顺序决定优先级：

| 优先级 | 条件 | counter 的下一个值 |
| --- | --- | --- |
| 1 | `rst` 为 1 | 0 |
| 2 | `enable` 为 0 | 0 |
| 3 | `counter < MIN_VALUE` 或 `counter >= MAX_VALUE` | `MIN_VALUE` |
| 4 | 其他 | `counter + 1` |

- 把 rst 写在第一个分支，保证 rst 的优先级高于 enable。
- enable 变低后，下一个时钟沿 counter 就清零，间隔为 1 个周期，满足「不超过三个时钟周期」的要求。
- enable 刚打开时 counter 为 0，小于 MIN_VALUE，所以要直接跳到 MIN_VALUE。判断上界时用 `>=` 而不是 `==`，这样即使 counter 越界，也能马上回到正常范围。
- 计数到 MAX_VALUE 时 out 为 1，持续一个周期。MIN = 10、MAX = 13 时，每 4 个时钟周期出现一次。

调试过程中，我第一次把条件写成了 `counter <= MIN_VALUE`。counter 等于 MIN_VALUE 时条件也成立，于是计数器卡在 10 不动。改成 `<` 后恢复正常。

**仿真验证：** 仿真文件的激励与题目给出的 `q3_tb.v` 相同，另外在每个时钟沿后打印各信号的状态。

```verilog
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
```

【Vivado 仿真波形截图：添加 clk、rst、en、counter（设为 Unsigned Decimal）、out 五个信号】

波形分析：复位期间 counter 为 0；enable 有效后，下一个时钟沿 counter 跳到 10，随后依次为 11、12、13，再回到 10；enable 变低后的下一个时钟沿 counter 清零；rst 和 enable 同时为 1 时 counter 为 0，说明 rst 优先；counter 为 13 时 out 为 1。结果与题目给出的参考波形一致。

【FPGAOL NEXT 通过截图】

### 题目 4：1 的个数 Pro

```verilog
module user_module(
    input       [31:0]  a,
    input       [4:0]   b,
    input       [4:0]   c,
    output reg  [5:0]   out
);
integer i;
always @(*) begin 
    out = 0;
    for(i = 0; i < 32; i = i + 1) begin
        if(i >= b && i <= c)
            out = out + a[i];
    end
end
endmodule
```

**说明：** Verilog 中的 for 循环在综合时会被展开成固定数量的硬件，所以循环上下界必须是常数，不能写成 `for (i = b; i <= c; ...)`。我的做法是固定遍历 0~31 全部 32 位，用 `if (i >= b && i <= c)` 判断这一位是否在区间内，在区间内就累加 `a[i]`。这样生成的是 32 级「比较 + 加法」电路，b、c 只作为比较器的输入，电路规模是固定的。

always 块开头先执行 `out = 0`，之后每次累加用的都是本次刚算出的值，不会用到上一次的旧值，所以 `out = out + a[i]` 不会产生锁存器。out 最大为 32（`6'b100000`），所以需要 6 位。

【FPGAOL NEXT 通过截图】

## 三、选择性必做内容：题目 2 格雷码计数器

```verilog
module user_module(
    input wire clk,
    input wire rst,
    output wire [3:0] gray,
    output wire out
);
reg [3:0] bin;
reg       out_r;

always @(posedge clk) begin
    if(rst) begin
        bin <= 0;
        out_r <= 0;
    end
    else begin
        bin <= bin + 4'b1;
        out_r <= (bin == 15);
    end
end

assign gray = bin ^ (bin >> 1);

assign out = out_r;

endmodule
```

**说明：**

1. 内部维护一个 4 位二进制计数器 `bin`，每个时钟加 1。加到 15 后，4 位加法溢出自动回到 0，不需要额外判断。
2. 格雷码由二进制转换得到：`gray = bin ^ (bin >> 1)`，即每一位与它左边的一位做异或，最高位不变。例如 7 = `0111`，转换后是 `0100`；8 = `1000`，转换后是 `1100`，两者只差 1 位。相邻格雷码只有 1 位不同，可以避免多位同时翻转引起的竞争冒险。
3. 平台要求 out 在计数从最大值回到 0 的那个周期为 1，并且复位时为 0。如果写成 `out = (bin == 0)`，复位期间 out 也会是 1，所以我用寄存器 `out_r` 保存：在同一个时钟沿，`out_r <= (bin == 15)` 读取的是 bin 更新前的旧值。旧值为 15 时，bin 变为 0，out_r 同时变为 1。

调试过程中，我第一次把 out 写成了 `assign out = (bin == 15)`，比平台要求早了一个周期，平台测试有 16 步失败。对照平台给出的「期望输出 / 用户输出」表格后，我找到了原因并改成了上面的写法。

**仿真验证：**

```verilog
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
```

【Vivado 仿真波形截图：添加 clk、rst、gray、out，以及 dut 内部的 bin】

【FPGAOL NEXT 通过截图】

## 四、实验总结

【用自己的话写 2～3 句，例如：】
1. 理解了锁存器的成因：组合逻辑中只要有输出在某条路径上没有被赋值，就需要保持旧值，从而产生锁存器。养成在 always 开头赋默认值的习惯可以避免这个问题。
2. 掌握了时序逻辑的写法：`always @(posedge clk)` 配合非阻塞赋值 `<=`，`if / else if` 的顺序决定优先级。
3. 学会了编写 Testbench：用 initial 产生激励、用 always 产生时钟、用 `$display` 输出结果、用 `$finish` 结束仿真，并能在 Vivado 中查看波形。
4. 理解了 Verilog 的 for 循环是在复制硬件，不是在重复执行，所以循环上下界必须是常数。

【可选：对实验的评价或建议】
