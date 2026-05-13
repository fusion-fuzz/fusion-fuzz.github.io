# Assertion failure at Python/instruction_sequence.c:121: `int _PyInstructionSequence_Addop(instr_sequence *, int, int, location): Assertion 'OPCODE_HAS_ARG(opcode) || HAS_TARGET(opcode) || oparg == 0' failed`

**Issue:** [https://github.com/python/cpython/issues/142661](https://github.com/python/cpython/issues/142661) &nbsp;·&nbsp; **State:** `open` &nbsp;·&nbsp; **Created:** `2025-12-13T12:02:36Z`

**Labels:** `tests`, `interpreter-core`, `type-crash`

## Description

# Crash report

### What happened?

```python
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
```

```
python: ../Python/instruction_sequence.c:121: int _PyInstructionSequence_Addop(instr_sequence *, int, int, location): Assertion `OPCODE_HAS_ARG(opcode) || HAS_TARGET(opcode) || oparg == 0' failed.
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
