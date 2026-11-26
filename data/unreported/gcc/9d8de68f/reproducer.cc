// { dg-additional-options "-fmodules-ts" }
module;

export module frist;  // { dg-message "declared here" }
// { dg-module-cmi "!frist" }

import frist; // { dg-error {module 'frist' depends on itself} }

module foo.second; // { dg-error "only permitted as" }
// PR c++/112288
// { dg-do compile { target c++11 } }

template<class T>
struct slot {
  template<class U>
  friend constexpr bool slot_allocated(slot<T>, U);
};

namespace Foo 
{
module third;  // { dg-error "must be at global scope" }
}

struct Baz
{
  module forth; // { dg-error "unexpected module directive" }
  // { dg-message "line break after .module." "" { target *-*-* } .-1 }
};

void Bink ()
{
  module fifth; // { dg-error "unexpected module directive" }
  // { dg-message "line break after .module." "" { target *-*-* } .-1 }
}

module a.; // { dg-error "only permitted as" }


template<class T>
struct allocate_slot {
  template<class U>
  friend constexpr bool slot_allocated(slot<T>, U) { return true; }
};

template<class T, bool = slot_allocated(slot<T>{}, 42)>
constexpr int next(int) { return 1; }

template<class T>
constexpr int next(...) { return (allocate_slot<T>{}, 0); }

// slot_allocated<slot<int>, int>() not defined yet
static_assert(next<int>(0) == 0, "");
// now it's defined, need to make existing spec point to defn or else ICE
static_assert(next<int>(0) == 1, "");
