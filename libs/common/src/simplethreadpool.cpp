#include <chrono>
#include "common/simplethreadpool.hpp"

using namespace std::chrono_literals;

thread_pool::thread_pool(unsigned num_threads) :
        threads(num_threads) {
    for (auto &entry: threads) {
        entry = std::jthread(
                [&](std::stop_token token) { thread_func(token); });
    }
}

thread_pool::~thread_pool() = default;

void thread_pool::submit(task_type func) {
    {
        std::lock_guard guard(mut);
        queue.emplace(std::move(func));
    }
    cond.notify_all();
}

void thread_pool::thread_func(std::stop_token stop) {
    while (!stop.stop_requested()) {
        std::unique_lock lock(mut);
        if (!cond.wait_until(
                lock, stop, std::chrono::system_clock::now() + 1s, [&] { return !queue.empty(); })) {
            return;
        }
        auto task = std::move(queue.front());
        queue.pop();
        lock.unlock();
        task();
    }
}
