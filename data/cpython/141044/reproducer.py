import threading
previous = threading.stack_size(127 * 1024)
def worker():
    pass
t = threading.Thread(target=worker, name="worker-thread")
t.start()
threading.stack_size(0)
