# [mlir] null pointer UBSan alert in mlir/lib/IR/Diagnostics.cpp

**Issue:** [https://github.com/llvm/llvm-project/issues/163343](https://github.com/llvm/llvm-project/issues/163343) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-14T08:47:17Z`

**Labels:** `mlir`, `crash`

## Description

PoC:
```
    // expected-warning @unknown {{could not cast operand of type 'f16' to 'vector<4xf16>'}}
```

stderr:
```
/home/phpfuzz/WorkSpace/llvm-project/mlir/lib/IR/Diagnostics.cpp:599:71: runtime error: applying non-zero offset 55 to null pointer
    #0 0x5c8f982fe1e9 in mlir::detail::ExpectedDiag::emitError(llvm::raw_ostream&, llvm::SourceMgr&, llvm::Twine const&) /home/phpfuzz/WorkSpace/llvm-project/mlir/lib/IR/Diagnostics.cpp:599:71
    #1 0x5c8f982fabb3 in mlir::SourceMgrDiagnosticVerifierHandler::verify()::$_8::operator()(mlir::detail::ExpectedDiag&) const /home/phpfuzz/WorkSpace/llvm-project/mlir/lib/IR/Diagnostics.cpp:844:15
    #2 0x5c8f982fa4dd in mlir::SourceMgrDiagnosticVerifierHandler::verify() /home/phpfuzz/WorkSpace/llvm-project/mlir/lib/IR/Diagnostics.cpp:852:5
    #3 0x5c8f982fa08d in mlir::SourceMgrDiagnosticVerifierHandler::~SourceMgrDiagnosticVerifierHandler() /home/phpfuzz/WorkSpace/llvm-project/mlir/lib/IR/Diagnostics.cpp:833:9
    #4 0x5c8f854b74f9 in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) /home/phpfuzz/WorkSpace/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:746:1
    #5 0x5c8f854b7e6d in mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) /home/phpfuzz/WorkSpace/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:784:14
    #6 0x5c8f854b85c2 in mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) /home/phpfuzz/WorkSpace/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:800:10
    #7 0x5c8f852d03ce in main /home/phpfuzz/WorkSpace/llvm-project/mlir/tools/mlir-opt/mlir-opt.cpp:343:33
    #8 0x781ff9447d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #9 0x781ff9447e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #10 0x5c8f8520fb64 in _start (/home/phpfuzz/WorkSpace/llvm-mlir-build/bin/mlir-opt+0x8381b64) (BuildId: 8d3f598c321c686de3addc0e0905b4ae76916fb7)

SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior /home/phpfuzz/WorkSpace/llvm-project/mlir/lib/IR/Diagnostics.cpp:599:71 in 
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
