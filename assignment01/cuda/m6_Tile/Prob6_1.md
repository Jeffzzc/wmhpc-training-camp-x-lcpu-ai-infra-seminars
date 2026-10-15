(a) 错误 ❌
Tile 不是显存中一块可变的内存区域，而是 Block 内的逻辑数据集合。
- Tile 是不可变的（Immutable），对 Tile 进行运算会产生新的 Tile。
- Tile 不一定存储在显存中，编译器决定使用 Register、Shared Memory 或其他硬件资源。
- 可以通过 store 操作将 Tile 的计算结果写回 Global Array。
例如：
C_tile = A_tile + B_tile



这里产生新的 C_tile，并不是直接修改显存中的某块区域。
(b) 正确 ✅
Tile 运算由编译器自动映射到 Block 内的多个线程上并行执行。
例如：
C_tile = A_tile + B_tile



假设 Tile 包含 256 个元素，那么这次运算需要完成 256 次元素级加法。
程序员只需要描述 Tile 加法，编译器负责决定：
- 使用多少个线程。
- 每个线程计算哪些元素。
- 如何组织底层执行。
因此，Tile Programming 是一种 Block 级别的编程抽象。
(c) 错误 ❌
Tile Programming 和 SIMT Programming 并不互斥，可以在同一个 CUDA 程序中共存。
例如，一个 CUDA 程序可以包含：
- SIMT Kernel：使用 __global__ 定义，显式管理 Thread。
- Tile Kernel：使用 __tile_global__ 定义，由编译器管理线程映射。
两种 Kernel 可以在同一个程序中分别启动，处理不同任务，也可以通过 Global Memory 交换数据。
但这不代表可以在同一个 Kernel 函数中随意混合两套编程模型。