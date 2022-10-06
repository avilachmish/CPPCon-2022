#include <thread>
#include <latch>
#include "common/timedScope.hpp"

#ifdef false
alignas(128) std::uint8_t vectorA[10];
alignas(128) std::uint8_t vectorB[10];
#endif

std::int32_t main() {
    static constexpr std::uint32_t vecSize = 10;
    alignas(64) std::uint8_t vectorA[vecSize];
    std::uint8_t vectorB[vecSize];
    std::latch threads_ready{2};
    auto thFunc = [&threads_ready](std::uint8_t *aVector) {

        std::uint64_t myCounter = 10000000;
        threads_ready.arrive_and_wait();
        while (--myCounter) {
            for (std::uint32_t i = 0; i < vecSize; ++i) {
                aVector[i]=i+aVector[i];
            }
        }
    };


    fmt::print("A:[{}-{}]\n", fmt::ptr(&vectorA[0]), fmt::ptr(&vectorA[vecSize - 1]));
    fmt::print("B:[{}-{}]\n", fmt::ptr(&vectorB[0]), fmt::ptr(&vectorB[vecSize - 1]));

    {
        timeScope ts;
        std::jthread t1(
                [thFunc, &vectorA]() {
                    thFunc(vectorA);
                });
        std::jthread t2(
                [thFunc, &vectorB]() {
                    thFunc(vectorB);
                });

    }
}
