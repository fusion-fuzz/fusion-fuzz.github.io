import SwiftDiagnostics
import SwiftOperators
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// --- Seed A ---
var __v_27278 = "x"
for __v_27279 in 0..<13 {
    do {
        __v_27278 += __v_27278
    } catch {
    }
}

do {
    let _ = try NSRegularExpression(pattern: "(xx|x)*").firstMatch(in: __v_27278, options: [], range: NSRange(location: 0, length: __v_27278.utf16.count))
} catch {
}

// --- Fusion Bridge ---
var fusion_8e4e = __v_27278

// --- Seed B ---

public struct AddStructDeclMacro: DeclarationMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    return [
    fusion_8e4e"
    @AddExtension
    struct MacroAddedStruct {
      var macroAddedStructMember = 1
    }
    """
    ]
  }
}

public struct AddVarDeclMacro: DeclarationMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    return [
    """
    static let macroAddedVar = 2
    """
    ]
  }
}

public struct AddExtensionMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    return protocols.map {
      ("""
      extension \(type.trimmed): \($0) {
        struct _Extension_\($0): \($0) {
          var nested = 8
        }
      }
      """ as DeclSyntax)
      .cast(ExtensionDeclSyntax.self)
    } + [
    ("""
    extension \(type.trimmed) {
      static let _extension_\(declaration.declGroupName) = 3
    }
    """ as DeclSyntax).cast(ExtensionDeclSyntax.self)
    ]
  }
}

public struct AddSpecificExtensionMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    var extensions = [ExtensionDeclSyntax]()
    let protocolNames = Set(protocols.compactMap { $0.as(IdentifierTypeSyntax.self)?.name.text })
    if protocolNames.contains("MyProto") {
        extensions.append(try ExtensionDeclSyntax("extension \(type.trimmed): MyProto") { })
    }
    return extensions
  }
}

public struct AddPeerVarMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let name = declaration.declName
    return [
    """
    static var _peer_\(name) = 4
    """
    ]
  }
}

public struct AddMemberMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let typeName = declaration.declGroupName
    return [
    """
    static let _member_\(typeName) = 5
    """
    ]
  }
}

public struct AddMemberAttributeMacro: MemberAttributeMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingAttributesFor member: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AttributeSyntax] {
    if member.isProtocol(DeclGroupSyntax.self) {
      return ["@AddExtension"]
    }
    return ["@AddPeerVar"]
  }
}

public struct GetterMacro: AccessorMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingAccessorsOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AccessorDeclSyntax] {
    return ["get { 6 }"]
  }
}

public struct AddPeerStructMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let name = declaration.declName
    return [
    """
    @AddExtension
    @AddMemberVar
    struct _Peer_\(name) {
      #AddMacroAddedVar
      
      @AddPeerVar
      var peerMacroVar = 7
    }
    """
    ]
  }
}

extension DeclGroupSyntax {
  var declGroupName: TokenSyntax {
    if let structDecl = self.as(StructDeclSyntax.self) {
      return structDecl.name.trimmed
    }
    fatalError("Not implemented")
  }
}

extension DeclSyntaxProtocol {
  var declName: TokenSyntax {
    if let varDecl = self.as(VariableDeclSyntax.self),
       let first = varDecl.bindings.first,
       let pattern = first.pattern.as(IdentifierPatternSyntax.self) {
      return pattern.identifier.trimmed
    } else if let funcDecl = self.as(FunctionDeclSyntax.self) {
      return funcDecl.name.trimmed
    } else if let structDecl = self.as(StructDeclSyntax.self) {
      return structDecl.name.trimmed
    }
    fatalError("Not implemented")
  }
}
// --- Bug Primitive ---

// P4: Closure capture / @escaping / ownership stress
func _ffl_p4_apply<T>(_ f: () -> T) -> T { f() }
func _ffl_p4_escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var _ffl_cap = fusion_8e4e
    // noescape: bridge captured by reference on the stack
    let _ffl_local = _ffl_p4_apply { _ffl_cap }
    // @escaping: bridge promoted to heap box
    let _ffl_esc   = _ffl_p4_escape { _ffl_cap }
    // nested closure capturing both outer and inner captures
    let _ffl_nest: () -> String = {
        let inner = _ffl_esc()
        return "\(inner) \(_ffl_local)"
    }
    _ = _ffl_nest()
    // mutation after escape — probes copy-on-write / exclusive-access
    _ffl_cap = fusion_8e4e
    _ = _ffl_esc()
}
