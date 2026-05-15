# [Assertion failed ParseDecl.cpp:9084](https://github.com/swiftlang/swift/issues/84903)

### Description

_No response_

### Reproduction

```swift
let __fusion_0 = [1,2,3]

@abi(func a {
```


### Stack dump

```text
Assertion failed: (!Flags.contains(PD_StubOnly) && "stub-only should parse body immediately"), function parseAbstractFunctionBody at ParseDecl.cpp:9084.
(to display assertion configuration options: -Xllvm -assert-help)
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -c -primary-file fused.swift -target x86_64-unknown-linux-gnu -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name fused -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -o /tmp/TemporaryDirectory.c9DEiD/fused-1.o
1.	Swift version 6.2 (swift-6.2-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request ParseTopLevelDeclsRequest(source_file "fused.swift")
4.	While evaluating request ParseSourceFileRequest(source_file "fused.swift")
5.	With parser at source location: fused.swift:4:1
 #0 0x00005c5abfd4c598 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x7316598)
 #1 0x00005c5abfd4a36e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731436e)
 #2 0x00005c5abfd4cc31 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x0000737c33cca330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x0000737c33d23b2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x0000737c33cca27e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x0000737c33cad8ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x00005c5abb158b4b (/usr/bin/swift-frontend+0x2722b4b)
 #8 0x00005c5ababf36df swift::Parser::parseAbstractFunctionBody(swift::AbstractFunctionDecl*, swift::optionset::OptionSet<swift::Parser::ParseDeclFlags, unsigned short>) (/usr/bin/swift-frontend+0x21bd6df)
 #9 0x00005c5ababf7730 swift::Parser::parseDeclFunc(swift::SourceLoc, swift::StaticSpellingKind, swift::optionset::OptionSet<swift::Parser::ParseDeclFlags, unsigned short>, swift::DeclAttributes&, bool) (/usr/bin/swift-frontend+0x21c1730)
#10 0x00005c5ababed3b9 swift::Parser::parseDecl(bool, bool, llvm::function_ref<void (swift::Decl*)>, bool)::$_30::operator()(bool) const ParseDecl.cpp:0:0
#11 0x00005c5ababde6f1 swift::Parser::parseDecl(bool, bool, llvm::function_ref<void (swift::Decl*)>, bool) (/usr/bin/swift-frontend+0x21a86f1)
#12 0x00005c5ababda5c8 swift::Parser::parseNewDeclAttribute(swift::DeclAttributes&, swift::SourceLoc, swift::DeclAttrKind, bool) (/usr/bin/swift-frontend+0x21a45c8)
#13 0x00005c5ababe0b2b swift::Parser::parseDeclAttribute(swift::DeclAttributes&, swift::SourceLoc, swift::SourceLoc, bool) (/usr/bin/swift-frontend+0x21aab2b)
#14 0x00005c5ababe4287 swift::Parser::parseDeclAttributeList(swift::DeclAttributes&, bool) (/usr/bin/swift-frontend+0x21ae287)
#15 0x00005c5ababde425 swift::Parser::parseDecl(bool, bool, llvm::function_ref<void (swift::Decl*)>, bool) (/usr/bin/swift-frontend+0x21a8425)
#16 0x00005c5abac28245 swift::Parser::parseBraceItems(llvm::SmallVectorImpl<swift::ASTNode>&, swift::BraceItemListKind, swift::BraceItemListKind, bool&) (/usr/bin/swift-frontend+0x21f2245)
#17 0x00005c5ababcd4fa swift::Parser::parseTopLevelItems(llvm::SmallVectorImpl<swift::ASTNode>&) (/usr/bin/swift-frontend+0x21974fa)
#18 0x00005c5abac21404 swift::ParseSourceFileRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x21eb404)
#19 0x00005c5abac24edc swift::SimpleRequest<swift::ParseSourceFileRequest, swift::SourceFileParsingResult (swift::SourceFile*), (swift::RequestFlags)20>::evaluateRequest(swift::ParseSourceFileRequest const&, swift::Evaluator&) crtstuff.c:0:0
#20 0x00005c5ab93c83e3 swift::ParseSourceFileRequest::OutputType swift::Evaluator::getResultUncached<swift::ParseSourceFileRequest, swift::ParseSourceFileRequest::OutputType swift::evaluateOrDefault<swift::ParseSourceFileRequest>(swift::Evaluator&, swift::ParseSourceFileRequest, swift::ParseSourceFileRequest::OutputType)::'lambda'()>(swift::ParseSourceFileRequest const&, swift::ParseSourceFileRequest::OutputType swift::evaluateOrDefault<swift::ParseSourceFileRequest>(swift::Evaluator&, swift::ParseSourceFileRequest, swift::ParseSourceFileRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#21 0x00005c5abac224d6 swift::ParseTopLevelDeclsRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x21ec4d6)
#22 0x00005c5abaf8cca5 swift::ParseTopLevelDeclsRequest::OutputType swift::Evaluator::getResultUncached<swift::ParseTopLevelDeclsRequest, swift::ParseTopLevelDeclsRequest::OutputType swift::evaluateOrDefault<swift::ParseTopLevelDeclsRequest>(swift::Evaluator&, swift::ParseTopLevelDeclsRequest, swift::ParseTopLevelDeclsRequest::OutputType)::'lambda'()>(swift::ParseTopLevelDeclsRequest const&, swift::ParseTopLevelDeclsRequest::OutputType swift::evaluateOrDefault<swift::ParseTopLevelDeclsRequest>(swift::Evaluator&, swift::ParseTopLevelDeclsRequest, swift::ParseTopLevelDeclsRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#23 0x00005c5abaf8cb18 swift::ParseTopLevelDeclsRequest::OutputType swift::Evaluator::getResultCached<swift::ParseTopLevelDeclsRequest, swift::ParseTopLevelDeclsRequest::OutputType swift::evaluateOrDefault<swift::ParseTopLevelDeclsRequest>(swift::Evaluator&, swift::ParseTopLevelDeclsRequest, swift::ParseTopLevelDeclsRequest::OutputType)::'lambda'(), (void*)0>(swift::ParseTopLevelDeclsRequest const&, swift::ParseTopLevelDeclsRequest::OutputType swift::evaluateOrDefault<swift::ParseTopLevelDeclsRequest>(swift::Evaluator&, swift::ParseTopLevelDeclsRequest, swift::ParseTopLevelDeclsRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#24 0x00005c5abaf6194b swift::SourceFile::getTopLevelDecls() const (/usr/bin/swift-frontend+0x252b94b)
#25 0x00005c5aba7f19e6 swift::performImportResolution(swift::SourceFile&) (/usr/bin/swift-frontend+0x1dbb9e6)
#26 0x00005c5aba7f192d swift::performImportResolution(swift::ModuleDecl*) (/usr/bin/swift-frontend+0x1dbb92d)
#27 0x00005c5ab985e6e6 swift::CompilerInstance::performParseAndResolveImportsOnly() (/usr/bin/swift-frontend+0xe286e6)
#28 0x00005c5ab985e75f swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xe2875f)
#29 0x00005c5ab95a453a performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#30 0x00005c5ab95a3ae4 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb6dae4)
#31 0x00005c5ab935b1f9 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x9251f9)
#32 0x0000737c33caf1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#33 0x0000737c33caf28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#34 0x00005c5ab935a345 _start (/usr/bin/swift-frontend+0x924345)
```

### Expected behavior

not crash

### Environment

docker run --rm -v "$PWD":/work -w /work swift:latest bash -lc 'swiftc -c test.swift -o /dev/null'

### Additional information

_No response_
