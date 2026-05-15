---
render_with_liquid: false
---

**Date:** `2026-01-07`
# [Crash due to integer overflow](https://github.com/swiftlang/swift/issues/86345)

### Description

_No response_

### Reproduction

```swift
let MAX_32Bit: Int32 = 2147483647
let MIN_32Bit: Int32 = -2147483647 - 1

print(Int64(MAX_32Bit) + 1, Int64(MIN_32Bit) - 1, Int64(MAX_32Bit * 2))
```


### Stack dump

```text
18:41:00
Swift version 6.2.3 (swift-6.2.3-RELEASE)
Target: x86_64-unknown-linux-gnu
Stack dump:
0.      Program arguments: /usr/bin/swift-frontend -frontend -interpr
et - -disable-objc-interop -I swiftfiddle.com/_Packages/.build/release/Modules -I swiftfiddle.com/_Packages/.build/checkouts/swift-numerics/Sources/_NumericsShims/include -color-diagnostics -Xcc -fcolor-diagnos
tics -enable-bare-slash-regex -empty-abi-descriptor -no-auto-bridging-header-ch
aining -module-name main -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -p
lugin-path /usr/local/lib/swift/host/plugins -l_Packages
1.      Swift version 6.2.3 (swift-6.2.3-RELEASE)
2.      Compiling with effective version 5.10
3.      While running user code "<stdin>
"
 #0 0x000055802ae4b438 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x72f5438)
 #1 0x000055802ae4921e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x72f321e)
 #2 0x000055802ae4bad1 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x00007f54bf8a2520 (/lib/x86_64-linux-gnu/libc.so.6+0x42520)
 #4 0x00007f54bfde5178 
 #5 0x00005580248c95ac llvm::orc::runAsMain(int (*)(int, char**), llvm::ArrayRef<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>>, std::optional<llvm::StringRef>) (/usr/bin/swift-frontend+0xd735ac)
 #6 0x0000558024751634 swift::SwiftJIT::runMain(llvm::ArrayRef<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>>) (/usr/bin/swift-frontend+0xbfb634)
 #7 0x000055802474f8a1 swift::RunImmediately(swift::CompilerInstance&, std::vector<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>, std::allocator<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>>> const&, swift::IRGenOptions const&, swift::SILOptions const&, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>>&&) (/usr/bin/swift-frontend+0xbf98a1)
 #8 0x00005580246ddcd5 processCommandLineAndRunImmediately(swift::CompilerInstance&, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>>&&, llvm::PointerUnion<swift::ModuleDecl*, swift::SourceFile*>, swift::FrontendObserver*, int&) FrontendTool.cpp:0:0
 #9 0x00005580246d9ca3 performCompileStepsPostSILGen(swift::CompilerInstance&, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>>, llvm::PointerUnion<swift::ModuleDecl*, swift::SourceFile*>, swift::PrimarySpecificPaths const&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#10 0x00005580246d8c8a swift::performCompileStepsPostSema(swift::CompilerInstance&, int&, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb82c8a)
#11 0x00005580246e75cb withSemanticAnalysis(swift::CompilerInstance&, swift::FrontendObserver*, llvm::function_ref<bool (swift::CompilerInstance&)>, bool) FrontendTool.cpp:0:0
#12 0x00005580246dc1d2 performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#13 0x00005580246da8ca swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb848ca)
#14 0x000055802447a50a swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x92450a)
#15 0x00007f54bf889d90 (/lib/x86_64-linux-gnu/libc.so.6+0x29d90)
#16 0x00007f54bf889e40 __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x29e40)
#17 0x0000558024479965 _start (/usr/bin/swift-frontend+0x923965)
💣 Program crashed: Signal 4: Backtracing from 0x7f54bf8f69fc...
💣 Program crashed: Illegal instruction at 0x0000000000001658
Platform: x86_64 Linux (Ubuntu 22.04.5 LTS)
Thread 0 "swift-frontend" crashed:
  0 0x00007f54bf8f69fc <unknown> in libc.so.6
... 
Backtrace took 0.00s

 failed
timeout: the monitored command dumped core
```

### Expected behavior

should not crash

### Environment

Swift version 6.2.3 (swift-6.2.3-RELEASE)

### Additional information

_No response_
