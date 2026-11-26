import io
import os
from test.support import os_helper

DATA_TEMPLATE = ['line1=1']
DATA_CR = r'\n\r\t'.join(DATA_TEMPLATE) + '\r'

open_func = io.open

READMODE = 'r'
WRITEMODE = 'wb'

data = DATA_CR
if 'b' in WRITEMODE:
    data = data.encode('ascii')

with open_func(os_helper.TESTFN, WRITEMODE) as fp:
    fp.write(data)

with open_func(os_helper.TESTFN, READMODE) as fp:
    _ = fp.readline()
    pos = fp.tell()
