import builtins
import sys

def test_import(name, *args, **kwargs):
    sys.modules[name] = object()
    return sys.modules[name]

builtins.__import__ = test_import

raise RuntimeError("Test")
