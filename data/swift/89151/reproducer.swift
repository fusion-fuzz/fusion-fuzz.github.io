protocol DefaultInit {
    init()
}

@attached(extension, conformances: DefaultInit)
@attached(member, conformances: DefaultInit, names: named(init()), named(f()))
macro DefaultInit() = #externalMacro(module: "MacroDefinition", type: "RequiredDefaultInitMacro")

@DefaultInit
class C { }

@DefaultInit
class D: C { }
