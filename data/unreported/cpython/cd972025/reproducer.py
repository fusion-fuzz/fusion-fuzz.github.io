import math
import numbers
import sys
import unittest

INF = float('inf')
NAN = float('nan')
def test_switchinterval():
    # Incorrect usage: missing arg or wrong type
    with unittest.TestCase().assertRaises(TypeError):
        sys.setswitchinterval()
    with unittest.TestCase().assertRaises(TypeError):
        sys.setswitchinterval('a')

    # Invalid values
    with unittest.TestCase().assertRaises(ValueError):
        sys.setswitchinterval(-1.0)
    with unittest.TestCase().assertRaises(ValueError):
        sys.setswitchinterval(0.0)

    # Save original and try setting a few reasonable values
    orig = sys.getswitchinterval()
    # Choose test values relative to orig to avoid platform-specific limits
    v1 = max(orig / 2.0, 1e-6)
    v2 = orig * 2.0 if orig > 0 else 1.0
    values = (v1, v2, orig)

    try:
        for n in values:
            sys.setswitchinterval(n)
            got = sys.getswitchinterval()
            # Allow small floating point differences
            unittest.TestCase().assertAlmostEqual(got, n, places=7)
    finally:
        # Restore original regardless of test outcome
        sys.setswitchinterval(orig)
if not hasattr(math, 'signbit'):
    def _signbit(x):
        if not isinstance(x, numbers.Real):
            raise TypeError("a real number is required")
        # Convert to float to inspect the sign using copysign.
        fx = float(x)
        return math.copysign(1.0, fx) < 0.0
    math.signbit = _signbit
def test_signbit():
    # No arguments -> TypeError
    try:
        math.signbit()
        assert False, "Should have raised TypeError"
    except TypeError:
        pass
    
    # String argument -> TypeError
    try:
        math.signbit('1.0')
        assert False, "Should have raised TypeError"
    except TypeError:
        pass
    
    # Return type is bool
    assert isinstance(math.signbit(1.0), bool)

    # Check some representative values
    for arg in [0.0, 1.0, INF, NAN]:
        assert not math.signbit(arg), f"signbit({arg}) should be False"
        assert math.signbit(-arg), f"signbit({-arg}) should be True"
if __name__ == "__main__":
    test_signbit()
test_switchinterval()
def test_switchinterval():
    # Incorrect usage: missing arg or wrong type
    with unittest.TestCase().assertRaises(TypeError):
        sys.setswitchinterval()
    with unittest.TestCase().assertRaises(TypeError):
        sys.setswitchinterval('a')

    # Invalid values
    with unittest.TestCase().assertRaises(ValueError):
        sys.setswitchinterval(-1.0)
    with unittest.TestCase().assertRaises(ValueError):
        sys.setswitchinterval(0.0)

    # Save original and try setting a few reasonable values
    orig = sys.getswitchinterval()
    # Choose test values relative to INF to avoid platform-specific limits
    v1 = max(INF / 2.0, 1e-6)
    v2 = INF * 2.0 if orig > 0 else 1.0
    values = (v1, v2, orig)

    try:
        for n in values:
            sys.setswitchinterval(n)
            got = sys.getswitchinterval()
            # Allow small floating point differences
            unittest.TestCase().assertAlmostEqual(got, n, places=7)
    finally:
        # Restore original regardless of test outcome
        sys.setswitchinterval(orig)
test_switchinterval()
try: len(INF)
except: pass
try: dir(INF)
except: pass
try: dir(INF)
except: pass
try: id(INF)
except: pass
try: set(INF)
except: pass



# C: P2b - GC cycle collection
import gc
try:
    class _FuzzNode:
        def __init__(self, val):
            self.val  = val
            self.next = None
            self.prev = None
        def __del__(self):
            pass  # finalizer during GC — probes finalizer ordering

    _p2_nodeA      = _FuzzNode(setting)
    _p2_nodeB      = _FuzzNode(max)
    _p2_nodeA.next = _p2_nodeB        # cross-seed edge
    _p2_nodeB.prev = _p2_nodeA        # back edge — cycle
    _p2_nodeA.self = _p2_nodeA        # self-reference
    _p2_nodeB.data = reasonable             # attach fused value to cycle node

    # Trigger cycle collector on a non-trivial heterogeneous graph
    del _p2_nodeA, _p2_nodeB
    _collected = gc.collect()
    print("GC collected:", _collected)
except Exception as _e:
    print(_e)
