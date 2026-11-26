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
