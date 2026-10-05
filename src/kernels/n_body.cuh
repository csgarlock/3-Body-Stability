#ifndef N_BODY_H_INCLUDED
#define N_BODY_H_INCLUDED

#include "../util.cuh"
#include "../types/body.cuh"
#include "../types/vector3.cuh"

template <int BodyCount = 3>
__device__ __forceinline__ Vector3 acceleration(int idx, Vector3 x, const Body bodies[BodyCount]) {
    
    const float G = 6.67e-11;
    const float epsilon = 1e4; // inital guess for planetary scale objects will need to be tuned
    const float eps2 = epsilon * epsilon;

    Vector3 sum(0.0f, 0.0f, 0.0f); 
    #pragma unroll
    for (int i = 0; i < BodyCount; i++) {
        if (i != idx) {
            Vector3 r = bodies[i].position - x;
            float r2 = r.dot(r) + eps2;
            float rec_r3 = 1.0f / (sqrtf(r2) * r2);
            sum += r * (bodies[i].mass * rec_r3);
        }
    }
    return sum * G;
}

template <int BodyCount = 3>
__global__ void n_body_forward(Body *__restrict__ all_bodies, int num_sims, int steps, float dt) {

    const int start_index = blockIdx.x * blockDim.x + threadIdx.x;
    const int stride = gridDim.x * blockDim.x;
    const float dt2 = dt * 0.5f;
    const float dt6 = dt / 6.0f;
    Body bodies[BodyCount];
    Body new_bodies[BodyCount];

    for (int idx = start_index; idx < num_sims; idx += stride) {
        
        int effective_index = idx * BodyCount;
        for (int i = 0; i < BodyCount; i++) {
            bodies[i] = all_bodies[effective_index + i];
        }

        for (int step = 0; step < steps; step++) {

            for (int i = 0; i < BodyCount; i++) {
                Body &current_body = bodies[i];
                Vector3 k1a = acceleration<BodyCount>(i, current_body.position, bodies);
                Vector3 k1v = current_body.velocity;

                Vector3 k2a = acceleration<BodyCount>(
                    i,
                    current_body.position + k1v * dt2,
                    bodies
                );
                Vector3 k2v = current_body.velocity + k1a * dt2;

                Vector3 k3a = acceleration<BodyCount>(
                    i,
                    current_body.position + k2v * dt2,
                    bodies
                );
                Vector3 k3v = current_body.velocity + k2a * dt2;

                Vector3 k4a = acceleration<BodyCount>(
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

            for (int i = 0; i < BodyCount; i++) {
                bodies[i] = new_bodies[i];
            }
        }

        for (int i = 0; i < BodyCount; i++) {
            all_bodies[effective_index + i] = bodies[i];
        }

    }
}


#endif