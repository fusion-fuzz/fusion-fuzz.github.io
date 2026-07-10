*Fusion-Fuzz Bug Report*

**ID:** `9d2ca348` &nbsp;·&nbsp; **Signature:** `Stack dump: current parser token '{' [clang::Parser::StashAwayMethodOrFunctionBodyTokens > clang::Parser::ParseObjCMethodDefinition > clang::Parser::ParseExternalDeclaration]` &nbsp;·&nbsp; **RC:** `1`

The following code:

```c
int main(void) {
    struct tm tm1 = {0}, tm2 = {0};
    time_t t1, t2;
    char buf1[32], buf2[32];

    tm1.tm_year = 2004 - 1900;
    tm1.tm_mon = 3;
    tm1.tm_mday = 4;
    tm1.tm_hour = 23;
    tm1.tm_min = 45;
    tm1.tm_isdst = -1;

    tm2.tm_year = 2004 - 1900;
    tm2.tm_mon = 3;
    tm2.tm_mday = 4;
    tm2.tm_hour = 0;
    tm2.tm_min = 45;
    tm2.tm_isdst = -1;

    t1 = mktime(&tm1);
    t2 = mktime(&tm2);

    if (gmtime(&t1)) strftime(buf1, sizeof(buf1), "%m/%d/%y %H%M", gmtime(&t1));
    if (gmtime(&t2)) strftime(buf2, sizeof(buf2), "%m/%d/%y %H%M", gmtime(&t2));

    puts("The following line rightly shows the correct date time:");
    puts(buf1);

    @end
    puts("But the following line fails to show the correct date time:");
    printf("%s\r\n", buf2);

    return 0;
}
@interface ISDPropertyChangeGroup
@end

@implementation ISDPropertyChangeGroup
@class ISDClientState;
#include <stdio.h>
#include <time.h>
// RUN: %clang_cc1 -x objective-c++ -Wno-return-type -fblocks -fms-extensions -rewrite-objc %s -o %t-rw.cpp
// RUN: %clang_cc1 -fsyntax-only -std=gnu++98 -fblocks -Wno-address-of-temporary -D"id=void*" -D"SEL=void*" -D"__declspec(X)=" %t-rw.cpp

extern "C" {
@class XX;
@class YY, ZZ, QQ;
@class ISyncClient, SMSession, ISyncManager, ISyncSession, SMDataclassInfo, SMClientInfo,
    DMCConfiguration, DMCStatusEntry;

@interface QQ

@end

@interface SMDataclassInfo : QQ
- (XX*) Meth;
- (DMCStatusEntry*)Meth2;
@end

@implementation SMDataclassInfo
- (XX*) Meth { return 0; }
- (DMCStatusEntry*)Meth2 { return 0; }
@end

@interface YY 
{
  ISyncClient *p1;
  ISyncSession *p2;
}
@property (copy) ISyncClient *p1;
@end

@implementation YY
@synthesize p1;
@end

extern "C" {
@class CCC;
@class Protocol, P , Q;
int I,J,K;
};

}
- (id)lastModifiedGeneration : (ISDClientState *) obj
{
  return obj ;
}
;
@end
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:2:15: error: variable has incomplete type 'struct tm'
    2 |     struct tm tm1 = {0}, tm2 = {0};
      |               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:2:12: note: forward declaration of 'tm'
    2 |     struct tm tm1 = {0}, tm2 = {0};
      |            ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:2:26: error: variable has incomplete type 'struct tm'
    2 |     struct tm tm1 = {0}, tm2 = {0};
      |                          ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:2:12: note: forward declaration of 'tm'
    2 |     struct tm tm1 = {0}, tm2 = {0};
      |            ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:3:5: error: unknown type name 'time_t'
    3 |     time_t t1, t2;
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:21:5: error: use of undeclared identifier 't2'
   21 |     t2 = mktime(&tm2);
      |     ^~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:24:17: error: use of undeclared identifier 't2'
   24 |     if (gmtime(&t2)) strftime(buf2, sizeof(buf2), "%m/%d/%y %H%M", gmtime(&t2));
      |                 ^~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:24:76: error: use of undeclared identifier 't2'
   24 |     if (gmtime(&t2)) strftime(buf2, sizeof(buf2), "%m/%d/%y %H%M", gmtime(&t2));
      |                                                                            ^~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:26:5: error: use of undeclared identifier 'puts'
   26 |     puts("The following line rightly shows the correct date time:");
      |     ^~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:27:5: error: use of undeclared identifier 'puts'
   27 |     puts(buf1);
      |     ^~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:29:5: error: unexpected '@' in program
   29 |     @end
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:31:5: error: use of undeclared identifier 'printf'
   31 |     printf("%s\r\n", buf2);
      |     ^~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:46:8: error: Objective-C declarations may only appear in global scope
   46 | @class XX;
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:47:8: error: Objective-C declarations may only appear in global scope
   47 | @class YY, ZZ, QQ;
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:47:12: error: Objective-C declarations may only appear in global scope
   47 | @class YY, ZZ, QQ;
      |            ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:47:16: error: Objective-C declarations may only appear in global scope
   47 | @class YY, ZZ, QQ;
      |                ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:48:8: error: Objective-C declarations may only appear in global scope
   48 | @class ISyncClient, SMSession, ISyncManager, ISyncSession, SMDataclassInfo, SMClientInfo,
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:48:21: error: Objective-C declarations may only appear in global scope
   48 | @class ISyncClient, SMSession, ISyncManager, ISyncSession, SMDataclassInfo, SMClientInfo,
      |                     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:48:32: error: Objective-C declarations may only appear in global scope
   48 | @class ISyncClient, SMSession, ISyncManager, ISyncSession, SMDataclassInfo, SMClientInfo,
      |                                ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:48:46: error: Objective-C declarations may only appear in global scope
   48 | @class ISyncClient, SMSession, ISyncManager, ISyncSession, SMDataclassInfo, SMClientInfo,
      |                                              ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:48:60: error: Objective-C declarations may only appear in global scope
   48 | @class ISyncClient, SMSession, ISyncManager, ISyncSession, SMDataclassInfo, SMClientInfo,
      |                                                            ^
fatal error: too many errors emitted, stopping now [-ferror-limit=]
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace, preprocessed source, and associated run script.
Stack dump:
0.	Program arguments: clang++ -emit-llvm -S -o /dev/null -Os -std=gnu++20 -fstrict-enums -fsanitize=address /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:85:1: current parser token '{'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpc9xvfsel/9d2ca348.mm:85:1: parsing Objective-C method 'ISDPropertyChangeGroup::lastModifiedGeneration:'
 #0 0x00007f55dffd3c9a llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-21/bin/../lib/libLLVM.so.21.1+0x45f2c9a)
 #1 0x00007f55dffd1487 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-21/bin/../lib/libLLVM.so.21.1+0x45f0487)
 #2 0x00007f55dff07654 (/usr/lib/llvm-21/bin/../lib/libLLVM.so.21.1+0x4526654)
 #3 0x00007f55db4a3df0 (/lib/x86_64-linux-gnu/libc.so.6+0x3fdf0)
 #4 0x00007f55e55a2d3f clang::Parser::StashAwayMethodOrFunctionBodyTokens(clang::Decl*) (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x15ffd3f)
 #5 0x00007f55e55a335e clang::Parser::ParseObjCMethodDefinition() (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x160035e)
 #6 0x00007f55e55ee811 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x164b811)
 #7 0x00007f55e559acde clang::Parser::ParseObjCAtImplementationDeclaration(clang::SourceLocation, clang::ParsedAttributes&) (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x15f7cde)
 #8 0x00007f55e5598ff8 clang::Parser::ParseObjCAtDirectives(clang::ParsedAttributes&, clang::ParsedAttributes&) (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x15f5ff8)
 #9 0x00007f55e55ee8af clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x164b8af)
#10 0x00007f55e55ed717 clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x164a717)
#11 0x00007f55e552c07e clang::ParseAST(clang::Sema&, bool, bool) (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x158907e)
#12 0x00007f55e713d26f clang::FrontendAction::Execute() (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x319a26f)
#13 0x00007f55e70aef74 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x310bf74)
#14 0x00007f55e71c5cce clang::ExecuteCompilerInvocation(clang::CompilerInstance*) (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x3222cce)
#15 0x0000557194bb488d cc1_main(llvm::ArrayRef<char const*>, char const*, void*) (/usr/lib/llvm-21/bin/clang+0x1388d)
#16 0x0000557194bb1435 (/usr/lib/llvm-21/bin/clang+0x10435)
#17 0x00007f55e6d625bd (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x2dbf5bd)
#18 0x00007f55dff07320 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) (/usr/lib/llvm-21/bin/../lib/libLLVM.so.21.1+0x4526320)
#19 0x00007f55e6d62041 clang::driver::CC1Command::Execute(llvm::ArrayRef<std::optional<llvm::StringRef>>, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>*, bool*) const (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x2dbf041)
#20 0x00007f55e6d22f92 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x2d7ff92)
#21 0x00007f55e6d2315e clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x2d8015e)
#22 0x00007f55e6d41a5d clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) (/usr/lib/llvm-21/bin/../lib/libclang-cpp.so.21.1+0x2d9ea5d)
#23 0x0000557194bb0f21 clang_main(int, char**, llvm::ToolContext const&) (/usr/lib/llvm-21/bin/clang+0xff21)
#24 0x0000557194bbf95a main (/usr/lib/llvm-21/bin/clang+0x1e95a)
#25 0x00007f55db48dca8 (/lib/x86_64-linux-gnu/libc.so.6+0x29ca8)
#26 0x00007f55db48dd65 __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x29d65)
#27 0x0000557194baf101 _start (/usr/lib/llvm-21/bin/clang+0xe101)
clang++: error: clang frontend command failed with exit code 139 (use -v to see invocation)
Debian clang version 21.1.8 (++20251221033036+2078da43e25a-1~exp1~20251221153213.50)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-21/bin
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING FILES TO THE BUG REPORT:
Preprocessed source(s) and associated run script(s) are located at:
clang++: note: diagnostic msg: /tmp/9d2ca348-8e11e8.mm
clang++: note: diagnostic msg: /tmp/9d2ca348-8e11e8.sh
clang++: note: diagnostic msg: 

********************
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' clang++ -emit-llvm -S -o /dev/null -Os -std=gnu++20 -fstrict-enums -fsanitize=address "$SCRIPT_DIR/test.mm"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `aebade41` | Bug corpus (project: `php`, name: `bug28088.phpt`) |
| `b` | `22ab0548` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
