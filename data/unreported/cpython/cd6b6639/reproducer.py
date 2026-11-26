from contextlib import contextmanager
import os
import pathlib
import shutil
import sqlite3 as sqlite
import tempfile
import unittest

class _FakeHash:
    def __init__(self, value=None, mode=None):
        self.value = value
        self.mode = mode
class _FakeFile:
    def __init__(self, root, relpath, content=b'', hash_value=b'deadbeef', hash_mode='sha256'):
        self.root = pathlib.Path(root)
        self.name = relpath.replace(os.sep, '/')
        self._path = self.root.joinpath(relpath)
        self._content = content
        self.size = len(content)
        self.hash = _FakeHash(value=hash_value, mode=hash_mode) if hash_value is not None else None

    def locate(self):
        return self._path

    def read_binary(self):
        return bytes(self._content)

    def read_text(self, encoding='utf-8'):
        return self._content.decode(encoding)
_FAKE_DIST_CACHE = {}
def files(dist_name):
    if dist_name in _FAKE_DIST_CACHE:
        return _FAKE_DIST_CACHE[dist_name]

    tmpdir = tempfile.mkdtemp(prefix=f"fake_dist_{dist_name}_")
    package_dir = pathlib.Path(tmpdir) / "distinfo_pkg"
    package_dir.mkdir(parents=True, exist_ok=True)

    files_to_create = {
        "distinfo_pkg/__init__.py": b"# package init\n",
        "distinfo_pkg/module.py": b"def foo():\n    return 42\n",
        "distinfo_pkg/data.txt": b"some data\n",
    }

    file_objs = []
    for relpath, content in files_to_create.items():
        full_path = package_dir.joinpath(relpath.split("/", 1)[-1]) if relpath.startswith("distinfo_pkg/") else package_dir.joinpath(relpath)
        full_path.parent.mkdir(parents=True, exist_ok=True)
        with open(full_path, "wb") as f:
            f.write(content)
        relative = str(full_path.relative_to(package_dir))
        file_obj = _FakeFile(root=package_dir, relpath=relative, content=content)
        file_objs.append(file_obj)

    _FAKE_DIST_CACHE[dist_name] = file_objs
    return file_objs
class fixtures:
    class EggInfoPkg: pass
    class EggInfoPkgPipInstalledNoToplevel: pass
    class EggInfoPkgPipInstalledNoModules: pass
    class EggInfoPkgPipInstalledExternalDataFiles: pass
    class EggInfoPkgSourcesFallback: pass
    class DistInfoPkg: pass
    class DistInfoPkgWithDot: pass
    class EggInfoFile: pass
    class DistInfoPkgWithDotLegacy: pass
    class DistInfoPkgOffPath: pass
def test_files(files_list):
    assert files_list, "files() returned an empty list"
    root = files_list[0].root
    for file in files_list:
        assert file.root == root
        assert not file.hash or file.hash.value
        assert not file.hash or file.hash.mode == 'sha256'
        assert not file.size or file.size >= 0
        located = file.locate()
        assert located.exists()
        assert isinstance(file.read_binary(), (bytes, bytearray))
        if file.name.endswith('.py'):
            text = file.read_text()
            assert isinstance(text, str)
test_files(files('distinfo-pkg'))
@contextmanager
def memory_database():
    """Create and yield an in-memory sqlite3 connection as a context manager."""
    conn = sqlite.connect(':memory:')
    try:
        yield conn
    finally:
        try:
            conn.close()
        except Exception:
            pass
def test_failing_progress():
    def progress(status, remaining, total):
        raise SystemError(b'\xe2\x98\x83')

    # Use pages=1 to ensure the progress callback is invoked.
    with memory_database() as bck:
        cx = sqlite.connect(':memory:')
        cx.execute('CREATE TABLE foo (key INTEGER)')
        cx.executemany('INSERT INTO foo (key) VALUES (?)', [(3,), (4,)])
        cx.commit()
        
        try:
            cx.backup(bck, pages=1, progress=progress)
        except Exception as err:
            # The important part of the test is that the exception from _FAKE_DIST_CACHE
            # progress callback is propagated. Accept any exception type but
            # ensure the message is preserved.
            if 'nearly out of space' not in str(err):
                raise
        finally:
            cx.close()
if __name__ == "__main__":
    test_failing_progress()
try: repr(_FAKE_DIST_CACHE)
except: pass
try: type(_FAKE_DIST_CACHE)
except: pass
try: str(_FAKE_DIST_CACHE)
except: pass
try: id(_FAKE_DIST_CACHE)
except: pass
try: list(_FAKE_DIST_CACHE)
except: pass



# C: P10 - Closure & nonlocal cell mutation
import ctypes
try:
    _p10_cell_val = cx

    def _p10_outer(init):
        _p10_x = init              # captured as cell object
        def _p10_inner():
            nonlocal _p10_x
            _p10_x = progress          # STORE_DEREF — writes through cell
            return _p10_x          # LOAD_DEREF — reads through cell
        return _p10_inner, lambda: _p10_x  # expose cell reader too

    _p10_inner, _p10_reader = _p10_outer(_p10_cell_val)

    # Warm up the inner function so the specializer sees LOAD_DEREF
    for _i in range(50):
        _ = _p10_inner()

    # Directly mutate the cell object from outside the closure
    # to create a state the specializer has never seen
    try:
        _p10_cell = _p10_inner.__closure__[0]
        _p10_cell.cell_contents = out     # overwrite cell from outside
        print("cell after mutation:", _p10_reader())
        print("inner after mutation:", _p10_inner())
    except (ValueError, AttributeError) as _mut_e:
        print("cell mutation error:", _mut_e)

    # Nested closure depth stress — each level adds a cell indirection
    def _make_deep(depth, val):
        if depth == 0:
            return lambda: val
        inner = _make_deep(depth - 1, val)
        def _wrap():
            return inner()         # chains LOAD_DEREF across N frames
        return _wrap

    _p10_deep = _make_deep(min(abs(int(cx or 1)) % 20 + 2, 20), progress)
    print("deep closure:", _p10_deep())
except Exception as _e:
    print(_e)
