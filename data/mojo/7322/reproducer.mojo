trait AnyType:
    pass


struct S[*Ts: AnyType]:
    pass


def g[T: AnyType]():
    _ = S[T]()


def main():
    pass
