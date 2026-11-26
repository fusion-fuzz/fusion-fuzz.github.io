import threading
import time

def hot_loop():
    # A hot loop involving function calls (time.time) to trigger 
    # Tier 2 JIT optimization.
    # We run this long enough to ensure it's active during interpreter shutdown.
    end = time.time() + 5.0
    while time.time() < end:
        pass

# 1. Create a daemon thread (crucial: daemon threads are killed/abandoned at shutdown)
t = threading.Thread(target=hot_loop, daemon=True)
t.start()

# 2. Allow brief time for the thread to start and trigger the JIT (Trace/Optimizer)
time.sleep(0.1)

# 3. Exit immediately. 
# The daemon thread is still running. The interpreter shutdown process 
# appears to fail to free the JIT memory allocated for this thread.
