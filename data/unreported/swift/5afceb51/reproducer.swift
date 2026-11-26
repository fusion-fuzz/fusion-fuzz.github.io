// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend %s -enable-library-evolution -module-name Structs -clang-header-expose-decls=all-public -typecheck -verify -emit-clang-header-path %t/structs.h
// RUN: %FileCheck %s < %t/structs.h

// RUN: %check-interop-cxx-header-in-clang(%t/structs.h -DSWIFT_CXX_INTEROP_HIDE_STL_OVERLAY)

public struct FirstSmallStruct {
    public var x: UInt32
#if CHANGE_LAYOUT
    public var y: UInt32 = 0
#endif

    public func dump() {
        print("find - small dump")
#if CHANGE_LAYOUT
        print("x&y = \(x)&\(y)")
#else
        print("x = \(x)")
#endif
    }

    public mutating func mutate() {
        x = x * 2
#if CHANGE_LAYOUT
        y = ~y
#endif
    }
}

// CHECK: class SWIFT_SYMBOL("s:7Structs16FirstSmallStructV") FirstSmallStruct;

// CHECK: template<>
// CHECK-NEXT: inline const constexpr bool isUsableInGenericContext<Structs::FirstSmallStruct> = true;

// CHECK: class SWIFT_SYMBOL("s:7Structs16FirstSmallStructV") FirstSmallStruct final {
// CHECK-NEXT: public:
// CHECK: SWIFT_INLINE_THUNK FirstSmallStruct(const FirstSmallStruct &other) noexcept {
// CHECK-NEXT:   auto metadata = _impl::$s7Structs16FirstSmallStructVMa(0);
// CHECK-NEXT:   auto *vwTableAddr = reinterpret_cast<swift::_impl::ValueWitnessTable **>(metadata._0) - 1;
// CHECK-NEXT: #ifdef __arm64e__
// CHECK-NEXT:   auto *vwTable = reinterpret_cast<swift::_impl::ValueWitnessTable *>(ptrauth_auth_data(reinterpret_cast<void *>(*vwTableAddr), ptrauth_key_process_independent_data, ptrauth_blend_discriminator(vwTableAddr, 11839)));
// CHECK-NEXT: #else
// CHECK-NEXT:   auto *vwTable = *vwTableAddr;
// CHECK-NEXT: #endif
// CHECK-NEXT:   _storage = swift::_impl::OpaqueStorage(vwTable->size, vwTable->getAlignment());
// CHECK-NEXT:   vwTable->initializeWithCopy(_getOpaquePointer(), const_cast<char *>(other._getOpaquePointer()), metadata._0);
// CHECK-NEXT: }
// CHECK: private:
// CHECK-NEXT:  SWIFT_INLINE_THUNK FirstSmallStruct(swift::_impl::ValueWitnessTable * _Nonnull vwTable) noexcept : _storage(vwTable->size, vwTable->getAlignment()) {}
// CHECK-NEXT:  static SWIFT_INLINE_THUNK FirstSmallStruct _make() noexcept {
// CHECK-NEXT:    auto metadata = _impl::$s7Structs16FirstSmallStructVMa(0);
// CHECK-NEXT:   auto *vwTableAddr = reinterpret_cast<swift::_impl::ValueWitnessTable **>(metadata._0) - 1;
// CHECK-NEXT: #ifdef __arm64e__
// CHECK-NEXT:   auto *vwTable = reinterpret_cast<swift::_impl::ValueWitnessTable *>(ptrauth_auth_data(reinterpret_cast<void *>(*vwTableAddr), ptrauth_key_process_independent_data, ptrauth_blend_discriminator(vwTableAddr, 11839)));
// CHECK-NEXT: #else
// CHECK-NEXT:   auto *vwTable = *vwTableAddr;
// CHECK-NEXT: #endif
// CHECK-NEXT:    return FirstSmallStruct(vwTable);
// CHECK-NEXT:  }
// CHECK-NEXT:  SWIFT_INLINE_THUNK const char * _Nonnull _getOpaquePointer() const noexcept { return _storage.getOpaquePointer(); }
// CHECK-NEXT:  SWIFT_INLINE_THUNK char * _Nonnull _getOpaquePointer() noexcept { return _storage.getOpaquePointer(); }
// CHECK-EMPTY:
// CHECK-NEXT:  swift::_impl::OpaqueStorage _storage;
// CHECK-NEXT:  friend class _impl::_impl_FirstSmallStruct;
// CHECK-NEXT: #pragma clang diagnostic push
// CHECK-NEXT: #pragma clang diagnostic ignored "-Wc++17-extensions"
// CHECK-NEXT: #pragma clang diagnostic push
// CHECK-NEXT: #pragma clang diagnostic ignored "-Wreserved-identifier"
// CHECK-NEXT:  typedef char $s7Structs16FirstSmallStructVD;
// CHECK-NEXT:  static inline constexpr $s7Structs16FirstSmallStructVD __swift_mangled_name = 0;
// CHECK-NEXT: #pragma clang diagnostic pop
// CHECK-NEXT: #pragma clang diagnostic pop
// CHECK-NEXT:};

// CHECK: class _impl_FirstSmallStruct {
// CHECK: };
// CHECK-EMPTY:
// CHECK-NEXT: }

// CHECK-EMPTY:
// CHECK-NEXT: } // end namespace
// CHECK-EMPTY:
// CHECK-NEXT: namespace swift SWIFT_PRIVATE_ATTR {
// CHECK-NEXT: #pragma clang diagnostic push
// CHECK-NEXT: #pragma clang diagnostic ignored "-Wc++17-extensions"
// CHECK-NEXT: template<>
// CHECK-NEXT: struct TypeMetadataTrait<Structs::FirstSmallStruct> {
// CHECK-NEXT: SWIFT_INLINE_PRIVATE_HELPER void * _Nonnull getTypeMetadata() {
// CHECK-NEXT:   return Structs::_impl::$s7Structs16FirstSmallStructVMa(0)._0;
// CHECK-NEXT: }
// CHECK-NEXT: };
// CHECK-NEXT: namespace _impl{
// CHECK-NEXT: template<>
// CHECK-NEXT: inline const constexpr bool isValueType<Structs::FirstSmallStruct> = true;
// CHECK-NEXT: template<>
// CHECK-NEXT: inline const constexpr bool isOpaqueLayout<Structs::FirstSmallStruct> = true;
// CHECK-NEXT: template<>
// CHECK-NEXT: struct implClassFor<Structs::FirstSmallStruct> { using type = Structs::_impl::_impl_FirstSmallStruct; };
// CHECK-NEXT: } // namespace
// CHECK-NEXT: #pragma clang diagnostic pop
// CHECK-NEXT: } // namespace swift
// CHECK-EMPTY:
// CHECK-NEXT: namespace Structs SWIFT_PRIVATE_ATTR SWIFT_SYMBOL_MODULE("Structs") {

@frozen public struct FrozenStruct {
    private let storedInt: Int32
}
// CHECK: class SWIFT_SYMBOL("s:7Structs12FrozenStructV") FrozenStruct final {
// CHECK:        alignas(4) char _storage[4];
// CHECK-NEXT:   friend class _impl::_impl_FrozenStruct;
// CHECK-NEXT: #pragma clang diagnostic push
// CHECK-NEXT: #pragma clang diagnostic ignored "-Wc++17-extensions"
// CHECK-NEXT: #pragma clang diagnostic push
// CHECK-NEXT: #pragma clang diagnostic ignored "-Wreserved-identifier"
// CHECK-NEXT:  typedef char $s7Structs12FrozenStructVD;
// CHECK-NEXT:  static inline constexpr $s7Structs12FrozenStructVD __swift_mangled_name = 0;
// CHECK-NEXT: #pragma clang diagnostic pop
// CHECK-NEXT: #pragma clang diagnostic pop
// CHECK-NEXT: };

public struct LargeStruct {
    public let x1: Int
    let x2, x3, x4, x5, x6: Int

    public var firstSmallStruct: FirstSmallStruct {
        return FirstSmallStruct(x: 65)
    }

    public func dump() {
        print("x.1 = \(x1), .2 = \(x2), .3 = \(x3), .4 = \(x4), .5 = \(x5)")
    }
}

// CHECK: class SWIFT_SYMBOL("s:7Structs11LargeStructV") LargeStruct final {
// CHECK-NEXT: public:
// CHECK: SWIFT_INLINE_THUNK LargeStruct(const LargeStruct &other) noexcept {
// CHECK-NEXT:   auto metadata = _impl::$s7Structs11LargeStructVMa(0);
// CHECK-NEXT:   auto *vwTableAddr = reinterpret_cast<swift::_impl::ValueWitnessTable **>(metadata._0) - 1;
// CHECK-NEXT: #ifdef __arm64e__
// CHECK-NEXT:   auto *vwTable = reinterpret_cast<swift::_impl::ValueWitnessTable *>(ptrauth_auth_data(reinterpret_cast<void *>(*vwTableAddr), ptrauth_key_process_independent_data, ptrauth_blend_discriminator(vwTableAddr, 11839)));
// CHECK-NEXT: #else
// CHECK-NEXT:   auto *vwTable = *vwTableAddr;
// CHECK-NEXT: #endif
// CHECK-NEXT:   _storage = swift::_impl::OpaqueStorage(vwTable->size, vwTable->getAlignment());
// CHECK-NEXT:   vwTable->initializeWithCopy(_getOpaquePointer(), const_cast<char *>(other._getOpaquePointer()), metadata._0);
// CHECK-NEXT: }
// RUN: %target-swift-frontend -sil-verify-all -enable-copy-propagation=requested-passes-only -emit-sil -primary-file %s -o /dev/null -verify

struct Test1 {
  var x: Int // expected-note {{variable defined here}}
  var y: Int // expected-note {{variable defined here}}
  var full: (Int, Int)

  var test1: (Int, Int) {
    @storageRestrictions(initializes: y, full, accesses: x)
    init(initialValue) {
      self.full = (self.x, self.y) // expected-error {{variable 'y' used before being initialized}}
    }

    get { full }
    set { self.full = newValue }
  }

  var pointY: Int {
    @storageRestrictions(initializes: y)
    init(initialValue) {
      self.y = initialValue // Ok
    }

    get { y }
    set {}
  }

  var errorPoint1: (Int, Int) {
    @storageRestrictions(initializes: x, y)
    init(initialValue) {
      // expected-error@-1 {{property 'x' not initialized by init accessor}}
      // expected-error@-2 {{property 'y' not initialized by init accessor}}
    }

    get { (x, y) }
    set { }
  }

  var errorPoint2: (Int, Int) {
    @storageRestrictions(initializes: x, y)
    init(initialValue) {
      // expected-error@-1 {{property 'y' not initialized by init accessor}}
      self.x = initialValue.0
    }

    get { (x, y) }
    set { }
  }

  var errorPoint3: (Int, Int) {
    @storageRestrictions(initializes: x, y)
    init(initialValue) {
      self.y = initialValue.1
      print(y) // Ok
      print(x) // expected-error {{variable 'x' used before being initialized}}
    }

    get { (x, y) }
    set { }
  }

  init(x: Int, y: Int) {
    self.x = x
    self.y = y
    self.full = (x, y)
  }
}

struct TestPartial {
  var x: Int
  var y: Int

  var point: (Int, Int) {
    @storageRestrictions(initializes: x, y)
    init(initialValue) {
      self.x = initialValue.0
      self.y = initialValue.1
    }

    get { (x, y) }
    set { }
  }

  init(x: Int, y: Int) {
    self.x = x
    self.point = (x, y) // Ok (x is going to get `destroy_addr`)
  }

  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
    self.point = (x, y) // Ok (calls a setter)
  }
}

struct TestDoubleInit1 {
  let x: Int // expected-note {{change 'let' to 'var' to make it mutable}}

  var invalidPointX: Int {
    @storageRestrictions(initializes: x)
    init(initialValue) {
      self.x = initialValue
      self.x = 42 // expected-error {{immutable value 'x' may only be initialized once}}
    }

    get { x }
    set { }
  }
}

struct TestDoubleInit2 {
  let x: Int // expected-note {{change 'let' to 'var' to make it mutable}}

  var pointX: Int {
    @storageRestrictions(initializes: x)
    init(initialValue) {
      self.x = initialValue
    }

    get { x }
    set { }
  }

  init(x: Int) {
    self.pointX = x
    self.x = 0 // expected-error {{immutable value 'self.x' may only be initialized once}}
  }
}

struct TestAccessBeforeInit {
  var _x: Int
  var x: Int {
    @storageRestrictions(initializes: _x, accesses: y)
    init(initialValue) {
      _x = initialValue
    }

    get { _x }
    set {}
  }

  var y: Int

  init(x: Int, y: Int) {
    self.x = x // expected-error {{variable 'self.y' used before being initialized}}
    self.y = y
  }
}

class TestInitWithGuard {
  var _a: Int
  var _b: Int

  var pair1: (Int, Int) {
    @storageRestrictions(initializes: _a, _b)
    init(initialValue) { // expected-error {{property '_b' not initialized by init accessor}}
      _a = initialValue.0

      if _a > 0 {
        return
      }

      _b = initialValue.1
    }

    get { (_a, _b) }
    set { }
  }

  var pair2: (Int, Int) {
    @storageRestrictions(initializes: _a, _b)
    init(initialValue) { // Ok
      _a = initialValue.0

      if _a > 0 {
        _b = 0
        return
      }

      _b = initialValue.1
    }

    get { (_a, _b) }
    set { }
  }

  init(a: Int, b: Int) {
    self.pair2 = (a, b)
  }
}

do {
  struct TestPropertyInitWithUnreachableBlocks {
    var _a: Int
    var a: Int? {
      @storageRestrictions(initializes: _a)
      init { _a = newValue ?? 0 } // Ok
      get { 42 }
    }
  }
}

do {
  class Base<T: Collection> {
    private var _v: T

    var data: T {
      @storageRestrictions(initializes: _v)
      init(initialValue) {
        _v = initialValue
      }

      get { _v }
    }

    init(data: T) {
      self.data = data
    }

    init(reinit: T) {
      self.data = reinit
      self.data = reinit // expected-error {{immutable value 'data' may only be initialized once}}
    }
  }

  class Sub<U> : Base<U> where U: Collection, U.Element == String {
    init(other: U) {
      super.init(data: other)
    }

    init(error: U) {
      super.init(data: error)
      data = error // expected-error {{immutable value 'data' may only be initialized once}}
    }
  }

  // Make sure that re-initialization is not allowed when there is no setter.
  struct TestPartialWithoutSetter {
    var _a: Int

    var a: Int {
      @storageRestrictions(initializes: _a)
      init(initialValue) {
        self._a = initialValue
      }

      get { _a }
    }

    var b: Int

    init(v: Int) {
      self.a = v
      self.a = v // expected-error {{immutable value 'a' may only be initialized once}}
      self.b = v
    }
  }
}
// CHECK: private:
// CHECK-NEXT:  SWIFT_INLINE_THUNK LargeStruct(swift::_impl::ValueWitnessTable * _Nonnull vwTable) noexcept : _storage(vwTable->size, vwTable->getAlignment()) {}
// CHECK-NEXT:  static SWIFT_INLINE_THUNK LargeStruct _make() noexcept {
// CHECK-NEXT:    auto metadata = _impl::$s7Structs11LargeStructVMa(0);
// CHECK-NEXT:    auto *vwTableAddr = reinterpret_cast<swift::_impl::ValueWitnessTable **>(metadata._0) - 1;
// CHECK-NEXT: #ifdef __arm64e__
// CHECK-NEXT:   auto *vwTable = reinterpret_cast<swift::_impl::ValueWitnessTable *>(ptrauth_auth_data(reinterpret_cast<void *>(*vwTableAddr), ptrauth_key_process_independent_data, ptrauth_blend_discriminator(vwTableAddr, 11839)));
// CHECK-NEXT: #else
// CHECK-NEXT:   auto *vwTable = *vwTableAddr;
// CHECK-NEXT: #endif
// CHECK-NEXT:    return LargeStruct(vwTable);
// CHECK-NEXT:  }
// CHECK-NEXT:  SWIFT_INLINE_THUNK const char * _Nonnull _getOpaquePointer() const noexcept { return _storage.getOpaquePointer(); }
// CHECK-NEXT:  SWIFT_INLINE_THUNK char * _Nonnull _getOpaquePointer() noexcept { return _storage.getOpaquePointer(); }
// CHECK-EMPTY:
// CHECK-NEXT:  swift::_impl::OpaqueStorage _storage;
// CHECK-NEXT:  friend class _impl::_impl_LargeStruct;
// CHECK-NEXT: #pragma clang diagnostic push
// CHECK-NEXT: #pragma clang diagnostic ignored "-Wc++17-extensions"
// CHECK-NEXT: #pragma clang diagnostic push
// CHECK-NEXT: #pragma clang diagnostic ignored "-Wreserved-identifier"
// CHECK-NEXT:  typedef char $s7Structs11LargeStructVD;
// CHECK-NEXT:  static inline constexpr $s7Structs11LargeStructVD __swift_mangled_name = 0;
// CHECK-NEXT: #pragma clang diagnostic pop
// CHECK-NEXT: #pragma clang diagnostic pop
// CHECK-NEXT: };

private class RefCountedClass {
    let x: Int

    init(x: Int) {
        self.x = x
        print("create RefCountedClass \(x)")
    }
    deinit {
        print("destroy RefCountedClass \(x)")
    }
}

public struct StructWithRefCountStoredProp {
    private let storedRef: RefCountedClass

    init(x: Int) {
        storedRef = RefCountedClass(x: x)
    }

    public func dump() {
        print("storedRef = \(storedRef.x)")
    }
}

// CHECK: SWIFT_INLINE_THUNK StructWithRefCountStoredProp(swift::_impl::ValueWitnessTable * _Nonnull vwTable) noexcept : _storage(vwTable->size, vwTable->getAlignment()) {}

public func createLargeStruct(_ x: Int) -> LargeStruct {
    return LargeStruct(x1: x, x2: -x, x3: x * 2, x4: x - 4, x5: 0, x6: 21)
}

public func printSmallAndLarge(_ x: FirstSmallStruct, _ y: LargeStruct) {
    x.dump()
    y.dump()
}

public func createStructWithRefCountStoredProp() -> StructWithRefCountStoredProp {
    return StructWithRefCountStoredProp(x: 0)
}

public func mutateSmall(_ x: inout FirstSmallStruct) {
#if CHANGE_LAYOUT
    let y = x.y
    x.y = x.x
    x.x = y
#else
    x.x += 1
#endif
}

// CHECK:      SWIFT_INLINE_THUNK LargeStruct createLargeStruct(swift::Int x) noexcept SWIFT_SYMBOL({{.*}}) SWIFT_WARN_UNUSED_RESULT {
// CHECK-NEXT:   return Structs::_impl::_impl_LargeStruct::returnNewValue([&](char * _Nonnull result) SWIFT_INLINE_THUNK_ATTRIBUTES {
// CHECK-NEXT:     Structs::_impl::$s7Structs17createLargeStructyAA0cD0VSiF(result, x);
// CHECK-NEXT:   });
// CHECK-NEXT: }

// CHECK:      SWIFT_INLINE_THUNK StructWithRefCountStoredProp createStructWithRefCountStoredProp() noexcept SWIFT_SYMBOL({{.*}}) SWIFT_WARN_UNUSED_RESULT {
// CHECK-NEXT:   return Structs::_impl::_impl_StructWithRefCountStoredProp::returnNewValue([&](char * _Nonnull result) SWIFT_INLINE_THUNK_ATTRIBUTES {
// CHECK-NEXT:     Structs::_impl::$s7Structs34createStructWithRefCountStoredPropAA0cdefgH0VyF(result);
// CHECK-NEXT:   });
// CHECK-NEXT: }

// CHECK:      SWIFT_INLINE_THUNK void mutateSmall(FirstSmallStruct& x) noexcept SWIFT_SYMBOL({{.*}}) {
// CHECK-NEXT:   Structs::_impl::$s7Structs11mutateSmallyyAA05FirstC6StructVzF(Structs::_impl::_impl_FirstSmallStruct::getOpaquePointer(x));
// CHECK-NEXT: }

// CHECK:      SWIFT_INLINE_THUNK void printSmallAndLarge(const FirstSmallStruct& x, const LargeStruct& y) noexcept SWIFT_SYMBOL({{.*}}) {
// CHECK-NEXT:   Structs::_impl::$s7Structs18printSmallAndLargeyyAA05FirstC6StructV_AA0eG0VtF(Structs::_impl::_impl_FirstSmallStruct::getOpaquePointer(x), Structs::_impl::_impl_LargeStruct::getOpaquePointer(y));
// CHECK-NEXT: }

// CHECK:      SWIFT_INLINE_THUNK uint32_t FirstSmallStruct::getX() const {
// CHECK-NEXT:   return Structs::_impl::$s7Structs16FirstSmallStructV1xs6UInt32Vvg(_getOpaquePointer());
// CHECK-NEXT: }
// CHECK:      SWIFT_INLINE_THUNK void FirstSmallStruct::setX(uint32_t value) {
// CHECK-NEXT:   Structs::_impl::$s7Structs16FirstSmallStructV1xs6UInt32Vvs(value, _getOpaquePointer());
// CHECK-NEXT: }
// CHECK-NEXT: SWIFT_INLINE_THUNK void FirstSmallStruct::dump() const {
// CHECK-NEXT:   Structs::_impl::$s7Structs16FirstSmallStructV4dumpyyF(_getOpaquePointer());
// CHECK-NEXT: }
// CHECK-NEXT: SWIFT_INLINE_THUNK void FirstSmallStruct::mutate() {
// CHECK-NEXT:   Structs::_impl::$s7Structs16FirstSmallStructV6mutateyyF(_getOpaquePointer());
// CHECK-NEXT: }

// CHECK:      SWIFT_INLINE_THUNK swift::Int LargeStruct::getX1() const {
// CHECK-NEXT: return Structs::_impl::$s7Structs11LargeStructV2x1Sivg(_getOpaquePointer());
// CHECK-NEXT: }
// CHECK-NEXT: SWIFT_INLINE_THUNK FirstSmallStruct LargeStruct::getFirstSmallStruct() const {
// CHECK-NEXT: return Structs::_impl::_impl_FirstSmallStruct::returnNewValue([&](char * _Nonnull result) SWIFT_INLINE_THUNK_ATTRIBUTES {
// CHECK-NEXT:   Structs::_impl::$s7Structs11LargeStructV010firstSmallC0AA05FirsteC0Vvg(result, _getOpaquePointer());
// CHECK-NEXT: });
// CHECK-NEXT: }
// CHECK-NEXT: SWIFT_INLINE_THUNK void LargeStruct::dump() const {
// CHECK-NEXT: Structs::_impl::$s7Structs11LargeStructV4dumpyyF(_getOpaquePointer());
// CHECK-NEXT: }

// CHECK:      SWIFT_INLINE_THUNK void StructWithRefCountStoredProp::dump() const {
// CHECK-NEXT:   Structs::_impl::$s7Structs28StructWithRefCountStoredPropV4dumpyyF(_getOpaquePointer());
// CHECK-NEXT: }

do {
  class Entity {
    var _age: Int
    var age: Int = 0 {
      @storageRestrictions(initializes: _age)
      init { _age = newValue }
      get { _age }
      set { _age = newValue }
    }
  }

  class Person : Entity {
    init(age: Int) {
      self.age = age // expected-error {{'self' used in property access 'age' before 'super.init' call}}
    }

    init(otherAge: Int) {
      super.init()
      self.age = otherAge // Ok
    }
  }
}

// Test that init accessor without "initializes" is required
do {
  struct Test {
    var a: Int {
      init {}
      get { 42 }
      set {}
    }
    var b: Int { // expected-note 2 {{'self' not initialized}}
      init {}
      get { 0 }
      set { }
    }

    init(a: Int) {
      self.a = a
    } // expected-error {{return from initializer without initializing all stored properties}}

    init(a: Int, b: Int) {
      if a == 0 {
        self.a = a
        self.b = b
      } else {
        self.a = 0
      }
    } // expected-error {{return from initializer without initializing all stored properties}}

    init() { // Ok
      self.a = 0
      self.b = 0
    }
  }

  struct TestWithStored {
    var _value: Int = 0

    var a: Int {
      @storageRestrictions(accesses: _value)
      init {}
      get { _value }
      set { _value = newValue }
    }
  }

  _ = TestWithStored(a: 42) // Ok
  _ = TestWithStored(_value: 1, a: 42) // Ok

  class TestWithStoredExplicit {
    var _value: Int = 0
    var _other: String = ""

    var a: Int { // expected-note 2 {{'self' not initialized}}
      @storageRestrictions(accesses: _value)
      init {}
      get { _value }
      set { _value = newValue }
    }

    init(data: Int) {
      self._value = data
    } // expected-error {{return from initializer without initializing all stored properties}}

    init() {} // expected-error {{return from initializer without initializing all stored properties}}

    init(a: Int) {
      self.a = a // Ok
    }
  }
}

struct Empty {}

final class Wrapper {
  var empty1 : Void?
  var empty2 : Void
  var empty3 : (Void, Void)
  var empty4 : Empty
  var empty5 : (Empty, Empty)
  var storage: Bool {
    @storageRestrictions(initializes: empty1, empty2, empty3, empty4, empty5)
    init(initialValue) { // expected-error {{property 'empty1' not initialized by init accessor}} // expected-error {{property 'empty4' not initialized by init accessor}} // expected-error {{property 'empty5.0' not initialized by init accessor}}

    }
    get {return true}
  }

  init() {
    empty1 = nil
    empty4 = Empty()
    empty5 = (Empty(), Empty())
  }
}
