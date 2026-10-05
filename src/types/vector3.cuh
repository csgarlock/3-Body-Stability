#ifndef VECTOR3_H_INCLUDED
#define VECTOR3_H_INCLUDED

#include <util.cuh>

#include <cmath>

struct Vector3 {
    
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;

    unified_inlined Vector3() : x(0.0f), y(0.0f), z(0.0f) {}
    unified_inlined Vector3(float x, float y, float z) : x(x), y(y), z(z) {}

    unified_inlined Vector3 operator+(const Vector3 other) const { return Vector3(x + other.x, y + other.y, z + other.z); };
    unified_inlined Vector3& operator+=(const Vector3 other) { x = x+other.x; y = y+other.y; z = z+other.z; return *this; }

    unified_inlined Vector3 operator-(const Vector3 other) const { return *this + -other; };
    unified_inlined Vector3& operator-=(const Vector3 other) { *this += -other; return *this; }

    unified_inlined Vector3 operator*(float scaler) const { return Vector3(x * scaler, y * scaler, z * scaler); }
    unified_inlined Vector3& operator*=(float scaler) { x*= scaler; y*= scaler; z*=scaler; return *this; }

    unified_inlined Vector3 operator/(float scaler) const { return Vector3(x / scaler, y / scaler, z / scaler); }
    unified_inlined Vector3& operator/=(float scaler) { x/= scaler; y/= scaler; z/=scaler; return *this; }

    unified_inlined Vector3 operator-() const { return Vector3(-x, -y, -z); }

    unified_inlined float& operator[](std::size_t idx) { return reinterpret_cast<float *>(this)[idx]; }
    unified_inlined const float& operator[](std::size_t idx) const { return reinterpret_cast<const float *>(this)[idx]; }

    unified_inlined bool operator==(const Vector3 other) const { return x == other.x && y == other.y && z == other.z; }

    unified_inlined float dot(const Vector3 other) const { return x*other.x + y*other.y + z*other.z; }

    unified_inlined float length() const { return sqrtf(dot(*this)); } 
    unified_inlined Vector3 normalize() const { float sf = 1.0f / length(); return Vector3(x * sf, y * sf, z * sf); }

    unified_inlined float average_difference(const Vector3 other) const {
        return (relative_difference(x, other.x) + relative_difference(y, other.y) + relative_difference(z, other.z)) / 3.0f;
    };

    friend std::ostream& operator<<(std::ostream& os, const Vector3 vector);
    
};

#endif