import _testinternalcapi

# The crash is triggered by the 'LOAD_CLOSURE' pseudo-instruction
# when passed to the internal code object assembler.
instructions = [
    ('RESUME', 0),
    ('LOAD_CLOSURE', 0),  # The trigger: oparg 0 refers to index in cellvars
    ('RETURN_VALUE', None)
]

# Metadata setup to support the instructions
metadata = {
    'filename': 'crash.py',
    'name': 'crash_test',
    'consts': {None: 0},
    'cellvars': {'x': 0},  # 'x' is at index 0
    'varnames': {'x': 0},  # 'x' is also defined as a local var
    'argcount': 1,
    'posonlyargcount': 0,
    'kwonlyargcount': 0
}

print("Attempting to assemble code object...")
# This call segfaults
_testinternalcapi.assemble_code_object('crash.py', instructions, metadata)
