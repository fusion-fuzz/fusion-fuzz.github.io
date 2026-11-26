import json
import sys
import threading

sys.setswitchinterval(1e-6)   # makes the race frequent; it also happens without this

def worker(data, index):
    while data:
        for d in list(data):
            try:
                if len(d) > 5:
                    d.pop(next(iter(d)), None)
                else:
                    d[index] = index
            except Exception:
                pass

data = [{}, {}]
threads = [threading.Thread(target=worker, args=(data, i), daemon=True) for i in range(4)]
for t in threads:
    t.start()
for _ in range(200):
    try:
        json.dumps(data)
    except Exception:
        pass
data.clear()
for t in threads:
    t.join(1.0)
print("done")
