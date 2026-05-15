---
render_with_liquid: false
---

**Date:** `2026-01-07`
# [Fatal error: Double value cannot be converted to Int because it is either infinite or NaN at Swift/IntegerTypes.swift:8835](https://github.com/swiftlang/swift/issues/86343)

### Description

_No response_

### Reproduction

```swift
import Foundation

let upperBound = Int(pow(2.0, 100000000))
_ = stride(from: 0, through: upperBound, by: 1)
```


### Stack dump

```text
Welcome to SwiftFiddle.
Empower our project through your generous support on GitHub Sponsors! 💖
https://github.com/sponsors/kishikawakatsumi/
                                                                                               18:21:47
Swift version 6.2.3 (swift-6.2.3-RELEASE)
Target: x86_64-unknown-linux-gnu
Swift/IntegerTypes.swift:8835: Fatal error: Double value cannot be converted to Int because it is either infinite or NaN
Stack dump:
0.      Program arguments: /usr/bin/swift-frontend -frontend -interpret - -disable-objc-interop -I swiftfiddle.com/_Packages/.build/release/Modules -I swiftfiddle.com/_Packages/.build/checkouts/swift-numerics/Sources/_NumericsShims/include -color-diagnostics -Xcc -fcolor-diagnostics -en
able-bare-slash-regex -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name main -in-process-plugin-server-path
 /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -l_Packages
1.      Swift version 6.2.3 (swift-6.2.3-RELEASE)
2.      Compiling with effective version 5.10
3.      While running user code
 "<stdin>"
 #0 0x0000555dbf4af438 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x72f5438)
 #1 0x0000555dbf4ad21e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x72f321e)
 #2 0x0000555dbf4afad1 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x00007f82cb87e520 (/lib/x86_64-linux-gnu/libc.so.6+0x42520)
 #4 0x00007f82cd21fe16 $ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF (/usr/lib/swift/linux/libswiftCore.so+0x2e2e16)
 #5 0x00007f82cbdc114d 
 #6 0x0000555db8f2d5ac llvm::orc::runAsMain(int (*)(int, char**), llvm::ArrayRef<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>>, std::optional<llvm::StringRef>) (/usr/bin/swift-frontend+0xd735ac)
 #7 0x0000555db8db5634 swift::SwiftJIT::runMain(llvm::ArrayRef<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>>) (/usr/bin/swift-frontend+0xbfb634)
 #8 0x0000555db8db38a1 swift::RunImmediately(swift::CompilerInstance&, std::vector<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>, std::allocator<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>>> const&, swift::IRGenOptions const&, swift::SILOptions const&, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>>&&) (/usr/bin/swift-frontend+0xbf98a1)
 #9 0x0000555db8d41cd5 processCommandLineAndRunImmediately(swift::CompilerInstance&, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>>&&, llvm::PointerUnion<swift::ModuleDecl*, swift::SourceFile*>, swift::FrontendObserver*, int&) FrontendTool.cpp:0:0
#10 0x0000555db8d3dca3 performCompileStepsPostSILGen(swift::CompilerInstance&, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>>, llvm::PointerUnion<swift::ModuleDecl*, swift::SourceFile*>, swift::PrimarySpecificPaths const&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#11 0x0000555db8d3cc8a swift::performCompileStepsPostSema(swift::CompilerInstance&, int&, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb82c8a)
#12 0x0000555db8d4b5cb withSemanticAnalysis(swift::CompilerInstance&, swift::FrontendObserver*, llvm::function_ref<bool (swift::CompilerInstance&)>, bool) FrontendTool.cpp:0:0
#13 0x0000555db8d401d2 performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#14 0x0000555db8d3e8ca swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb848ca)
#15 0x0000555db8ade50a swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x92450a)
#16 0x00007f82cb865d90 (/lib/x86_64-linux-gnu/libc.so.6+0x29d90)
#17 0x00007f82cb865e40 __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x29e40)
#18 0x0000555db8add965 _start (/usr/bin/swift-frontend+0x923965)
💣 Program crashed: Signal 4: Backtracing from 0x7f82cb8d29fc...
💣 Program crashed: Illegal instruction at 0x000000000000147c
Platform: x86_64 Linux (Ubuntu 22.04.5 LTS)
Thread 0 "swift-frontend" crashed:
  0 0x00007f82cb8d29fc <unknown> in libc.so.6
... 
Backtrace took 0.01s

 failed
timeout: the monitored command dumped core
```

### Expected behavior

should not crash

### Environment

Swift version 6.2.3 (swift-6.2.3-RELEASE)


### Additional information

_No response_
