方式一（0.0036 ms）：CPU 在启动 Kernel 后立即停止计时，由于 CUDA Kernel 启动是异步的，因此测得的主要是 CPU 侧 Kernel Launch 开销，而不是 GPU 的计算时间。
方式二（2.7311 ms）：CPU 启动 Kernel 后，通过 cudaDeviceSynchronize() 等待 GPU 工作完成。因此测得的是 CPU 视角下的总等待时间，包括 Kernel 执行、Launch 开销、同步与 CPU 调度等额外开销。
方式三（0.2860 ms）：使用 CUDA Event 记录 GPU Stream 中 Kernel 执行前后的时间，避免 CPU 侧启动与等待同步开销，是三种方式中最适合用作 Kernel Performance Index 的结果。
本次实验中 Host 同步计时远高于 CUDA Event 计时，可能受到 CPU 调度、GPU 资源竞争或运行状态波动影响，需要重复实验确认。