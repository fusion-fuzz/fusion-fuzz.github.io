import multiprocessing

s = multiprocessing.Semaphore(0)
s.acquire(timeout=float("inf"))   # also 1e19, 1e300
