#ifndef BODY_H_INCLUDED
#define BODY_H_INCLUDED

#include <util.cuh>
#include <types/vector3.cuh>

struct Body {

    float mass;
    Vector3 position;
    Vector3 velocity;

    unified_inlined Body() : mass(0.0f), position(), velocity() {}
    unified_inlined Body(float mass, Vector3 position, Vector3 velocity) : mass(mass), position(position), velocity(velocity) {}

    unified_inlined bool operator==(const Body other) const { return mass == other.mass && position == other.position && velocity == other.velocity; }

    unified_inlined float average_difference(const Body other) const {
        return (position.average_difference(other.position) + velocity.average_difference(other.velocity)) / 2.0f;
    }

    friend std::ostream& operator<<(std::ostream& os, const Body body);

};

#endif