Prob 6.2（CONCEPT）：CUDA SIMT、cuTile 与 Triton 对比
答案
| 对比项 | CUDA SIMT | cuTile | Triton |
|---|---|---|---|
| **并行单位** | Block 内的 Thread | Block | Program Instance（逻辑上类似 Block） |
| **编号** | `blockIdx`、`threadIdx` | `ct.bid(0)` | `tl.program_id(0)` |
| **数据分工** | 每个线程利用全局下标确定要处理的元素 | 用 `tiled_view` 将 Array 分成 Tile，Block 根据 `bid` 加载并处理对应 Tile；具体线程映射由编译器负责 | 每个 Program Instance 根据 `program_id` 和 `tl.arange` 生成所处理元素的下标，具体线程映射由编译器负责 |
| **边界处理** | `if (i < n)` | Tile `load` / `store` 支持自动边界检查；越界 Load 可设置零填充 | `tl.load` / `tl.store` 使用 `mask` 过滤越界元素 |


简要说明
1. CUDA SIMT：程序员编写单个线程的逻辑，显式计算 i = blockIdx.x * blockDim.x + threadIdx.x，并通过 if (i < n) 处理越界。
2. cuTile：程序员编写 Block 级 Tile 运算，通过 a.tiled_view((TILE,)) 划分数据，ct.bid(0) 选择 Tile，load、运算、store 完成计算，具体 Thread 分工由编译器决定。
3. Triton：程序员编写 Program Instance 级逻辑，用 tl.program_id(0) 定位数据块、tl.arange 生成元素下标，并通过 mask 处理边界。
注意：cuTile 的边界检查与越界元素的取值是两回事：越界加载的值默认不保证为零；若计算要求零填充，应明确指定 padding_mode=ct.PaddingMode.ZERO（在相应 Tiled View 上设置）。
一句话总结：SIMT 显式管理 Thread；cuTile 面向 Tile；Triton 面向 Program Instance 和向量化元素操作。