import curses
import sys
import os

# Ensure TERM is set so setupterm doesn't fail
if not os.environ.get('TERM'):
    os.environ['TERM'] = 'xterm'

# 1. First allocation (from TestCurses.setUpClass)
# This allocates the first 'struct term' and assigns it to the global cur_term.
try:
    curses.setupterm(fd=sys.stdout.fileno())
except curses.error:
    # If setupterm fails (e.g. no terminal info), we can't reproduce the leak.
    sys.exit(0)

# 2. Second allocation (from TestCurses.setUp -> curses.initscr)
# initscr() internally calls newterm(), which allocates a NEW 'struct term'.
# This overwrites the global cur_term pointer, leaking the memory from step 1.
stdscr = curses.initscr()

# Cleanup (standard curses exit, though the leak has already happened)
curses.endwin()
