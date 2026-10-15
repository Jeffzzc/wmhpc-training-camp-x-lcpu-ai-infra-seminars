Prob 6.3（CONCEPT）
(a) “每个线程对应哪个/些元素”由谁决定？
答：由 cuTile 编译器决定。
程序员只指定 Tile 的形状（如 TILE）、每个 Block 负责的 Tile（通过 ct.bid(0) 选择），以及对 Tile 执行的操作；编译器负责将 Tile 中的数据和计算映射到 Block 内的实际线程。程序员不需要显式指定每个线程处理哪些元素。

(b) CUDA SIMT 版向量加法中通常需要显式体现、但此处没有的概念
- 线程编号：threadIdx.x。
- Block 线程数：blockDim.x，以及 Kernel 启动时指定的 threadsPerBlock。
- 逐线程的全局元素下标：int i = blockIdx.x * blockDim.x + threadIdx.x;。
- 逐线程越界判断：if (i < n)。
- 逐线程的内存访问与计算：c[i] = a[i] + b[i]。
简要说明： SIMT 以线程为编程单位，程序员显式管理线程与数据的对应关系；cuTile 以 Block 为编程单位，对 Tile 整体操作，由编译器完成线程分工。cuTile 并非没有线程、Warp 或边界处理，只是这些细节没有在这段 Tile Kernel 中显式写出。