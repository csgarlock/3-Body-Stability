#include "pgm.h"

bool writePGM8(
    const std::string& filename,
    const uint8_t* pixels,
    int width,
    int height
) {
    if (!pixels || width <= 0 || height <= 0)
        return false;

    std::ofstream out(filename, std::ios::binary);
    if (!out)
        return false;

    out << "P5\n"
        << width << " " << height << "\n"
        << "255\n";

    out.write(reinterpret_cast<const char*>(pixels),
              width * height);

    return out.good();
}
