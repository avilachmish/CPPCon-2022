#include "common/timedScope.hpp"

constexpr static std::int32_t N = 4096;
constexpr static std::int32_t M = 4096;

double sumArrayRows(double matrix[M][N], std::int32_t stride) {
    std::int32_t i = 0, j = 0;
    double sum = 0;
    for (std::int32_t s = 0; s < stride; ++s) {
        for (i = 0; i < M; ++i) {
            for (j = 0; j < N; ++j) {
                if (s == 0 || i * N + j % s == 0) {
                    sum += matrix[i][j];
                }
            }
        }
    }
    return sum;
}

double sumArrayCols(double matrix[M][N], std::int32_t stride) {
    std::int32_t i = 0, j = 0;
    double sum = 0;
    for (std::int32_t s = 0; s < stride; ++s) {
        for (j = 0; j < N; j++) {
            for (i = 0; i < M; i++) {
                if (s == 0 || j * N + i % s == 0) {
                    sum += matrix[i][j];
                }
            }
        }
    }
    return sum;
}

std::int32_t main(std::int32_t argc, char **) {
    double matrix[M][N];
    memset(matrix, 1, sizeof(matrix[0][0]) * M * N);

    double sum = 0;
    if (argc > 1) {
        timeScope ts;
        for (std::int32_t j = 0; j < 1000; ++j) {
            sum += sumArrayRows(matrix, 2);
        }
    } else {
        timeScope ts;
        for (std::int32_t j = 0; j < 1000; ++j) {
            sum += sumArrayCols(matrix, 2);
        }
    }
    return 0;
}
