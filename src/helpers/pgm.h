#ifndef PGM_H_INCLUDED
#define PGM_H_INCLUDED

#include <fstream>
#include <vector>
#include <cstdint>
#include <string>

bool writePGM8(
    const std::string& filename,
    const uint8_t* pixels,
    int width,
    int height
);

#endif