import ast
import unittest
class ASTConstructorTests(unittest.TestCase):
    def test_incomplete_field_types(self):
        class MoreFieldsThanTypes(ast.AST):
            _fields = (None, 'b')
            _field_types = {'a': int | None}
        with self.assertWarnsRegex(DeprecationWarning, "Field 'b' is missing from MoreFieldsThanTypes\\._field_types"):
            obj = MoreFieldsThanTypes()
if __name__ == "__main__":
    unittest.main()
