题目	判断	理由
(a)	✅ 正确	同一个 Stream 内操作按提交顺序执行
(b)	✅ 正确	Kernel 启动通常是异步的，CPU 不必等待完成
(c)	✅ 正确（有条件）	CPU 访问 GPU 驻留的托管内存页可能触发缺页与页迁移

CUDA Stream 是 GPU 的一条任务队列。同一个 Stream 中的任务按顺序执行，不同 Stream 中的任务则有机会并行执行。
假设我们创建一个 Stream：
cudaStream_t stream;
cudaStreamCreate(&stream);


然后把三个 Kernel 提交到这个 Stream：
kernelA<<<blocks, threads, 0, stream>>>();
kernelB<<<blocks, threads, 0, stream>>>();
kernelC<<<blocks, threads, 0, stream>>>();


这里 Kernel 的启动语法是：
kernel<<<grid, block, sharedMem, stream>>>();


四个参数分别代表：
参数	含义
grid	Grid 中的 Block 数量
block	每个 Block 的线程数
sharedMem	动态 Shared Memory 字节数
stream	Kernel 提交到哪个 Stream