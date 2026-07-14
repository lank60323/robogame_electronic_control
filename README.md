# STM32F401 GPIO 与外部中断示例

基于 STM32CubeMX 生成、使用 HAL 库编写的两个 STM32F401CCU6（Cortex-M4）入门工程。工程可用 Keil MDK 打开、编译和烧录。

## 工程说明

| 目录 | 功能 |
| --- | --- |
| `test_gpio` | 通过 PC13 每 500 ms 翻转一次输出，用于测试 GPIO 和板载 LED 闪烁。 |
| `test_exti` | PA0 产生下降沿时触发 EXTI0 中断，在中断回调中翻转 PC13 输出。 |

## 引脚连接

| 引脚 | 配置 | 用途 |
| --- | --- | --- |
| PC13 | 推挽输出 | LED 输出。许多 STM32F401 小板的板载 LED 为低电平点亮。 |
| PA0 | 上拉输入、下降沿中断 | 按键输入；按键另一端应接 GND。 |
| PA13 / PA14 | SWD | ST-Link 调试、烧录接口。 |

`test_exti` 中 PA0 默认通过内部上拉保持高电平。按下接至 GND 的按键时，PA0 出现高到低的变化，触发 `EXTI0_IRQHandler()`，随后执行 `HAL_GPIO_EXTI_Callback()` 并翻转 PC13。

> 注意：机械按键会抖动。`test_exti` 当前用于验证外部中断，尚未加入软件消抖；一次按下可能出现多次翻转。

## 硬件与时钟

- 目标芯片：STM32F401CCU6
- 系统时钟：50 MHz
- 时钟来源：25 MHz 外部高速晶振（HSE）经 PLL 配置
- 调试接口：SWD（PA13/SWDIO、PA14/SWCLK）

如果你的开发板没有 25 MHz 外部晶振，或晶振配置不同，需要在 CubeMX / `SystemClock_Config()` 中按实际硬件调整；否则程序可能在时钟初始化阶段停在 `Error_Handler()`。

## 编译与烧录

1. 使用 Keil MDK 打开相应工程：
   - `test_gpio/MDK-ARM/test_gpio.uvprojx`
   - `test_exti/MDK-ARM/test_exti.uvprojx`
2. 连接 ST-Link 的 `3.3V`、`GND`、`SWDIO`、`SWCLK`。
3. 在 Keil 中执行 Build，然后执行 Download（`F8`）。
4. 确认烧录输出包含 `Programming Done` 和 `Verify OK`，按下 RESET 后观察现象。

## 目录结构

```text
.
├── test_gpio/       # GPIO 闪烁示例
└── test_exti/       # PA0 外部中断示例
```

`Core/` 存放应用代码，`Drivers/` 为 STM32 HAL 与 CMSIS 驱动，`.ioc` 文件可用 STM32CubeMX 打开以修改引脚和时钟配置。
