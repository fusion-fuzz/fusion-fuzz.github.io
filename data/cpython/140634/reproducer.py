import copy
import posix

param = posix.sched_param(float('inf'))
newparam = copy.deepcopy(param)
