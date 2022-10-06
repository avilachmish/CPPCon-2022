#include <fmt/core.h>
#include "common/timedScope.hpp"

constexpr static std::int32_t N = 4096;
constexpr static std::int32_t M = 4096;

double sumArrayRows(double matrix[M][N]) {
    std::int32_t i, j;
    double sum = 0;
    for (i = 0; i < M; i++) {
        for (j = 0; j < N; j++) {
            sum += matrix[i][j];
        }
    }
    return sum;
}

double sumArrayCols(double matrix[M][N]) {
    std::int32_t i, j;
    double sum = 0;

    for (j = 0; j < N; j++) {
        for (i = 0; i < M; i++) {
            sum += matrix[i][j];
        }
    }
    return sum;
}

std::int32_t main(std::int32_t argc, char **) {
    double matrix[M][N];

    memset(matrix, 1, sizeof(matrix[0][0]) * M * N);
    double i = 0;
    if (argc > 1) {
        timeScope ts;
        for (std::int32_t j = 0; j < 1; ++j) {
            i += sumArrayRows(matrix);
        }
        fmt::print("{}\n", i);
    } else {
        timeScope ts;
        for (std::int32_t j = 0; j < 1; ++j) {
            i += sumArrayCols(matrix);
        }
        fmt::print("{}\n", i);
    }
    return 0;
}
