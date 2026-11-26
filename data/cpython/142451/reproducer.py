import hmac
import hashlib

h = hmac.HMAC(b'key', digestmod=hashlib.sha256)
h_copy = h.copy()
print(h_copy.name)
