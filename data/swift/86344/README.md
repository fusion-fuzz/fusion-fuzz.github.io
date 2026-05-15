---
render_with_liquid: false
---

# [Foundation/NSCoder.swift:743: Fatal error: There was a decoding error and the decoding failure policy is .raiseException.](https://github.com/swiftlang/swift/issues/86344)

### Description

Foundation/NSCoder.swift:743: Fatal error: There was a decoding error and the decoding failure policy is .raiseException.

### Reproduction

```swift
import Foundation

let data = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(base64Encoded: "YToxOntpOjA7czo5OiJBUHBTZXR0aW5ncyI7fQ==")!) as! Array<Any>

print(data)
```


### Stack dump

```text
Swift version 6.2.3 (swift-6.2.3-RELEASE)
Target: x86_64-unknown-linux-gnu
2026-01-07 10:27:48.540 swift-frontend[5421:78ae8880] *** NSKeyedUnarchiver.init: Unexpected character a at line 1
Foundation/NSCoder.swift:743: Fatal error: There was a decoding error and the decoding failure policy is .raiseException. Aborting.
Stack dump:
0.      Program arguments: /usr/bin/swift-frontend
 -frontend -interpret - -disable-objc-interop -I swiftfiddle.com/_Packages/.build/release/Modules -I swiftfiddle.com/_Packages/.build/checkouts/swift-numerics/Sources/_NumericsShims/include -color-diagnostics -Xcc -fcolor-diagnostics -enable-bare-slash-regex -empty-abi-descriptor -no-auto-bridgi
ng-header-chaining -module-name main -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swif
t/host/plugins -l_Packages
1.      Swift version 6.2.3 (swift-6.2.3-RELEASE)
2.      Compiling with effective version 5.10
3.      While running user code "<stdin>"
 #0 0x0000556691086438 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x72f5438)
 #1 0x000055669108421e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x72f321e)
 #2 0x0000556691086ad1 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x00007fea78c4c520 (/lib/x86_64-linux-gnu/libc.so.6+0x42520)
 #4 0x00007fea7a5edaf8 $ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_SSAHSus6UInt32VtF (/usr/lib/swift/linux/libswiftCore.so+0x2e2af8)
 #5 0x00007fea748f76d0 $s10Foundation7NSCoderC21decodingFailurePolicyAC08DecodingdE0Ovg (/usr/lib/swift/linux/libFoundation.so+0x2856d0)
 #6 0x00007fea7493753d $s10Foundation17NSKeyedUnarchiverC12_handleError33_8A4A1351250253AE495C4D706D70227BLLyys0E0_pF (/usr/lib/swift/linux/libFoundation.so+0x2c553d)
 #7 0x00007fea74932dfc $s10Foundation17NSKeyedUnarchiverC6streamA2C6Stream33_8A4A1351250253AE495C4D706D70227BLLO_tcAFLlfc crtstuff.c:0:0
 #8 0x00007fea7493938e $s10Foundation17NSKeyedUnarchiverC31unarchiveTopLevelObjectWithDatayypSg0A10Essentials0I0VKFZ (/usr/lib/swift/linux/libFoundation.so+0x2c738e)
 #9 0x00007fea7918f24c 
#10 0x000055668ab045ac llvm::orc::runAsMain(int (*)(int, char**), llvm::ArrayRef<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>>, std::optional<llvm::StringRef>) (/usr/bin/swift-frontend+0xd735ac)
#11 0x000055668a98c634 swift::SwiftJIT::runMain(llvm::ArrayRef<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>>) (/usr/bin/swift-frontend+0xbfb634)
#12 0x000055668a98a8a1 swift::RunImmediately(swift::CompilerInstance&, std::vector<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>, std::allocator<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>>> const&, swift::IRGenOptions const&, swift::SILOptions const&, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>>&&) (/usr/bin/swift-frontend+0xbf98a1)
#13 0x000055668a918cd5 processCommandLineAndRunImmediately(swift::CompilerInstance&, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>>&&, llvm::PointerUnion<swift::ModuleDecl*, swift::SourceFile*>, swift::FrontendObserver*, int&) FrontendTool.cpp:0:0
#14 0x000055668a914ca3 performCompileStepsPostSILGen(swift::CompilerInstance&, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>>, llvm::PointerUnion<swift::ModuleDecl*, swift::SourceFile*>, swift::PrimarySpecificPaths const&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#15 0x000055668a913c8a swift::performCompileStepsPostSema(swift::CompilerInstance&, int&, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb82c8a)
#16 0x000055668a9225cb withSemanticAnalysis(swift::CompilerInstance&, swift::FrontendObserver*, llvm::function_ref<bool (swift::CompilerInstance&)>, bool) FrontendTool.cpp:0:0
#17 0x000055668a9171d2 performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#18 0x000055668a9158ca swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb848ca)
#19 0x000055668a6b550a swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x92450a)
#20 0x00007fea78c33d90 (/lib/x86_64-linux-gnu/libc.so.6+0x29d90)
#21 0x00007fea78c33e40 __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x29e40)
#22 0x000055668a6b4965 _start (/usr/bin/swift-frontend+0x923965)
💣 Program crashed: Signal 4: Backtracing from 0x7fea78ca09fc...
💣 Program crashed: Illegal instruction at 0x000000000000152d
Platform: x86_64 Linux (Ubuntu 22.04.5 LTS)
Thread 0 "swift-frontend" crashed:
  0 0x00007fea78ca09fc <unknown> in libc.so.6
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
