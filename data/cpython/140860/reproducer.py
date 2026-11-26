import sys
import time

time_tuple = time.localtime()

events = []
def hook(event, *args):
    events.append((event, args))
sys.addaudithook(hook)

roundtrip('%x', slice(0, 3), tt2)
