#ifndef UTIL_H_INCLUDED
#define UTIL_H_INCLUDED

#include <iostream>
#include <cuda_runtime.h>

#define unified_inlined __device__ __host__ __forceinline__

#define CUDA_CHECK(err) \
    do { \
        cudaError_t e = (err); \
        if (e != cudaSuccess) { \
            std::cerr << "CUDA Error: " << cudaGetErrorString(e) \
                      << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
            std::exit(1); \
        } \
    } while (0)


unified_inlined float relative_difference(float a, float b) {
    float max = (a > b) ? a : b;
    return std::abs(a - b) / max;
}
    
#endif

