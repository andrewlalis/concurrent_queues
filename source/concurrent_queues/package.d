module concurrent_queues;

import std.typecons : Nullable;

interface ConcurrentQueue(T) {
    void enqueue(T item);
    T dequeue();
    size_t size();
    T peek();
}
