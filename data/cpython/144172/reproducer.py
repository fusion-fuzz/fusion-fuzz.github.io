from concurrent import interpreters
import tracemalloc

# Start tracking memory allocations.
# Tracemalloc captures filenames of code objects loaded during execution.
tracemalloc.start()

# Create a subinterpreter.
# During initialization (specifically _Py_Get_Getpath_CodeObject), 
# the subinterpreter allocates and interns strings (filenames).
# Tracemalloc records pointers to these strings.
interp_id = interpreters.create()

# Ensure the interpreter is fully initialized/used.
interpreters.run_string(interp_id, "pass")

# Destroy the subinterpreter.
# This clears the subinterpreter's interned dictionary, freeing the strings 
# that tracemalloc is still tracking.
interpreters.destroy(interp_id)

# When the script exits, _Py_Finalize calls tracemalloc_deinit.
# Tracemalloc iterates its traces and tries to access the filename strings
