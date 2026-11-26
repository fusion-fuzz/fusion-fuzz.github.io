import Foundation

// --- Seed A ---

var s = "struct Foo { func foo() {} }"
while true {
    do {
        let _ = try NSRegularExpression(pattern: s)
    } catch {
        break
    }
    s = s.replacingOccurrences(of: "foo() {}", with: "foo() { \(s) }")
}

// RUN: %target-swift-emit-silgen -Xllvm -sil-print-types -module-name switch_isa %s | %FileCheck %s

func markUsed<T>(_ t: T) {}

// rdar://17772217
func testSwitchOnExistential(_ value: Any) {
  switch value {
    case true as Bool: markUsed("true")
    case false as Bool: markUsed("false")
    default: markUsed("default")
  }
}

// CHECK-LABEL: sil hidden [ossa] @$s10switch_isa23testSwitchOnExistentialyyypF :
// CHECK:   [[ANY:%.*]] = alloc_stack $Any
// CHECK:   copy_addr %0 to [init] [[ANY]]
// CHECK:   [[BOOL:%.*]] = alloc_stack $Bool
// CHECK:   checked_cast_addr_br copy_on_success Any in [[ANY]] : $*Any to Bool in [[BOOL]] : $*Bool, [[IS_BOOL:bb[0-9]+]], [[IS_NOT_BOOL:bb[0-9]+]]
// CHECK: [[IS_BOOL]]:
// CHECK:   [[T0:%.*]] = load [trivial] [[BOOL]]

enum Foo {
  case A
}
enum Bar<T> {
  case B(T)
}
func testSwitchEnumOnExistential(_ value: Any) {
  switch value {
  case Foo.A:
    ()
  case Bar<Int>.B(let i):
    ()
  case Bar<Foo>.B(let f):
    ()
  default:
    ()
  }
}

// CHECK-LABEL: sil hidden [ossa] @$s10switch_isa27testSwitchEnumOnExistentialyyypF : $@convention(thin) (@in_guaranteed Any) -> ()
// CHECK:   checked_cast_addr_br copy_on_success Any in {{%.*}} : $*Any to Foo
// CHECK:   checked_cast_addr_br copy_on_success Any in {{%.*}} : $*Any to Bar<Int>
// CHECK:   checked_cast_addr_br copy_on_success Any in {{%.*}} : $*Any to Bar<Foo>

class B {}
class D: B {}

func guardFn(_ l: D, _ r: D) -> Bool { return true }

// rdar://problem/21087371
// CHECK-LABEL: sil hidden [ossa] @$s10switch_isa32testSwitchTwoIsPatternsWithGuard_1ryAA1BC_AEtF
// CHECK: bb0([[ARG0:%.*]] : @guaranteed $B, [[ARG1:%.*]] : @guaranteed $B):
// CHECK:       [[ARG0_COPY:%.*]] = copy_value [[ARG0]]
// CHECK:       [[ARG1_COPY:%.*]] = copy_value [[ARG1]]
// CHECK:       [[TUP:%.*]] = tuple ([[ARG0_COPY:%.*]] : $B, [[ARG1_COPY:%.*]] : $B)
// CHECK:       [[BORROWED_TUP:%.*]] = begin_borrow [[TUP]]
// CHECK:       ([[TUP_1:%.*]], [[TUP_2:%.*]]) = destructure_tuple [[BORROWED_TUP]]
// CHECK:       checked_cast_br B in [[TUP_1]] : $B to D, [[R_CAST_YES:bb[0-9]+]], [[R_CAST_NO:bb[0-9]+]]
//
// CHECK:       [[R_CAST_YES]]([[R:%.*]] : @guaranteed $D):
// CHECK:         [[R2:%.*]] = copy_value [[R]]
// CHECK:         checked_cast_br B in [[TUP_2]] : $B to D, [[L_CAST_YES:bb[0-9]+]], [[L_CAST_NO:bb[0-9]+]]
//
// CHECK:       [[L_CAST_YES]]([[L:%.*]] : @guaranteed $D):
// CHECK:         [[L2:%.*]] = copy_value [[L]]
// CHECK:         [[MOVED_R2:%.*]] = move_value [lexical] [var_decl] [[R2]]
// CHECK:         [[MOVED_L2:%.*]] = move_value [lexical] [var_decl] [[L2]]
// CHECK:         function_ref @$s10switch_isa7guardFnySbAA1DC_ADtF
// CHECK:         cond_br {{%.*}}, [[GUARD_YES:bb[0-9]+]], [[GUARD_NO:bb[0-9]+]]
//
// CHECK:       [[GUARD_YES]]:
// CHECK-NEXT:    debug_value [[MOVED_R2]]
// CHECK-NEXT:    debug_value [[MOVED_L2]]
// CHECK-NEXT:    destroy_value [[MOVED_L2]]
// CHECK-NEXT:    destroy_value [[MOVED_R2]]
// CHECK-NEXT:    end_borrow [[BORROWED_TUP]]
// CHECK-NEXT:    destroy_value [[TUP]]
// CHECK-NEXT:    br [[EXIT:bb[0-9]+]]
//
// CHECK:       [[GUARD_NO]]:
// CHECK-NEXT:    destroy_value [[MOVED_L2]]
// CHECK-NEXT:    destroy_value [[MOVED_R2]]
// CHECK-NEXT:    end_borrow [[BORROWED_TUP]]
// CHECK-NEXT:    br [[CONT:bb[0-9]+]]
//
// CHECK:       [[L_CAST_NO]]([[LFAIL:%.*]] : @guaranteed $B):
// CHECK-NEXT:    destroy_value [[R2]]
// CHECK-NEXT:    end_borrow [[BORROWED_TUP]]
// CHECK-NEXT:    br [[CONT]]
//
// CHECK:       [[CONT]]:
// CHECK-NEXT:    destroy_value [[TUP]]
// CHECK-NEXT:    br [[EXIT]]
func testSwitchTwoIsPatternsWithGuard(_ l: B, r: B) {
  switch (l, r) {
  case (let l2 as D, let r2 as D) where guardFn(l2, r2):
    break
  default:
    break
  }
}
// --- Seed B ---

// RUN: %target-swift-emit-silgen -Xllvm -sil-print-types -module-name switch_isa %s | %FileCheck %s

func markUsed_b1e0630<T>(_ t: T) {}

// rdar://17772217
func testSwitchOnExistential_b1e0630(_ value: Any) {
  switch value {
    case true as Bool: markUsed_b1e0630("true")
    case false as Bool: markUsed_b1e0630("false")
    default: markUsed_b1e0630("default")
  }
}

// CHECK-LABEL: sil hidden [ossa] @$s10switch_isa23testSwitchOnExistentialyyypF :
// CHECK:   [[ANY:%.*]] = alloc_stack $Any
// CHECK:   copy_addr %0 to [init] [[ANY]]
// CHECK:   [[BOOL:%.*]] = alloc_stack $Bool
// CHECK:   checked_cast_addr_br copy_on_success Any in [[ANY]] : $*Any to Bool in [[BOOL]] : $*Bool, [[IS_BOOL:bb[0-9]+]], [[IS_NOT_BOOL:bb[0-9]+]]
// CHECK: [[IS_BOOL]]:
// CHECK:   [[T0:%.*]] = load [trivial] [[BOOL]]

enum Foo_b1e0630 {
  case A
}
enum Bar_b1e0630<T> {
  case B_b1e0630(T)
}
func testSwitchEnumOnExistential_b1e0630(_ value: Any) {
  switch value {
  case Foo_b1e0630.A:
    ()
  case Bar_b1e0630<Int>.B_b1e0630(let i):
    ()
  case Bar_b1e0630<_>.B_b1e0630(let f):
    ()
  default:
    ()
  }
}

// CHECK-LABEL: sil hidden [ossa] @$s10switch_isa27testSwitchEnumOnExistentialyyypF : $@convention(thin) (@in_guaranteed Any) -> ()
// CHECK:   checked_cast_addr_br copy_on_success Any in {{%.*}} : $*Any to Foo_b1e0630
// CHECK:   checked_cast_addr_br copy_on_success Any in {{%.*}} : $*Any to Bar_b1e0630<Int>
// CHECK:   checked_cast_addr_br copy_on_success Any in {{%.*}} : $*Any to Bar_b1e0630<Foo_b1e0630>

class B_b1e0630 {}
class D_b1e0630: B_b1e0630 {}

func guardFn_b1e0630(_ l: D_b1e0630, _ r: D_b1e0630) -> Bool { return true }

// rdar://problem/21087371
// CHECK-LABEL: sil hidden [ossa] @$s10switch_isa32testSwitchTwoIsPatternsWithGuard_1ryAA1BC_AEtF
// CHECK: bb0([[ARG0:%.*]] : @guaranteed $B_b1e0630, [[ARG1:%.*]] : @guaranteed $B_b1e0630):
// CHECK:       [[ARG0_COPY:%.*]] = copy_value [[ARG0]]
// CHECK:       [[ARG1_COPY:%.*]] = copy_value [[ARG1]]
// CHECK:       [[TUP:%.*]] = tuple ([[ARG0_COPY:%.*]] : $B_b1e0630, [[ARG1_COPY:%.*]] : $B_b1e0630)
// CHECK:       [[BORROWED_TUP:%.*]] = begin_borrow [[TUP]]
// CHECK:       ([[TUP_1:%.*]], [[TUP_2:%.*]]) = destructure_tuple [[BORROWED_TUP]]
// CHECK:       checked_cast_br B_b1e0630 in [[TUP_1]] : $B_b1e0630 to D_b1e0630, [[R_CAST_YES:bb[0-9]+]], [[R_CAST_NO:bb[0-9]+]]
//
// CHECK:       [[R_CAST_YES]]([[R:%.*]] : @guaranteed $D_b1e0630):
// CHECK:         [[R2:%.*]] = copy_value [[R]]
// CHECK:         checked_cast_br B_b1e0630 in [[TUP_2]] : $B_b1e0630 to D_b1e0630, [[L_CAST_YES:bb[0-9]+]], [[L_CAST_NO:bb[0-9]+]]
//
// CHECK:       [[L_CAST_YES]]([[L:%.*]] : @guaranteed $D_b1e0630):
// CHECK:         [[L2:%.*]] = copy_value [[L]]
// CHECK:         [[MOVED_R2:%.*]] = move_value [lexical] [var_decl] [[R2]]
// CHECK:         [[MOVED_L2:%.*]] = move_value [lexical] [var_decl] [[L2]]
// CHECK:         function_ref @$s10switch_isa7guardFnySbAA1DC_ADtF
// CHECK:         cond_br {{%.*}}, [[GUARD_YES:bb[0-9]+]], [[GUARD_NO:bb[0-9]+]]
//
// CHECK:       [[GUARD_YES]]:
// CHECK-NEXT:    debug_value [[MOVED_R2]]
// CHECK-NEXT:    debug_value [[MOVED_L2]]
// CHECK-NEXT:    destroy_value [[MOVED_L2]]
// CHECK-NEXT:    destroy_value [[MOVED_R2]]
// CHECK-NEXT:    end_borrow [[BORROWED_TUP]]
// CHECK-NEXT:    destroy_value [[TUP]]
// CHECK-NEXT:    br [[EXIT:bb[0-9]+]]
//
// CHECK:       [[GUARD_NO]]:
// CHECK-NEXT:    destroy_value [[MOVED_L2]]
// CHECK-NEXT:    destroy_value [[MOVED_R2]]
// CHECK-NEXT:    end_borrow [[BORROWED_TUP]]
// CHECK-NEXT:    br [[CONT:bb[0-9]+]]
//
// CHECK:       [[L_CAST_NO]]([[LFAIL:%.*]] : @guaranteed $B_b1e0630):
// CHECK-NEXT:    destroy_value [[R2]]
// CHECK-NEXT:    end_borrow [[BORROWED_TUP]]
// CHECK-NEXT:    br [[CONT]]
//
// CHECK:       [[CONT]]:
// CHECK-NEXT:    destroy_value [[TUP]]
// CHECK-NEXT:    br [[EXIT]]
func testSwitchTwoIsPatternsWithGuard_b1e0630(_ l: B_b1e0630, r: B_b1e0630) {
  switch (l, r) {
  case (let l2 as D_b1e0630, let r2 as D_b1e0630) where guardFn_b1e0630(l2, r2):
    break
  default:
    break
  }
}
// --- Bug Primitive ---

// P4: Closure capture / @escaping / ownership stress
func _ffl_p4_apply<T>(_ f: () -> T) -> T { f() }
func _ffl_p4_escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var _ffl_cap = _
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
    _ffl_cap = _
    _ = _ffl_esc()
}
