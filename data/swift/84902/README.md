---
render_with_liquid: false
---

**Date:** `2025-10-15`
# [swiftc crash `swift::Parser::parseExternAttribute`](https://github.com/swiftlang/swift/issues/84902)

### Description

_No response_

### Reproduction

```swift
enum b<T{var e:d=}typealias d<T where h:T>:N

let __fusion_0 = [1,2,3]

@_extern(wasm, module: "m1", name: "f1")
func f1(x: Int) -> Int

@_extern(wasm, module: "m2", name: ) 
func f2ErrorOnMissingNameLiteral(x: Int) -> Int 

@_extern(wasm, module: "m3", name) 
func f3ErrorOnMissingNameColon(x: Int) -> Int 

@_extern(wasm, module: "m4",) 
func f4ErrorOnMissingNameLabel(x: Int) -> Int 

@_extern(wasm, module: "m5") 
func f5ErrorOnMissingName(x: Int) -> Int 

@_extern(wasm, module: ) 
func f6ErrorOnMissingModuleLiteral(x: Int) -> Int 

@_extern(wasm, module) 
func f7ErrorOnMissingModuleColon(x: Int) -> Int 

@_extern(wasm,) 
func f8ErrorOnMissingModuleLabel(x: Int) -> Int 

@_extern(wasm, module: "m9", name: "f9")
func f9WithBody() {} 

struct S {
    @_extern(wasm, module: "m10", name: "f10") 
    func f10Member()
}

func f11Scope() {
    @_extern(wasm, module: "m11", name: "f11")
    func f11Inner()
}

@_extern(invalid, module: "m12", name: "f12") 
func f12InvalidLang() 

@_extern(c, "valid")
func externCValid()

@_extern(c, "_start_with_underscore")
func underscoredValid()

@_extern(c, "") 
func emptyCName()


@_extern(c, "0start_with_digit")
func explicitDigitPrefixed()

@_extern(c) 
func +(a: Int, b: Bool) -> Bool

@_extern(c) 
func 🥸_implicitInvalid()

@_extern(c)
func omitCName()

@_extern(c, ) 
func editingCName() 

struct StructScopeC {
    @_extern(c, "member_decl") 
    func memberDecl()

    @_extern(c, "static_member_decl")
    static func staticMemberDecl()
}

func funcScopeC() {
    @_extern(c, "func_scope_inner")
    func inner()
}

@_extern(c, "c_value") 
var nonFunc: Int = __fusion_0

@_extern(c, "with_body")
func withInvalidBody() {} 

@_extern(c, "duplicate_attr_c_1")
@_extern(c, "duplicate_attr_c_2") 
func duplicateAttrsC()

@_extern(wasm, module: "dup", name: "duplicate_attr_wasm_1")
@_extern(wasm, module: "dup", name: "duplicate_attr_wasm_2") 
func duplicateAttrsWasm()

@_extern(c, "mixed_attr_c")
@_extern(wasm, module: "mixed", name: "mixed_attr_wasm")
func mixedAttrs_C_Wasm()

class NonC {}
@_extern(c)
func nonCReturnTypes() -> NonC 

@_extern(wasm, module: "non-c", name: "return_wasm")
func nonCReturnTypesWasm() -> NonC
@_extern(c)
@_extern(wasm, module: "non-c", name: "return_mixed")
func nonCReturnTypesMixed() -> NonC 

@_extern(c)
func nonCParamTypes(_: Int, _: NonC) 
@_extern(wasm, module: "non-c", name: "param_wasm")
func nonCParamTypesWasm(_: Int, _: NonC)

@_extern(c)
@_extern(wasm, module: "non-c", name: "param_mixed")
func nonCParamTypesMixed(_: Int, _: NonC) 

@_extern(c)
func defaultArgValue_C(_: Int = 42)

@_extern(wasm, module: "", name: "")
func defaultArgValue_Wasm(_: Int = 24)

@_extern(c)
func asyncFuncC() async 

@_extern(c)
func throwsFuncC() throws 

@_extern(c)
func genericFuncC<T>(_: T) 

@_extern(c) 
@_cdecl("another_c_name")
func withAtCDecl_C()

@_extern(wasm, module: "", name: "") 
@_cdecl("another_c_name")
func withAtCDecl_Wasm()

@_extern(c) 
@_silgen_name("another_sil_name")
func withAtSILGenName_C()

@_extern(wasm, module: "", name: "") 
@_silgen_name("another_sil_name")
func withAtSILGenName_Wasm()

@_extern(c) 
@_cdecl("another_c_name")
@_silgen_name("another_sil_name")
func withAtSILGenName_CDecl_C()
```


### Stack dump

```text
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -c -primary-file min.swift -target x86_64-unknown-linux-gnu -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name min -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -o /tmp/TemporaryDirectory.lUcKJd/min-1.o
1.	Swift version 6.2 (swift-6.2-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request ParseTopLevelDeclsRequest(source_file "min.swift")
4.	While evaluating request ParseSourceFileRequest(source_file "min.swift")
5.	With parser at source location: min.swift:43:1
#0 0x000059403f35a598 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x7316598)
#1 0x000059403f35836e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731436e)
#2 0x000059403f35ac31 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
#3 0x00007184cdabd330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
#4 0x000059403a1e2005 swift::Parser::parseExternAttribute(swift::DeclAttributes&, bool&, llvm::StringRef, swift::SourceLoc, swift::SourceLoc)::$_10::operator()(std::optional<llvm::StringRef>) const ParseDecl.cpp:0:0
#5 0x0000594076ffaf80 

*** Signal 11: Backtracing from 0x7184cdb16b2c... done ***

*** Program crashed: Bad pointer dereference at 0x0000000000390816 ***

Platform: x86_64 Linux (Ubuntu 24.04.3 LTS)

Thread 0 "swift-frontend" crashed:

  0      0x00007184cdb16b2c <unknown> in libc.so.6
  1 [ra] 0x00007184cdabd27e <unknown> in libc.so.6
...


Registers:

rax 0x0000000000000000  0
rdx 0x0000000000390816  3737622
rcx 0x00007184cdb16b2c  41 89 c6 41 f7 de 3d 00 f0 ff ff b8 00 00 00 00  A·ÆA÷Þ=·ðÿÿ¸····
rbx 0x000000000000000b  11
rsi 0x0000000000390816  3737622
rdi 0x0000000000390816  3737622
rbp 0x0000594076fdfb40  60 fb fd 76 40 59 00 00 7e d2 ab cd 84 71 00 00  `ûýv@Y··~Ò«Í·q··
rsp 0x0000594076fdfb00  00 00 00 00 00 00 00 00 00 a8 10 47 f8 fb 68 59  ·········¨·GøûhY
 r8 0x0000594076f72010  02 00 07 00 04 00 06 00 06 00 06 00 04 00 04 00  ················
 r9 0x0000000000000007  7
r10 0x00007184cda8e750  d4 01 00 00 12 00 11 00 60 52 04 00 00 00 00 00  Ô·······`R······
r11 0x0000000000000246  582
r12 0x000000000000000b  11
r13 0x0000000000000007  7
r14 0x0000000000000016  22
r15 0x0000594076fdfc08  ff ff ff 7f fe ff ff ff 00 00 00 00 00 00 00 00  ÿÿÿ·þÿÿÿ········
rip 0x00007184cdb16b2c  41 89 c6 41 f7 de 3d 00 f0 ff ff b8 00 00 00 00  A·ÆA÷Þ=·ðÿÿ¸····

rflags 0x0000000000000246  ZF PF

cs 0x0033  fs 0x0000  gs 0x0000
```

### Expected behavior

not crash

### Environment

docker run --rm -v "$PWD":/work -w /work swift:latest bash -lc 'swiftc -c test.swift -o /dev/null'

### Additional information

_No response_
