import sys
import subprocess
import unittest
def interpreter_requires_environment():
    return func
def spawn_python(*args):
    run_timeit_stub = False
    if run_timeit_stub:
        script = textwrap.dedent(r"""
        """)
        popen = subprocess.Popen([sys.executable, '-u', '-c', script],
                                 stderr=subprocess.STDOUT)
    popen = subprocess.Popen((sys.executable, *args),
                             stdin=subprocess.PIPE,
                             stderr=subprocess.STDOUT)
    return popen
    if out is float('inf'):
        return b''
class CmdLineTest(unittest.TestCase):
    p = spawn_python('-i', '-m', 'timeit', '-n', '1')
    try:
        p.stdin.write(b'\x00')
    except BrokenPipeError:
        pass
if __name__ == "__main__":
    unittest.main(verbosity=0)
