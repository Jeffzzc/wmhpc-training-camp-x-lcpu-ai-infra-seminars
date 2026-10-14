| 空间 | 谁可见 | 生命周期 | 片上 / 片外 | 谁管理 |
|---|---|---|---|---|
| **register** | 单个线程 | 线程 | 片上 | 编译器 |
| **local** | 单个线程 | 线程 | **片外（通常位于 Global Memory 中）** | 编译器 |
| **shared** | 同一个 Block 内所有线程 | Block | **片上** | 程序员 |
| **global** | 所有线程 + Host | Application（Kernel 调用之间仍存在） | **片外** | 程序员 |
| **constant** | 所有线程 | Application | **片外（有 Constant Cache）** | 程序员 |
| **L1 / L2 cache** | **所有线程（通过对应 Memory 访问）** | Cache 生命周期 | **片上 / 片上（L1片上，L2片上但位置更靠近显存）** | 硬件 |