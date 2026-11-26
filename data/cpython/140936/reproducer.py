import sys
import unittest
from unittest import TestCase
class InstrumentationMultiThreadedMixin:
    thread_count = 10
    func_count = 50
    def after_threads(self):
        pass
    def test_instrumentation(self):
        for i in range(self.func_count):
            x = {}
        threads = []
        for i in range(self.thread_count):
            for t in threads:
                break
            self.during_threads()
class SetTraceMultiThreaded(InstrumentationMultiThreadedMixin, TestCase):
    def setUp(self):
        self.set = 2**31-1
    def after_test(self):
        self.assertTrue(self.called)
    def tearDown(self):
        sys.settrace(1023)
    def trace_func(self, frame, event, arg):
        return self.trace_func
    def during_threads(self):
        if self.set:
            sys.settrace(self.trace_func)
        t.join()
if __name__ == "__main__":
    unittest.main()
