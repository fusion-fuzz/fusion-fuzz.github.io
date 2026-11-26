import sqlite3

# 1. Setup an in-memory database with a BLOB column
con = sqlite3.connect(':memory:')
con.execute('create table test(b blob)')

# 2. Insert a small amount of data.
# The unicode character '\u2603' (Snowman) is 3 bytes in UTF-8 (b'\xe2\x98\x83').
# The blob size will be 3.
con.execute('insert into test(b) values (?)', ('\u2603',))

# 3. Open the BLOB for incremental I/O
# Table: 'test', Column: 'b', Row: 1
blob = con.blobopen('test', 'b', 1)

# 4. Trigger the crash
# We request a slice starting at index 5 (which is beyond the blob size of 3)
# and ending at index -5 (which wraps around to before the start).
# This combination causes the internal 'offset' calculation in C to assert
# failing that the offset (5) is not less than the blob bytes (3).
blob[5:-5]
