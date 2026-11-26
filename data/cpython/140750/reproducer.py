import json

def bad_encoder1(*args):
    return None
enc = json.encoder.c_make_encoder(None, lambda obj: str(obj), bad_encoder1, r'\udcff', ': ', r'\udfff', False, -(2**64), False)    
enc({'spam': 10**1000}, 4)
