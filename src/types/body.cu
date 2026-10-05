#include "body.cuh"

std::ostream& operator<<(std::ostream& os, const Body body) {
    os << "Mass: " << body.mass << ", Position: " << body.position << ", Velocity: " << body.velocity;
    return os;
}