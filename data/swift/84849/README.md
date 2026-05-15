---
render_with_liquid: false
---

# [swiftc crash bad pointer dereference when typealias nonexisting one](https://github.com/swiftlang/swift/issues/84849)

### Description

One line to reproduce: `docker run --rm -v "$PWD":/work -w /work swift:latest bash -lc 'swiftc -c test.swift -o /dev/null'`

### Reproduction

```swift
let test = 42
typealias a = () extension a : Comparable
```


### Stack dump

```text
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -typecheck min.swift
1.	Swift version 6.2 (swift-6.2-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "min.swift")
4.	While type-checking extension of a (at min.swift:3:18)
#0 0x000063381a966598 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x7316598)
#1 0x000063381a96436e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731436e)
#2 0x000063381a966c31 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
#3 0x00007e337f0cb330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
#4 0x0000633815af3717 swift::DeclContext::getASTContext() const (/usr/bin/swift-frontend+0x24a3717)
#5 0x0000633815a2ab95 swift::GenericContext::getGenericParams() const (/usr/bin/swift-frontend+0x23dab95)
#6 0x0000633849f817e0 

💣 Program crashed: Bad pointer dereference at 0x00000000000288da
```

### Expected behavior

should not crash anyway

### Environment

nightly

### Additional information

_No response_
