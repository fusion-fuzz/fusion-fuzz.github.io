# [Infinite recursion in TypeBase::isBindableToSuperclassOf()](https://github.com/swiftlang/swift/issues/84851)

### Description

_No response_

### Reproduction

```swift
class a < b protocol
    c{associatedtype f : a<d> associatedtype d : a<f>} func e < b : c {
  b.f = b.d

let __fusion_0 = "fusion"

@propertyWrapper
public struct Wrapper<T> {
    public var wrappedV: T // part-way through typing wrappedValue
    
    public init(initialValue: T) {
        self.value = initialValue
    }
    
    public init(body: () -> T) {
        self.value = __fusion_0
    }
}

var globalInt: Int { return 17 }

public struct HasWrappers {
    @Wrapper
    public var x: Int = globalInt
    
    @Wrapper(body: { globalInt })
    public var y: Int
    
    @Wrapper(body: {
        struct Inner {
            @Wrapper
            var x: Int = globalInt
        }
        return Inner().x + globalInt
    })
    public var z: Int
    
    func backingUse() {
        _ = $y.value + $z.value + x + $x.value
    }
}

func useMemberwiseInits(i: Int) {
    _ = HasWrappers(x: i)
    _ = HasWrappers(y: Wrapper(initialValue: i))
}
```

cmd: `docker run --rm -v "$PWD":/work -w /work swift:latest bash -lc 'swiftc -c test.swift -o /dev/null'`


### Stack dump

```text
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -c -primary-file min.swift -target x86_64-unknown-linux-gnu -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name min -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -o /tmp/TemporaryDirectory.5lGf7R/min-1.o
1.	Swift version 6.2 (swift-6.2-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "min.swift")
4.	While evaluating request TypeCheckFunctionBodyRequest(min.(file).e()@min.swift:2:61)
5.	While type-checking statement at [min.swift:2:71 - line:50:1] RangeText="{
  b.f = b.d

let __fusion_0 = "fusion"

@propertyWrapper
public struct Wrapper<T> {
    public var wrappedV: T // part-way through typing wrappedValue
    
    public init(initialValue: T) {
        self.value = initialValue
    }
    
    public init(body: () -> T) {
        self.value = __fusion_0
    }
}

var globalInt: Int { return 17 }

public struct HasWrappers {
    @Wrapper
    public var x: Int = globalInt
    
    @Wrapper(body: { globalInt })
    public var y: Int
    
    @Wrapper(body: {
        struct Inner {
            @Wrapper
            var x: Int = globalInt
        }
        return Inner().x + globalInt
    })
    public var z: Int
    
    func backingUse() {
        _ = $y.value + $z.value + x + $x.value
    }
}

func useMemberwiseInits(i: Int) {
    _ = HasWrappers(x: i)
    _ = HasWrappers(y: Wrapper(initialValue: i))
"
6.	While type-checking expression at [min.swift:3:3 - line:3:11] RangeText="b.f = b."
7.	While type-checking-target starting at min.swift:3:3
8.	While evaluating request LookupConformanceInModuleRequest(looking up conformance to Swift.(file).Copyable for b.f)
9.	While evaluating request LookupConformanceInModuleRequest(looking up conformance to Swift.(file).Copyable for a<b.d>)
  #0 0x00005c0da0102598 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x7316598)
  #1 0x00005c0da010036e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731436e)
  #2 0x00005c0da0102c31 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
  #3 0x00007888aea22330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
  #4 0x00005c0d9b4493b0 void swift::ConformanceLookupTable::forEachInStage<swift::ConformanceLookupTable::updateLookupTable(swift::NominalTypeDecl*, swift::ConformanceLookupTable::ConformanceStage)::$_3, swift::ConformanceLookupTable::updateLookupTable(swift::NominalTypeDecl*, swift::ConformanceLookupTable::ConformanceStage)::$_4>(swift::ConformanceLookupTable::ConformanceStage, swift::NominalTypeDecl*, swift::ConformanceLookupTable::updateLookupTable(swift::NominalTypeDecl*, swift::ConformanceLookupTable::ConformanceStage)::$_3, swift::ConformanceLookupTable::updateLookupTable(swift::NominalTypeDecl*, swift::ConformanceLookupTable::ConformanceStage)::$_4) ConformanceLookupTable.cpp:0:0
  #5 0x00005c0d9b447f2f swift::ConformanceLookupTable::updateLookupTable(swift::NominalTypeDecl*, swift::ConformanceLookupTable::ConformanceStage) (/usr/bin/swift-frontend+0x265bf2f)
  #6 0x00005c0d9b44bdc9 swift::ConformanceLookupTable::lookupConformance(swift::NominalTypeDecl*, swift::ProtocolDecl*, llvm::SmallVectorImpl<swift::ProtocolConformance*>&) (/usr/bin/swift-frontend+0x265fdc9)
  #7 0x00005c0d9b1c08c5 swift::LookupConformanceInModuleRequest::evaluate(swift::Evaluator&, swift::LookupConformanceDescriptor) const (/usr/bin/swift-frontend+0x23d48c5)
  #8 0x00005c0d9b1c28ed swift::LookupConformanceInModuleRequest::OutputType swift::Evaluator::getResultUncached<swift::LookupConformanceInModuleRequest, swift::LookupConformanceInModuleRequest::OutputType swift::evaluateOrDefault<swift::LookupConformanceInModuleRequest>(swift::Evaluator&, swift::LookupConformanceInModuleRequest, swift::LookupConformanceInModuleRequest::OutputType)::'lambda'()>(swift::LookupConformanceInModuleRequest const&, swift::LookupConformanceInModuleRequest::OutputType swift::evaluateOrDefault<swift::LookupConformanceInModuleRequest>(swift::Evaluator&, swift::LookupConformanceInModuleRequest, swift::LookupConformanceInModuleRequest::OutputType)::'lambda'()) crtstuff.c:0:0
  #9 0x00005c0d9b1bfc24 swift::lookupConformance(swift::Type, swift::ProtocolDecl*, bool) (/usr/bin/swift-frontend+0x23d3c24)
 #10 0x00005c0d9b1c053b swift::LookupConformanceInModuleRequest::evaluate(swift::Evaluator&, swift::LookupConformanceDescriptor) const (/usr/bin/swift-frontend+0x23d453b)
 #11 0x00005c0d9b1c28ed swift::LookupConformanceInModuleRequest::OutputType swift::Evaluator::getResultUncached<swift::LookupConformanceInModuleRequest, swift::LookupConformanceInModuleRequest::OutputType swift::evaluateOrDefault<swift::LookupConformanceInModuleRequest>(swift::Evaluator&, swift::LookupConformanceInModuleRequest, swift::LookupConformanceInModuleRequest::OutputType)::'lambda'()>(swift::LookupConformanceInModuleRequest const&, swift::LookupConformanceInModuleRequest::OutputType swift::evaluateOrDefault<swift::LookupConformanceInModuleRequest>(swift::Evaluator&, swift::LookupConformanceInModuleRequest, swift::LookupConformanceInModuleRequest::OutputType)::'lambda'()) crtstuff.c:0:0
 #12 0x00005c0d9b1bfc24 swift::lookupConformance(swift::Type, swift::ProtocolDecl*, bool) (/usr/bin/swift-frontend+0x23d3c24)
 #13 0x00005c0d9b42e015 swift::InFlightSubstitution::lookupConformance(swift::CanType, swift::Type, swift::ProtocolDecl*, unsigned int) (/usr/bin/swift-frontend+0x2642015)
 #14 0x00005c0d9b3f83ef swift::SubstitutionMap::get(swift::GenericSignature, llvm::ArrayRef<swift::Type>, swift::InFlightSubstitution&) (/usr/bin/swift-frontend+0x260c3ef)
 #15 0x00005c0d9b3f8252 swift::SubstitutionMap::get(swift::GenericSignature, swift::InFlightSubstitution&) (/usr/bin/swift-frontend+0x260c252)
 #16 0x00005c0d9b3f80ac swift::SubstitutionMap::get(swift::GenericSignature, llvm::function_ref<swift::Type (swift::SubstitutableType*)>, llvm::function_ref<swift::ProtocolConformanceRef (swift::CanType, swift::Type, swift::ProtocolDecl*)>) (/usr/bin/swift-frontend+0x260c0ac)
 #17 0x00005c0d9b431e97 swift::TypeBase::getContextSubstitutionMap(swift::DeclContext const*, swift::GenericEnvironment*) (/usr/bin/swift-frontend+0x2645e97)
 #18 0x00005c0d9b416c39 (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #19 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #20 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #21 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #22 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #23 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #24 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #25 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #26 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #27 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #28 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #29 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #30 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #31 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #32 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #33 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #34 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #35 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #36 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #37 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #38 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #39 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #40 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #41 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #42 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #43 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #44 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #45 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #46 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #47 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #48 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #49 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #50 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #51 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #52 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #53 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #54 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #55 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #56 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #57 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #58 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #59 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #60 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #61 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #62 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #63 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #64 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #65 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #66 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #67 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #68 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #69 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #70 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #71 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #72 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #73 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #74 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #75 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #76 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #77 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #78 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #79 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #80 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #81 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #82 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #83 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #84 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #85 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #86 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #87 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #88 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #89 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #90 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #91 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #92 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #93 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #94 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #95 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #96 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
 #97 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
 #98 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
 #99 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#100 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#101 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#102 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#103 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#104 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#105 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#106 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#107 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#108 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#109 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#110 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#111 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#112 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#113 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#114 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#115 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#116 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#117 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#118 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#119 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#120 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#121 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#122 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#123 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#124 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#125 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#126 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#127 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#128 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#129 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#130 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#131 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#132 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#133 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#134 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#135 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#136 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#137 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#138 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#139 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#140 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#141 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#142 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#143 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#144 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#145 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#146 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#147 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#148 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#149 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#150 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#151 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#152 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#153 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#154 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#155 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#156 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#157 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#158 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#159 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#160 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#161 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#162 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#163 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#164 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#165 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#166 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#167 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#168 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#169 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#170 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#171 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#172 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#173 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#174 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#175 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#176 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#177 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#178 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#179 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#180 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#181 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#182 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#183 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#184 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#185 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#186 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#187 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#188 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#189 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#190 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#191 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#192 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#193 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#194 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#195 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#196 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#197 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#198 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#199 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#200 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#201 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#202 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#203 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#204 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#205 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#206 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#207 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#208 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#209 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#210 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#211 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#212 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#213 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#214 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#215 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#216 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#217 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#218 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#219 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#220 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#221 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#222 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#223 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#224 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#225 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#226 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#227 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#228 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#229 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#230 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#231 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#232 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#233 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#234 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#235 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#236 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#237 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#238 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#239 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#240 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#241 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#242 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#243 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#244 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#245 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#246 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#247 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#248 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#249 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#250 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#251 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#252 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0
#253 0x00005c0d9b407b9b swift::TypeBase::isBindableToSuperclassOf(swift::Type) (/usr/bin/swift-frontend+0x261bb9b)
#254 0x00005c0d9b417761 (anonymous namespace)::IsBindableVisitor::visitArchetypeType(swift::ArchetypeType*, swift::CanType) Type.cpp:0:0
#255 0x00005c0d9b416e6d (anonymous namespace)::IsBindableVisitor::handleGenericNominalType(swift::NominalTypeDecl*, swift::CanType, swift::CanType) Type.cpp:0:0

*** Signal 11: Backtracing from 0x7888aea7bb2c... done ***

*** Program crashed: Bad pointer dereference at 0x000000000006f1e8 ***

Platform: x86_64 Linux (Ubuntu 24.04.3 LTS)

Thread 0 "swift-frontend" crashed:

  0      0x00007888aea7bb2c <unknown> in libc.so.6
  1 [ra] 0x00007888aea2227e <unknown> in libc.so.6
...


Registers:

rax 0x0000000000000000  0
rdx 0x000000000006f1e8  455144
rcx 0x00007888aea7bb2c  41 89 c6 41 f7 de 3d 00 f0 ff ff b8 00 00 00 00  A·ÆA÷Þ=·ðÿÿ¸····
rbx 0x000000000000000b  11
rsi 0x000000000006f1e8  455144
rdi 0x000000000006f1e8  455144
rbp 0x00005c0dd4632b40  60 2b 63 d4 0d 5c 00 00 7e 22 a2 ae 88 78 00 00  `+cÔ·\··~"¢®·x··
rsp 0x00005c0dd4632b00  00 00 00 00 00 00 00 00 00 d3 2d 15 91 25 06 c2  ·········Ó-··%·Â
 r8 0x00005c0dd45c5010  05 00 06 00 04 00 06 00 07 00 04 00 04 00 03 00  ················
 r9 0x0000000000000007  7
r10 0x00007888ae9f3750  d4 01 00 00 12 00 11 00 60 52 04 00 00 00 00 00  Ô·······`R······
r11 0x0000000000000246  582
r12 0x000000000000000b  11
r13 0x00005c0dd496b700  b0 10 96 d4 0d 5c 00 00 0d 00 00 00 00 00 00 00  °··Ô·\··········
r14 0x0000000000000016  22
r15 0x00005c0dd4632c08  ff ff ff 7f fe ff ff ff 00 00 00 00 00 00 00 00  ÿÿÿ·þÿÿÿ········
rip 0x00007888aea7bb2c  41 89 c6 41 f7 de 3d 00 f0 ff ff b8 00 00 00 00  A·ÆA÷Þ=·ðÿÿ¸····

rflags 0x0000000000000246  ZF PF

cs 0x0033  fs 0x0000  gs 0x0000
```

### Expected behavior

should not crash anyway

### Environment

nightly

### Additional information

_No response_
