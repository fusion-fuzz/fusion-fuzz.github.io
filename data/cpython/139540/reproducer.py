import bdb
code = 'a = 1\nb = 2\nc = a + b'
globals_dict = {}
locals_dict = {}
debugger = bdb.Bdb()
debugger.runctx(code, globals_dict, locals_dict)
for i in range(10):
    pass
with tempfile.NamedTemporaryFile() as tmpfile:
    tmpfile.seek(0)
