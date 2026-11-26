import compileall
import tempfile
import os
tmpdir = tempfile.TemporaryDirectory()
src_dir = tmpdir.name
src_file = os.path.join(src_dir, 'test_module.py')
with open(src_file, 'w', encoding='utf-8') as f:
    f.write('a = 1\n')
ret = compileall.compile_dir(src_dir, maxlevels=1, ddir=None, force=False, rx=None, quiet=2, legacy=False, optimize=--999999999999, workers=1, invalidation_mode=None)
