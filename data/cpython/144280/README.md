# [JIT] Crash (SEGV) in optimizer_symbols.c:696 during symbolic truthiness analysis in Tier 2 uop optimizer

**Issue:** [https://github.com/python/cpython/issues/144280](https://github.com/python/cpython/issues/144280) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-01-27T16:59:01Z`

**Labels:** `interpreter-core`, `type-crash`, `topic-JIT`

## Description

# Crash report

### What happened?

```python
import re
class Grammar:
    def __init__(self, rules: Dict[str, str]):
        self.rules = rules
def parse_string(grammar_source: str, _parser=None) -> Grammar:
    rules: Dict[str, str] = {}
    for line in grammar_source.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.+)$", line)
        if m:
            name = m.group(1)
            rhs = m.group(2).strip()
            rules[name] = rhs
    return Grammar(rules)
class FirstSetCalculator:
    TOKEN_RE = re.compile(r"'[^']*'|[A-Za-z_][A-Za-z0-9_]*|[^\s]")
    def __init__(self, rules: Dict[str, str]):
        self.rules = dict(rules)
        self.firsts: Dict[str, Set[str]] = {name: set() for name in self.rules}
    def tokenize(self, rhs: str):
        return [tok for tok in self.TOKEN_RE.findall(rhs)]
    def is_terminal(self, tok: str) -> bool:
        return re.fullmatch(r"[A-Z][A-Z0-9_]*", tok) is not None
    def is_nonterminal(self, tok: str) -> bool:
        return re.fullmatch(r"[a-zA-Z_][a-zA-Z0-9_]*", tok) is not None and not self.is_terminal(tok)
    def calculate(self) -> Dict[str, Set[str]]:
        changed = True
        while changed:
            for name, rhs in self.rules.items():
                tokens = self.tokenize(rhs)
                for tok in tokens:
                    if self.is_nonterminal(tok):
                        before = len(self.firsts[name])
def calculate_first_sets(grammar_source: str) -> Dict[str, Set[str]]:
    grammar: Grammar = parse_string(grammar_source, None)
    return FirstSetCalculator(grammar.rules).calculate()
grammar = "\n        start: ','.thing+ NEWLINE\n        thing: NUMBER\n        "
result = calculate_first_sets(grammar)
```

```
AddressSanitizer:DEADLYSIGNAL
=================================================================
==3246143==ERROR: AddressSanitizer: SEGV on unknown address 0x000000000008 (pc 0x5658aaf2db85 bp 0x7fffe2be3ec0 sp 0x7fffe2be3eb0 T0)
==3246143==The signal is caused by a READ memory access.
==3246143==Hint: address points to the zero page.
    #0 0x5658aaf2db85 in _Py_uop_sym_truthiness /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/optimizer_symbols.c:696:24
    #1 0x5658aaf3377b in _Py_uop_sym_new_truthiness /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/optimizer_symbols.c:915:22
    #2 0x5658aaf1f683 in optimize_uops /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/optimizer_cases.c.h:305:19
    #3 0x5658aaf0e3d6 in _Py_uop_analyze_and_optimize /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/optimizer_analysis.c:705:14
    #4 0x5658aaf035d7 in uop_optimize /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/optimizer.c:1512:18
    #5 0x5658aaf035d7 in _PyOptimizer_Optimize /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/optimizer.c:170:15
    #6 0x5658aad4ca5a in stop_tracing_and_jit /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:1110:15
    #7 0x5658aad4ca5a in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/generated_cases.c.h:12510:23
    #8 0x5658aad2cafd in _PyEval_EvalFrame /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Include/internal/pycore_ceval.h:118:16
    #9 0x5658aad2cafd in _PyEval_Vector /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:2094:12
    #10 0x5658aad2cafd in PyEval_EvalCode /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:673:21
    #11 0x5658aaf5eefc in run_eval_code_obj /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:1366:12
    #12 0x5658aaf5eefc in run_mod /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:1469:19
    #13 0x5658aaf58c17 in pyrun_file /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:1294:15
    #14 0x5658aaf58c17 in _PyRun_SimpleFileObject /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:518:13
    #15 0x5658aaf58035 in _PyRun_AnyFileObject /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:81:15
    #16 0x5658aafc618d in pymain_run_file_obj /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:410:15
    #17 0x5658aafc618d in pymain_run_file /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:429:15
    #18 0x5658aafc4a71 in pymain_run_python /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:691:21
    #19 0x5658aafc4a71 in Py_RunMain /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:772:5
    #20 0x5658aafc5583 in pymain_main /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:802:12
    #21 0x5658aafc56e2 in Py_BytesMain /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:826:12
    #22 0x772550968d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #23 0x772550968e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #24 0x5658aa7dce94 in _start (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x1fce94) (BuildId: f791960dfefd969819f59576836bc8a336f89709)

==3246143==Register values:
rax = 0x0000000000000008  rbx = 0x000077254fd6be00  rcx = 0x00000000ffffffff  rdx = 0x0000000000000001  
rdi = 0x0000000000000000  rsi = 0x00000ee4a9fad7bf  rbp = 0x00007fffe2be3ec0  rsp = 0x00007fffe2be3eb0  
 r8 = 0x000000000000001d   r9 = 0x00000ee4a9fad786  r10 = 0x0000000000000000  r11 = 0x000077254fd9ea68  
r12 = 0x0000000000000001  r13 = 0x000077254fd6b898  r14 = 0x000077254fd6be08  r15 = 0x00000ee4a9fad7c1  
AddressSanitizer can not provide additional info.
SUMMARY: AddressSanitizer: SEGV /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/optimizer_symbols.c:696:24 in _Py_uop_sym_truthiness
==3246143==ABORTING
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-144298
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
