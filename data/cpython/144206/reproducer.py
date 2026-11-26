import fcntl
import termios

with open('/dev/tty', 'rb') as fd:
    fcntl.ioctl(fd, termios.TIOCGPGRP, b'', True)
