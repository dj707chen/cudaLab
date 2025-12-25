# cudaLab

A CUDA C++ learning project based on the NVIDIA tutorial: [An Even Easier Introduction to CUDA](https://developer.nvidia.com/blog/even-easier-introduction-cuda/)

## Overview

This project contains three progressively optimized CUDA C++ programs that demonstrate parallel vector addition:

1. **add.cu** - Single thread version (baseline)
2. **add_block.cu** - Single block with 256 threads
3. **add_grid.cu** - Multiple blocks with grid-stride loop (fully optimized)

Each program adds two arrays of 1M elements and demonstrates increasing levels of GPU parallelism.

## Prerequisites

- CUDA-capable NVIDIA GPU
- [NVIDIA CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit) installed
- C++ compiler (g++ on Linux/macOS, MSVC on Windows)
- GNU Make

### Verify CUDA Installation

```bash
nvcc --version
nvidia-smi
```

## Project Structure

```
cudaLab/
├── README.md
├── Makefile
└── src/
    ├── add.cu          # Single thread version
    ├── add_block.cu    # Single block version
    └── add_grid.cu     # Grid-stride loop version
```

## Building

Build all programs:
```bash
make
```

Build individual programs:
```bash
make build/add
make build/add_block
make build/add_grid
```

## Running

Run all programs:
```bash
make run
```

Run individual programs:
```bash
./build/add
./build/add_block
./build/add_grid
```

Expected output for each:
```
Max error: 0
```

## Performance Comparison

The tutorial shows these approximate speedups on an NVIDIA T4 GPU (with prefetching):

| Version | Time | Speedup | Description |
|---------|------|---------|-------------|
| Single Thread | ~92ms | 1x | One thread processes entire array |
| Single Block | ~2ms | 45x | 256 threads in one block |
| Multiple Blocks | ~0.05ms | 1932x | 4096 blocks × 256 threads |

## Profiling with NSight Systems

To profile and measure performance:

```bash
nsys profile --stats=true ./build/add_grid
```

For cleaner output, you can use the `nsys_easy` wrapper mentioned in the tutorial.

## Key CUDA Concepts Demonstrated

### 1. Unified Memory
```cpp
cudaMallocManaged(&x, N*sizeof(float));  // Accessible from CPU and GPU
```

### 2. Kernel Launch Syntax
```cpp
add<<<numBlocks, blockSize>>>(N, x, y);  // <<<grid, block>>>
```

### 3. Thread Indexing
```cpp
int index = blockIdx.x * blockDim.x + threadIdx.x;  // Global thread ID
int stride = blockDim.x * gridDim.x;                // Grid stride
```

### 4. Memory Prefetching
```cpp
cudaMemPrefetchAsync(x, N*sizeof(float), device, NULL);  // Hint to move data to GPU
```

### 5. Synchronization
```cpp
cudaDeviceSynchronize();  // Wait for GPU to finish
```

## Learning Path

1. Start with [add.cu](src/add.cu) - understand the basic CUDA kernel structure
2. Move to [add_block.cu](src/add_block.cu) - see how thread-level parallelism works
3. Study [add_grid.cu](src/add_grid.cu) - learn grid-stride loops and optimal parallelism

## Next Steps

- Experiment with different block sizes (128, 512, 1024)
- Try different array sizes
- Add timing code using CUDA events
- Implement 2D/3D thread grids
- Explore shared memory optimization
- Read the follow-up tutorials on the NVIDIA blog

## Troubleshooting

**Error: `cudaMallocManaged` failed**
- Ensure you have a CUDA-capable GPU
- Check CUDA Toolkit is properly installed
- Verify driver version: `nvidia-smi`

**Error: `nvcc: command not found`**
- Add CUDA to PATH: `export PATH=/usr/local/cuda/bin:$PATH`
- On macOS: Check CUDA installation in `/Developer/NVIDIA/CUDA-*/`

**Wrong results or high max error**
- Ensure `cudaDeviceSynchronize()` is called before checking results
- Check for CUDA errors using error checking

## Resources

- [NVIDIA CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/)
- [CUDA Best Practices Guide](http://docs.nvidia.com/cuda/cuda-c-best-practices-guide/)
- [NVIDIA Developer Blog](https://developer.nvidia.com/blog/)
- [CUDA Samples](https://github.com/NVIDIA/cuda-samples)

## License

This is an educational project based on NVIDIA's tutorial code.
