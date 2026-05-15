---
render_with_liquid: false
---

# [Crash when evaluating request ExecuteSILPipelineRequest(Run pipelines ... on SIL for min)](https://github.com/swiftlang/swift/issues/86407)

### Description

To reproduce: `swiftc -sil-verify-all -O -c test.swift`

### Reproduction

```swift
var globalStorage = [Int: [Int]]()

class Service {
    func run(data: [[String: Any]]) {
        for item in data {
        
            let innerList: [[String: Any]] = []
            
            for innerItem in innerList {
                if (item["Score"] as? Int ?? 0) != 0 {
                    
                    if !(innerItem["Flag"] as? Bool ?? false) {
                    }
                    
                    let queue: [Int] = []
                    for id in queue {
                        globalStorage[id, default: []].append(item["ID"] as! Int)
                    }
                }
            }
        }
    }
}

let s = Service()
s.run(data: [["Score": 10, "ID": 1]])
```


### Stack dump

```text
SIL verification failed: invalid enclosing value in borrowed-from:   %2 = enum $Optional<@callee_guaranteed @substituted <τ_0_0> () -> @out τ_0_0 for <Array<Int>>>, #Optional.none!enumelt // users: %52, %49, %26, %3
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -c -primary-file min.swift -target x86_64-unknown-linux-gnu -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -O -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name min -sil-verify-all -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -enable-default-cmo -o min.o
1.	Swift version 6.2.3 (swift-6.2.3-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request ExecuteSILPipelineRequest(Run pipelines { PrepareOptimizationPasses, EarlyModulePasses, HighLevel,Function+EarlyLoopOpt, HighLevel,Module+StackPromote, MidLevel,Function, ClosureSpecialize, LowLevel,Function, LateLoopOpt, SIL Debug Info Generator } on SIL for min)
4.	While running pass #6396 SILFunctionTransform "SimplifyCFG" on SILFunction "@$s3min7ServiceC3run4dataySaySDySSypGG_tF".
 for 'run(data:)' (at min.swift:4:5)
 #0 0x000063a1bab9bc58 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x731ec58)
 #1 0x000063a1bab99a2e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731ca2e)
 #2 0x000063a1bab9c2f1 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x00007bb3c4b6a330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007bb3c4bc3b2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007bb3c4b6a27e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007bb3c4b4d8ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x000063a1b54aa349 (/usr/bin/swift-frontend+0x1c2d349)
 #8 0x000063a1b4e96bc2 verifierError(BridgedStringRef, OptionalBridgedInstruction, OptionalBridgedArgument) (/usr/bin/swift-frontend+0x1619bc2)
 #9 0x000063a1b42f5ae9 $s3SIL16BorrowedFromInstC9OptimizerE6verifyyyAD19FunctionPassContextVF crtstuff.c:0:0
#10 0x000063a1b42f5966 $s3SIL8FunctionC9OptimizerE6verifyyyAD0B11PassContextVF (/usr/bin/swift-frontend+0xa78966)
#11 0x000063a1b42f703a $s9Optimizer16registerVerifieryyFySo18BridgedPassContextV_So0D8FunctionVtcfU_To (/usr/bin/swift-frontend+0xa7a03a)
#12 0x000063a1b4e93686 swift::SILPassManager::runSwiftFunctionVerification(swift::SILFunction*) (/usr/bin/swift-frontend+0x1616686)
#13 0x000063a1b4c58bd0 swift::SILPassManager::runPassOnFunction(unsigned int, swift::SILFunction*) (/usr/bin/swift-frontend+0x13dbbd0)
#14 0x000063a1b4c5965f swift::SILPassManager::runFunctionPasses(unsigned int, unsigned int) (/usr/bin/swift-frontend+0x13dc65f)
#15 0x000063a1b4c56748 swift::SILPassManager::executePassPipelinePlan(swift::SILPassPipelinePlan const&) (/usr/bin/swift-frontend+0x13d9748)
#16 0x000063a1b4c566fd swift::ExecuteSILPipelineRequest::evaluate(swift::Evaluator&, swift::SILPipelineExecutionDescriptor) const (/usr/bin/swift-frontend+0x13d96fd)
#17 0x000063a1b4c826da swift::SimpleRequest<swift::ExecuteSILPipelineRequest, std::tuple<> (swift::SILPipelineExecutionDescriptor), (swift::RequestFlags)1>::evaluateRequest(swift::ExecuteSILPipelineRequest const&, swift::Evaluator&) crtstuff.c:0:0
#18 0x000063a1b4c6019d swift::ExecuteSILPipelineRequest::OutputType swift::Evaluator::getResultUncached<swift::ExecuteSILPipelineRequest, swift::ExecuteSILPipelineRequest::OutputType swift::evaluateOrFatal<swift::ExecuteSILPipelineRequest>(swift::Evaluator&, swift::ExecuteSILPipelineRequest)::'lambda'()>(swift::ExecuteSILPipelineRequest const&, swift::ExecuteSILPipelineRequest::OutputType swift::evaluateOrFatal<swift::ExecuteSILPipelineRequest>(swift::Evaluator&, swift::ExecuteSILPipelineRequest)::'lambda'()) crtstuff.c:0:0
#19 0x000063a1b4c5685f swift::executePassPipelinePlan(swift::SILModule*, swift::SILPassPipelinePlan const&, bool, swift::irgen::IRGenModule*) (/usr/bin/swift-frontend+0x13d985f)
#20 0x000063a1b4c60f7b swift::runSILOptimizationPasses(swift::SILModule&) (/usr/bin/swift-frontend+0x13e3f7b)
#21 0x000063a1b46ad2ae swift::CompilerInstance::performSILProcessing(swift::SILModule*) (/usr/bin/swift-frontend+0xe302ae)
#22 0x000063a1b43f0a3f performCompileStepsPostSILGen(swift::CompilerInstance&, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>>, llvm::PointerUnion<swift::ModuleDecl*, swift::SourceFile*>, swift::PrimarySpecificPaths const&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#23 0x000063a1b43ef957 swift::performCompileStepsPostSema(swift::CompilerInstance&, int&, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb72957)
#24 0x000063a1b43f21fa performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#25 0x000063a1b43f1744 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb74744)
#26 0x000063a1b41a3029 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x926029)
#27 0x00007bb3c4b4f1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#28 0x00007bb3c4b4f28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#29 0x000063a1b41a2175 _start (/usr/bin/swift-frontend+0x925175)
Aborted (core dumped)
```

### Expected behavior

should not crash

### Environment

Swift version 6.2.3 (swift-6.2.3-RELEASE)

### Additional information

_No response_
