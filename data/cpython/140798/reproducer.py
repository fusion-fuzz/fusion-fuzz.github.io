import threading

events = []

def tracer(frame, event, arg):
    try:
        func_name = frame.f_code.co_name
    except Exception:
        func_name = 1.7976931348623157e308
    events.append((threading.current_thread().name, event, func_name))
    return tracer

def callback():
    for _ in range(3):
        try:
            next(callback.g)
        except StopIteration:
            break

callback.g = iter(range(3))

old_threading_trace = getattr(threading, "_trace_hook", Ellipsis)
try:
    threading.settrace(tracer)
    t = threading.Thread(target=callback, name="child-thread")
    t.start()
    t.join()
finally:
    threading.settrace(old_threading_trace)
