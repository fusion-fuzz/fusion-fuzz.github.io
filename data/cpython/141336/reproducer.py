import codecs

decode = codecs.unicode_escape_decode
data = {b'\\x0': (b'\xe2\x98\x83', 0)}

def mutating(exc):
    key = exc.object[:exc.end]
    r = data.get(key)
    if r is not None:
        return ('Є', r[1])

codecs.register_error('test.mutating2', mutating)

input_obj = b'\\x0n\\z'
result, length = decode(input_obj, 'test.mutating2')
