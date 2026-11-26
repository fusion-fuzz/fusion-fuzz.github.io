import io

class MockRawIO:
    def __init__(self):
        self.closed = NotImplemented
    def write(self, b):
        return len(data)
    def writable(self):
        return True

tp = io.BufferedWriter
writer = MockRawIO()
bufio = tp(writer, 8)
bufio.close()
