/**
 * A basic array-based queue that controls concurrent access via a mutex,
 * so that only one thread may modify the queue at any time.
 */
module concurrent_queues.blocking;

import core.sync.rwmutex;
import core.sync.semaphore;
import concurrent_queues : ConcurrentQueue;

class ConcurrentBlockingQueue(T) : ConcurrentQueue!T {
    private T[] array;
    private size_t front = 0;
    private size_t back = 0;
    private ReadWriteMutex mutex;
    private Semaphore semaphore;

    this(size_t initialSize = 64) {
        this.mutex = new ReadWriteMutex();
        this.semaphore = new Semaphore();
        this.array = new T[](initialSize);
    }

    void enqueue(T item) {
        synchronized(mutex.writer) {
            if (back == array.length) {
                assert(false, "Ran out of space!");
                return;
            }
            array[back++] = item;
            if (back == size) {
                if (front == 0) {
                    // array is full, expand it!
                    array.length *= 2;
                } else {
                    // Shift all elements to the front of the array.
                    const size_t elements = back - front;
                    array[0..elements] = array[front..back];
                    array[elements..$] = T.init;
                    front = 0;
                    back = elements;
                }
            }
        }
        semaphore.notify();
    }

    T dequeue() {
        try {
            bool success = semaphore.wait(msecs(10_000));
            if (success) {
                synchronized(mutex.writer) {
                    if (front >= back) return T.init;
                }
            }
        }
    }

    size_t size() {

    }

    T peek() {

    }
}

unittest {
    auto q = new ConcurrentBlockingQueue!int;
}
