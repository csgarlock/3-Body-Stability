#include <tests/n_body_test.cuh>
#include <types/body.cuh>
#include <types/tensor.cuh>
#include <types/vector3.cuh>
#include <kernels/n_body.cuh>
#include <util.cuh>

#include <iostream>
#include <vector>
#include <random>

#define OBJECT_COUNT 3

Vector3 acceleration(int idx, Vector3 x, const Body bodies[OBJECT_COUNT]);
void make_step(Body bodies[OBJECT_COUNT], float dt);

void n_body_test(size_t count, int steps, float dt) {

    std::cout << "Running 3-body test on Device and Host" << std::endl;

    std::mt19937 rng(time(0));
    std::uniform_real_distribution<float> pos_dist(-1.0e10f, 1.0e10f);
    std::uniform_real_distribution<float> mass_dist(1e26, 2e26); 

    Tensor<Body> device_bodies({count * 3}, MemoryLocation::Host);
    Tensor<Body> host_bodies({count * 3}, MemoryLocation::Host);
    for (int i = 0; i < count * 3; i++) {
        host_bodies.data[i].mass = mass_dist(rng);
        host_bodies.data[i].position = Vector3(pos_dist(rng), pos_dist(rng), pos_dist(rng));
        host_bodies.data[i].velocity = Vector3(0.0f, 0.0f, 0.0f);
        device_bodies.data[i] = host_bodies.data[i]; 
    }
    
    std::cout << "Running Device Version..." << std::endl;
    device_bodies.change_memory_location(MemoryLocation::Device);
    n_body_forward<<<16, 256>>>(device_bodies.data, count, steps, dt);
    CUDA_CHECK(cudaDeviceSynchronize());
    device_bodies.change_memory_location(MemoryLocation::Host);
    
    std::cout << "Running Host Version..." << std::endl;
    for (int i = 0; i < count; i++) {
        Body *body_start = host_bodies.data + (i * 3);
        for (int step = 0; step < steps; step++) {
            make_step(body_start, dt);
        }
    }

    float max_error = 0.0f;
    float total_error = 0.0f;
    for (int i = 0; i < count * 3; i++) {
        total_error += device_bodies.data[i].average_difference(host_bodies.data[i]);
        if (device_bodies.data[i].average_difference(host_bodies.data[i]) > max_error) {
            max_error = device_bodies.data[i].average_difference(host_bodies.data[i]);
        }
    }
    std::cout << "Max error between Host and Device: " << max_error << std::endl;
    std::cout << "Average error between Host and Device: " << total_error / count << std::endl;
}


void make_step(Body bodies[OBJECT_COUNT], float dt) {

    const float dt2 = dt * 0.5f;
    const float dt6 = dt / 6.0f;

    Body new_bodies[OBJECT_COUNT];
    for (int i = 0; i < OBJECT_COUNT; i++) {
        Body &current_body = bodies[i];
        Vector3 k1a = acceleration(i, current_body.position, bodies);
        Vector3 k1v = current_body.velocity;

        Vector3 k2a = acceleration(
            i,
            current_body.position + k1v * dt2,
            bodies
        );
        Vector3 k2v = current_body.velocity + k1a * dt2;

        Vector3 k3a = acceleration(
            i,
            current_body.position + k2v * dt2,
            bodies
        );
        Vector3 k3v = current_body.velocity + k2a * dt2;

        Vector3 k4a = acceleration(
            i,
            current_body.position + k3v * dt,
            bodies
        );
        Vector3 k4v = current_body.velocity + k3a * dt;
        new_bodies[i] = Body(
            current_body.mass,
            current_body.position + (k1v + k2v * 2.0f + k3v * 2.0f + k4v) * dt6,
            current_body.velocity + (k1a + k2a * 2.0f + k3a * 2.0f + k4a) * dt6
        );
    }
    for (int i = 0; i < OBJECT_COUNT; i++) {
        bodies[i] = new_bodies[i];
    }
}

Vector3 acceleration(int idx, Vector3 x, const Body bodies[OBJECT_COUNT]) {
    
    const float G = 6.67e-11;
    const float epsilon = 1e4; // inital guess for planetary scale objects will need to be tuned
    const float eps2 = epsilon * epsilon;

    Vector3 sum(0.0f, 0.0f, 0.0f); 
    for (int i = 0; i < OBJECT_COUNT; i++) {
        if (i != idx) {
            Vector3 r = bodies[i].position - x;
            float r2 = r.dot(r) + eps2;
            float rec_r3 = 1.0f / (sqrtf(r2) * r2);
            sum += r * (bodies[i].mass * rec_r3);
        }
    }
    return sum * G;
}