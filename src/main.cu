#include "types/vector3.cuh"
#include "types/body.cuh"
#include "types/tensor.cuh"
#include "helpers/pgm.h"
#include "tests/n_body_test.cuh"
#include "benchmarks/n_body_benchmark.cuh"

#include <iostream>
#include <vector>
#include <random>


int main() {
    n_body_test(1080*1920, 100, 60.0f);
}