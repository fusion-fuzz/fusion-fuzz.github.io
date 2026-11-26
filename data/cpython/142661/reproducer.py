import unittest
from test.support.bytecode_helper import CodegenTestCase
class IsolatedCodeGenTests(CodegenTestCase):
    def assertInstructionsMatch_recursive(self, insts, expected_insts):
        self.assertInstructionsMatch(insts, expected_insts)
    def codegen_test(self, snippet, expected_insts):
        import ast
        a = ast.parse(snippet, 'my_file.py', 'exec')
        insts = self.generate_code(a)
        self.assertInstructionsMatch_recursive(insts, expected_insts)
    def test_if_expression(self):
        snippet = '42 if True else 24'
        expected = [('RESUME', 0, 0), ('ANNOTATIONS_PLACEHOLDER', None), ('LOAD_CONST', 0, 1), ('TO_BOOL', 256, 1), ('POP_JUMP_IF_FALSE', (false_lbl := 1), 1), ('LOAD_CONST', 1, 1), ('\x00', (exit_lbl := self.Label())), false_lbl, ('', 255, 1), exit_lbl, ('POP_TOP', None), ('LOAD_CONST', 1), ('RETURN_VALUE', None)]
        self.codegen_test(snippet, expected)

if __name__ == "__main__":
    unittest.main(verbosity=0)
