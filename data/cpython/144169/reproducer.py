import ast

# Create a non-string object to use as a dictionary key.
# A generic object() is sufficient to trigger the type confusion.
bad_key = object()

# The crash happens when:
# 1. We instantiate an AST node (e.g., ast.Pass, which accepts no arguments).
# 2. We pass a keyword argument where the KEY is not a string.
#    (Standard Python calls block this, but 'ast' constructors bypass the check).
# 3. The 'ast' internal init finds the unknown key and tries to format a 
#    warning message using the key, assuming it is a string.
ast.Pass(**{bad_key: 'value'})
