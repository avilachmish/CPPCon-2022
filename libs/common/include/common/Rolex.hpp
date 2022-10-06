#ifndef CORECPP__ROLEX_H
#define CORECPP__ROLEX_H

#include <chrono>

class Rolex {
public:
    Rolex() {
        start_ = std::chrono::high_resolution_clock::now();
    }

    ~Rolex() = default;

    auto mesure() {
        stop_ = std::chrono::high_resolution_clock::now();
        return duration_cast<std::chrono::microseconds>(stop_ - start_).count() / 1000;
    }

private:
    std::chrono::time_point<std::chrono::high_resolution_clock> start_;
    std::chrono::time_point<std::chrono::high_resolution_clock> stop_;
};

#endif // CORECPP__ROLEX_H
