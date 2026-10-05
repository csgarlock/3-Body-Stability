#include <benchmarks/n_body_benchmark.cuh>
#include <types/body.cuh>
#include <types/tensor.cuh>
#include <types/vector3.cuh>
#include <kernels/n_body.cuh>
#include <util.cuh>

#include <iostream>
#include <vector>
#include <random>
#include <chrono>

void benchmark_n_body(size_t count, int steps, float dt) {
    std::cout << "Running 3-body Benchmark" << std::endl;

    std::mt19937 rng(time(0));
    std::uniform_real_distribution<float> pos_dist(-1.0e10f, 1.0e10f);
    std::uniform_real_distribution<float> mass_dist(1e26, 2e26); 

    Tensor<Body> device_bodies({count * 3}, MemoryLocation::Host);
    for (int i = 0; i < count * 3; i++) {
        device_bodies.data[i].mass = mass_dist(rng);
        device_bodies.data[i].position = Vector3(pos_dist(rng), pos_dist(rng), pos_dist(rng));
        device_bodies.data[i].velocity = Vector3(0.0f, 0.0f, 0.0f);
    }

    device_bodies.change_memory_location(MemoryLocation::Device);
    auto start = std::chrono::high_resolution_clock::now();
    n_body_forward<<<76, 1024>>>(device_bodies.data, count, steps, dt);
    CUDA_CHECK(cudaDeviceSynchronize());
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
    float time_sec = (float) duration.count() / 1000.0f;
    long total_steps = (long) count * steps;
    std::cout << "Total Steps: " << total_steps << std::endl;
    std::cout << "Time take: " << time_sec << " Seconds" << std::endl;
    std::cout << "Million Steps per Second: " << (float) total_steps / time_sec / 1000000.0 << std::endl;

}
    