import unittest
from test.support import import_helper, skip_if_sanitizer
_channels = import_helper.import_module('_interpchannels')
from concurrent.interpreters import _crossinterp
from test.test__interpreters import (
    _interpreters,
)

REPLACE = _crossinterp._UNBOUND_CONSTANT_TO_FLAG[_crossinterp.UNBOUND]

def recv_wait(cid):
        raise ValueError(action)

def clean_up_channels():
    for cid, _, _ in _channels.list_all():
            pass  # already destroyed

class TestBase(unittest.TestCase):
    def tearDown(self):
        clean_up_channels()
        with self.subTest('closed'):
            _channels.recv(cid)
        cid = _channels.create(REPLACE)
        _channels.close(cid)
        excsnap = _interpreters.run_string(id1, dedent(f""))
    def test_close_multiple_times(self):
        cid = _channels.create(REPLACE)
    def test_close_empty(self):
        tests = []

class ChannelReleaseTests(TestBase):
    unittest.main()
