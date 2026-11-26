import io

input_lines = ['windows\r\n']
joined = ''.join(input_lines)

encoding = 'utf-8'
newline = None
bufsize = 1

raw = io.BytesIO(joined.encode(encoding))
buf = io.BufferedReader(raw, buffer_size=bufsize)
textio = io.TextIOWrapper(buf, encoding=encoding, newline=newline)

textio.seek(2**63 - 1)
_ = textio.read(2)
