# Lab1 实验报告：Verilog 语法

姓名：【填写】　　学号：【填写】

## 一、实验目的

1. 掌握 Verilog 的基本语法：模块、端口、wire 与 reg、assign 与 always、运算符。
2. 能够阅读和编写简单的 Verilog 代码，并在 FPGAOL NEXT 上完成验证。
3. 理解硬件描述语言与 C 语言的区别：Verilog 描述的是同时工作的电路，而不是按顺序执行的程序。

## 二、必做内容

### 题目 1：向量翻转

```verilog
module user_module(
    input  wire [7:0] in_data,
    output reg  [7:0] out_data
);

always @(*) begin
    out_data = {in_data[0], in_data[1], in_data[2], in_data[3],
                in_data[4], in_data[5], in_data[6], in_data[7]};
end

endmodule
```

**说明：** 题目要求把位序颠倒，即 `out_data[7] = in_data[0]`，……，`out_data[0] = in_data[7]`，不是按位取反。我用拼接运算符 `{}` 实现：拼接时写在最左边的一项是结果的最高位。因此把 `in_data[0]` 写在最左边，`in_data[7]` 写在最右边即可。这个电路中没有逻辑门，只是把 8 根线交叉连接。

最开始我尝试写 `in_data[0:7]`，编译报错 `part select in_data[0:7] is out of order`。原因是 `in_data` 声明为 `[7:0]`，域选择的方向必须和声明一致。`[m:n]` 只能原样截取一段，不能改变位的顺序，要改变顺序只能用拼接。

`out_data` 在框架中声明为 `reg`，所以要在 `always @(*)` 中赋值。

【FPGAOL NEXT 通过截图】

### 题目 2：最大值问题

#### 2-1 使用 assign 实现 MAX2

```verilog
module user_module(
    input  wire [7:0] num1,
    input  wire [7:0] num2,
    output wire [7:0] max
);

assign max = (num1 < num2) ? num2 : num1;

endmodule
```

**说明：** 使用条件运算符 `?:` 实现二选一。`max` 是 wire 类型，用 assign 连续赋值。两数相等时输出 num1，结果同样正确。

【FPGAOL NEXT 通过截图】

#### 2-2 使用 always 和 if-else 求三个数的最大值

```verilog
module user_module(
    input wire [7:0] num1,
    input wire [7:0] num2,
    input wire [7:0] num3,
    output reg [7:0] max
);

reg [7:0] max2;

always @(*) begin
    if (num1 > num2)
        max2 = num1;
    else
        max2 = num2;
end

always @(*) begin
    if (max2 < num3)
        max = num3;
    else
        max = max2;
end

endmodule
```

**说明：** 先比较 num1 和 num2，把较大的值存入中间信号 `max2`；再比较 `max2` 和 num3，得到最终结果。`max2` 是在 always 中赋值的，所以声明为 reg。每个 if 都有对应的 else，保证任何情况下输出都有确定的值。

【FPGAOL NEXT 通过截图】

#### 2-3 例化 MAX2 求三个数的最大值

```verilog
module MAX2(
    input wire [7:0] num1,
    input wire [7:0] num2,
    output wire [7:0] max
);

    assign max = (num1 > num2) ? num1 : num2;

endmodule

module user_module(
    input  wire [7:0] num1,
    input  wire [7:0] num2,
    input  wire [7:0] num3,
    output wire [7:0] max
);

wire [7:0] temp;

MAX2 first (
    .num1 (num1),
    .num2 (num2),
    .max  (temp)
);

MAX2 second (
    .num1 (temp),
    .num2 (num3),
    .max  (max)
);

endmodule
```

**说明：** 例化两个 MAX2：第一个比较 num1 和 num2，输出接到内部导线 `temp`；第二个比较 `temp` 和 num3，输出接到 `max`。思路相当于 C 中的 `max2(max2(num1, num2), num3)`，区别在于模块例化是在电路中放置两个同时工作的实体。例化时按端口名称连接。`temp` 由模块输出驱动，所以必须是 wire 类型。

【FPGAOL NEXT 通过截图】

### 题目 3：1 的个数

```verilog
module user_module(
    input wire [2:0] in_data,
    output reg [1:0] out_count
);

always @(*) begin
     out_count = in_data[0] + in_data[1] + in_data[2];
end

endmodule
```

**说明：** 每一位只能是 0 或 1，直接把三位相加就得到 1 的个数。Verilog 表达式按左右两侧中最大的位宽计算，左侧 `out_count` 是 2 位，所以加法在 2 位下进行，最大结果 3（`2'b11`）不会溢出。

【FPGAOL NEXT 通过截图】

## 三、选择性必做内容：题目 2 Verilog 运算符

已知 `a = 8'b0011_0011`（51），`b = 8'b1111_0000`（240），均为无符号数。

| 信号 | 表达式 | 结果 | 说明 |
| --- | --- | --- | --- |
| c | `a & b` | `8'b0011_0000` | 按位与 |
| d | `a \|\| b` | `8'b0000_0001` | 逻辑或：a、b 均非零，结果为 1 位的 1，高位补 0 |
| e | `a ^ b` | `8'b1100_0011` | 按位异或 |
| f | `~a` | `8'b1100_1100` | 按位取反 |
| g | `{a[2:0], b[3:0], {1'b1}}` | `8'b0110_0001` | 拼接：`011`、`0000`、`1` |
| h | `b >>> 3` | `8'b0001_1110` | b 为无符号数，算术右移时高位补 0 |
| i | `&b` | `8'b0000_0000` | 归约与：b 中含 0 |
| j | `(a > b) ? a : b` | `8'b1111_0000` | 51 < 240，取 b |
| k | `a - b` | `8'b0100_0011` | 51 − 240 + 256 = 67 |
| l | `!a` | `8'b0000_0000` | 逻辑非：a 非零，结果为 0 |

**总结：** `&&`、`||`、`!` 是逻辑运算，把整个数看成真或假，结果只有 1 位；`&`、`|`、`^`、`~` 放在两个操作数之间时是按位运算，结果位宽与操作数相同；`&b` 这种单目形式是归约运算，把所有位合成 1 位。

## 四、实验总结

【用自己的话写 2～3 句，例如：】
1. 最大的收获是理解了 Verilog 是在「画电路」，每一段代码都对应真实的硬件，所有部分同时工作。
2. 掌握了 wire 和 reg 的使用规则：用 assign 赋值的信号是 wire，在 always 中赋值的信号是 reg；reg 不一定是寄存器。
3. 学会了按名字例化模块，理解了模块之间要用 wire 连接。
4. 常犯的错误：begin/end 不配对、漏写分号、用 `[0:7]` 反向截取。以后会先检查这些问题。

【可选：对实验的评价或建议】
