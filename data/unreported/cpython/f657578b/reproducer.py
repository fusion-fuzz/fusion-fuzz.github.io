import codecs

def handler(exc):
    # A decode error handler that returns a non-advancing position (0, i.e.
    # at or before exc.start) together with a non-empty replacement, without
    # growing exc.object.
    return ("Є", 0)

codecs.register_error("m", handler)
codecs.unicode_escape_decode(b"\\xz", "m")
