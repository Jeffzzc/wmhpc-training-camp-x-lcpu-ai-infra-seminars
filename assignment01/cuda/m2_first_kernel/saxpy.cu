#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>

// ============================================================
// 自己实现 CUDA 错误检查宏
// ============================================================
#define CUDA_CHECK(call)                                                   \
    do {                                                                   \
        cudaError_t err = (call);                                          \
        if (err != cudaSuccess) {                                          \
            fprintf(stderr, "CUDA error at %s:%d: %s\n",                  \
                    __FILE__, __LINE__, cudaGetErrorString(err));          \
            exit(1);                                                       \
        }                                                                  \
    } while (0)

// ============================================================
// SAXPY kernel:
//     y <- 2.0 * x + y
// ============================================================
__global__ void saxpy(const float *x, float *y, size_t n){
    size_t i = (size_t)blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n){
        y[i] = 2.0f * x[i] + y[i];
    }
}

int main(int argc, char **argv){
    // --------------------------------------------------------
    // 1. 检查命令行
    // --------------------------------------------------------
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <n>\n", argv[0]);
        return 1;
    }

    char *end = nullptr;
    unsigned long long parsed = strtoull(argv[1], &end, 10);

    if (end == argv[1] || *end != '\0') {
        fprintf(stderr, "Invalid n: %s\n", argv[1]);
        return 1;
    }

    size_t n = (size_t) parsed;

    // --------------------------------------------------------
    // 2. n == 0 特判
    //    因为 <<<0, threads>>> 是非法 launch
    // --------------------------------------------------------
    if (n == 0) {
        printf("SUM=0\n");
        return 0;
    }

    size_t bytes = n * sizeof(float);

    // --------------------------------------------------------
    // 3. Host 内存
    // --------------------------------------------------------
    float *h_x = (float *)malloc(bytes);
    float *h_y = (float *)malloc(bytes);

    if (h_x == nullptr || h_y == nullptr) {
        fprintf(stderr, "Host malloc failed\n");
        free(h_x);
        free(h_y);
        return 1;
    }

    // --------------------------------------------------------
    // 4. 按题目指定公式初始化
    //
    // x[i] = ((i % 2048) - 1024) * 0.5f
    // y[i] = (i % 1024) - 512
    //
    // 注意：
    // i 是 size_t，无符号。
    // 必须先转换成 int，再做减法。
    // --------------------------------------------------------
    for (size_t i = 0; i < n; i++) {
        int xi = (int)(i % 2048) - 1024;
        int yi = (int)(i % 1024) - 512;
        h_x[i] = xi * 0.5f;
        h_y[i] = yi;
    }

    // --------------------------------------------------------
    // 5. Device 内存
    // --------------------------------------------------------
    float *d_x = nullptr;
    float *d_y = nullptr;

    CUDA_CHECK(cudaMalloc(&d_x, bytes));
    CUDA_CHECK(cudaMalloc(&d_y, bytes));

    // --------------------------------------------------------
    // 6. Host -> Device
    // --------------------------------------------------------
    CUDA_CHECK(cudaMemcpy(
        d_x,
        h_x,
        bytes,
        cudaMemcpyHostToDevice
    ));
    CUDA_CHECK(cudaMemcpy(
        d_y,
        h_y,
        bytes,
        cudaMemcpyHostToDevice
    ));

    // --------------------------------------------------------
    // 7. kernel launch 参数
    // --------------------------------------------------------
    const int threads = 512;
    int blocks = (int)((n + threads - 1) / threads);

    // --------------------------------------------------------
    // 8. cudaEvent 计时
    // --------------------------------------------------------
    cudaEvent_t start, stop;

    CUDA_CHECK(cudaEventCreate(&start));
    CUDA_CHECK(cudaEventCreate(&stop));

    CUDA_CHECK(cudaEventRecord(start));

    saxpy<<<blocks, threads>>>(d_x, d_y, n);

    // 检查 kernel launch 本身是否合法
    CUDA_CHECK(cudaGetLastError());

    CUDA_CHECK(cudaEventRecord(stop));

    // 等 stop event，即等 kernel 完成
    CUDA_CHECK(cudaEventSynchronize(stop));

    float timeInterval = 0.0f;

    CUDA_CHECK(cudaEventElapsedTime(
        &timeInterval,
        start,
        stop
    ));

    // --------------------------------------------------------
    // 9. Device -> Host
    // --------------------------------------------------------
    CUDA_CHECK(cudaMemcpy(
        h_y,
        d_y,
        bytes,
        cudaMemcpyDeviceToHost
    ));

    // --------------------------------------------------------
    // 10. 用 double 累加最终 y
    // --------------------------------------------------------
    double s = 0.0;

    for (size_t i = 0; i < n; i++){
        s += (double)h_y[i];
    }

    // 判测脚本会使用 SUM
    printf(
        "SUM=%.0f n=%zu kernel_ms=%.3f\n",
        s,
        n,
        timeInterval
    );

     // --------------------------------------------------------
    // 11. 清理
    // --------------------------------------------------------
    CUDA_CHECK(cudaEventDestroy(start));
    CUDA_CHECK(cudaEventDestroy(stop));

    CUDA_CHECK(cudaFree(d_x));
    CUDA_CHECK(cudaFree(d_y));

    free(h_x);
    free(h_y);

    return 0;
}