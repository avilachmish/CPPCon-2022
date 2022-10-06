
#pragma once

#include <chrono>
#include <fmt/chrono.h>

class timeScope {
public:
    ~timeScope() {
        fmt::print("Elapsed time: {}\n", std::chrono::duration_cast<std::chrono::milliseconds> (std::chrono::high_resolution_clock::now() - start));
    }

private:
    std::chrono::time_point<std::chrono::high_resolution_clock> start = std::chrono::high_resolution_clock::now();
};
