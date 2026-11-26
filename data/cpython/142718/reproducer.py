class EvilAttr:
    def __init__(self, d):
        self.d = d

    def __del__(self):
        try:
            del self.d['attr']
        except Exception:
            pass

class Obj:
    pass

obj = Obj()
obj.__dict__ = {}

for _ in range(32768):
    obj.attr = EvilAttr(obj.__dict__)
