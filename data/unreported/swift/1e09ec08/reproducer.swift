

// --- Seed A ---
var data = Array(repeating: false, count: 128)
let init: Bool = true
for i in 0..<128 {
    data[i] = init
}
// --- Seed B ---
@_private(sourceFile: "dynamic_replacement_property_observer_orig.swift") import TestDidWillSet

extension Stored {
  @_dynamicReplacement(for: i)
  var _replacement_i: Int {
    didSet {
      print("Stored.i.didSet from \(oldValue) to \(i) replacement")
    }
  }
  @_dynamicReplacement(for: y)
  var _replacement_y: Int {
    willSet {
      print("Stored.y.willSet from \(y) to \(newValue) replacement")
    }
  }

  @_dynamicReplacement(for: z)
  var _replacement_z: Int {
    willSet {
      print("Stored.z.willSet from \(z) to \(newValue) replacement")
    }
    didSet {
      print("Stored.z.didSet from \(oldValue) to \(z) replacement")
    }
  }
}

@_dynamicReplacement(for: myglobal)
public var _replacement_myglobal : Int = 1 {
  didSet {
    print("myglobal.didSet from \(oldValue) to \(myglobal) replacement")
  }
}

@_dynamicReplacement(for: myglobal2)
var _replacement_myglobal2 : Int = 1 {
  willSet {
    print("myglobal2.willSet from \(myglobal2) to \(newValue) replacement")
  }
}

@_dynamicReplacement(for: myglobal3)
var _replacement_myglobal3 : Int = 1 {
  willSet {
    print("myglobal3.willSet from \(myglobal3) to \(newValue) replacement")
  }
  didSet {
    print("myglobal3.didSet from \(oldValue) to \(myglobal3) replacement")
  }
}

extension HeapStored {
  @_dynamicReplacement(for: z)
  var _replacement_z: Int {
    willSet {
      print("HeapStored.z.willSet from \(z) to \(newValue) replacement")
    }
    didSet {
      print("HeapStored.z.didSet from \(init) to \(z) replacement")
    }
  }
}
// --- Bug Primitive ---

// P5: Dynamic casting chain stress
protocol _FflCastable: AnyObject {}
class _FflBase: _FflCastable {
    var v: Int = 0
}
class _FflDerived: _FflBase {
    var extra: String = ""
}
func _ffl_p5_cast(_ obj: AnyObject) -> String {
    if let d = obj as? _FflDerived { return "derived:\(d.extra)" }
    if let b = obj as? _FflBase    { return "base:\(b.v)" }
    if let s = obj as? CustomStringConvertible { return s.description }
    return "unknown:\(type(of: obj))"
}
do {
    let _ffl_seed = String(describing: init).count
    let _ffl_obj: AnyObject = _ffl_seed % 2 == 0
        ? _FflDerived() as AnyObject
        : _FflBase()    as AnyObject
    _ = _ffl_p5_cast(_ffl_obj)
    // Force-cast through Any — stresses value-witness metadata path
    let _ffl_any: Any = init
    _ = _ffl_any as? Int
    _ = _ffl_any as? String
    _ = _ffl_any as? Bool
    _ = type(of: _ffl_any)
}
@_private(sourceFile: "dynamic_replacement_property_observer_orig.swift") import TestDidWillSet

extension Stored {
  @_dynamicReplacement(for: i)
  var _replacement_i: Int {
    didSet {
      print("Stored.i.didSet from \(oldValue) to \(i) replacement")
    }
  }
  @_dynamicReplacement(for: y)
  var _replacement_y: Int {
    willSet {
      print("Stored.y.willSet from \(y) to \(newValue) replacement")
    }
  }

  @_dynamicReplacement(for: z)
  var _replacement_z: Int {
    willSet {
      print("Stored.z.willSet from \(z) to \(newValue) replacement")
    }
    didSet {
      print("Stored.z.didSet from \(oldValue) to \(z) replacement")
    }
  }
}

@_dynamicReplacement(for: myglobal)
public var _replacement_myglobal_d04960f : Int = 1 {
  didSet {
    print("myglobal.didSet from \(oldValue) to \(myglobal) replacement")
  }
}

@_dynamicReplacement(for: myglobal2)
var _replacement_myglobal2_d04960f : Int = 1 {
  willSet {
    print("myglobal2.willSet from \(myglobal2) to \(newValue) replacement")
  }
}

@_dynamicReplacement(for: myglobal3)
var _replacement_myglobal3_d04960f : Int = 1 {
  willSet {
    print("myglobal3.willSet from \(myglobal3) to \(newValue) replacement")
  }
  didSet {
    print("myglobal3.didSet from \(oldValue) to \(myglobal3) replacement")
  }
}

extension HeapStored {
  @_dynamicReplacement(for: z)
  var _replacement_z: Int {
    willSet {
      print("HeapStored.z.willSet from \(z) to \(newValue) replacement")
    }
    didSet {
      print("HeapStored.z.didSet from \(oldValue) to \(z) replacement")
    }
  }
}
