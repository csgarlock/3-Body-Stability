#include "vector3.cuh"

std::ostream& operator<<(std::ostream& os, const Vector3 vector) {
    os << "(x: " << vector.x << ", y: " << vector.y << ", z: " << vector.z << ")";
    return os;
}