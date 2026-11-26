import socket

s = socket.socket(socket.AF_CAN, socket.SOCK_DGRAM, socket.CAN_ISOTP)  # or CAN_J1939
s.bind("vcan0")   # any non-tuple address
