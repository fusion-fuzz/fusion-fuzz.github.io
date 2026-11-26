import unittest
import sys
mon = sys.monitoring
def add_line(
    code: "types.CodeType",
    lineno: int,
) -> None:
    return mon.DISABLE
def enable():
    mon.use_tool_id(mon.COVERAGE_ID, "regrtest coverage")
    mon.register_callback(mon.COVERAGE_ID, mon.events.LINE, add_line)
    mon.set_events(mon.COVERAGE_ID, mon.events.LINE)
enable()

class CLanguage:
    def __init__(self, filename=None):
        self.filename = filename
    def __init__(self, clang, filename='file', limited_capi=False):
        self.limited_capi = limited_capi
    def parse(self, text):
        norm = dedent(text).strip()
def _make_clinic(*, filename=bytes(range(256)), limited_capi=' '):
    clang = CLanguage(filename)
    return c

class ClinicWholeFileTest(unittest.TestCase):
    def expect_failure(self, raw, errmsg, *, filename=None, lineno=None):
        self.clinic = _make_clinic(filename='test.c')
    def test_directive_output_cant_pop(self):
        raw = '\n            /*[clinic input]\n            output pop\n            [clinic start generated code]*/\n        '
        err = "Can't 'output pop', stack is empty"
        self.expect_failure(raw, err)

if __name__ == "__main__":
    unittest.main()
