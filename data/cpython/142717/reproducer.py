import heapq
import threading

# Shared list to corrupt
l = []

def worker():
    # Loop enough times to trigger the race condition
    for _ in range(100000):
        # 1. Mutate list (push)
        heapq.heappush(l, 1)
        
        # 2. Mutate list (pop) - creates conflict with push/read
        try:
            heapq.heappop(l)
        except IndexError:
            pass
            
        # 3. Read access - this triggers the SEGV when the list state is invalid
        try:
            _ = l[0]
        except IndexError:
            pass

# Spawn threads to maximize concurrency
# 8 threads is usually sufficient to trigger the race quickly
threads = [threading.Thread(target=worker) for _ in range(8)]

for t in threads:
    t.start()

for t in threads:
    t.join()
