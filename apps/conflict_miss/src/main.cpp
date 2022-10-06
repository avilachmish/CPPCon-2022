#include "common/timedScope.hpp"

constexpr static std::int32_t N = 4096;
constexpr static std::int32_t M = 4096;

double sumArrayRows(double matrix[M][N], std::uint32_t row, std::uint32_t col) {
    std::uint32_t i = 0, j = 0;
    double sum = 0;
    for (i = row; i < 32; i++) {
        for (j = col; j < 32; j++) {
            sum += matrix[i][j];
        }
    }
    return sum;
}
template <std::size_t MM,std::size_t NN>
double sumArrayCols(double matrix[MM][NN], std::int32_t row, std::int32_t col) {
    std::uint32_t i = 0, j = 0;
    double sum = 0;
    for (j = col; j < 32; j++) {
        for (i = row; i < 32; i++) {
            sum += matrix[i][j];
        }
    }
    return sum;
}

std::int32_t main(std::int32_t argc, char **) {
    double matrix[M][N];
    memset(matrix, 1, sizeof(matrix[0][0]) * M * N);

    double i = 0;
    if (argc > 1) {//good
        timeScope ts;
        double subMatrix[32][32];
        for(std::int32_t sub_j = 0; sub_j < 32; ++sub_j)
            for(std::int32_t sub_i = 0; sub_i < 32; ++sub_i)
                subMatrix[sub_j][sub_i]  = matrix[sub_j][sub_i];
        for (std::int32_t j = 0; j < 100000; ++j) {
            i += sumArrayCols<32,32>(subMatrix, 0, 0);
        }
    } else {
        timeScope ts;
        for (std::int32_t j = 0; j < 100000; ++j) {
            i += sumArrayCols<M,N>(matrix, 0, 0);
        }
    }
    fmt::print("the sum ={}\n", i);
    return 0;
}
