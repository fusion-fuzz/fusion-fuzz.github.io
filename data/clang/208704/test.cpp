//--- k.h
namespace base {
namespace internal {
struct LiteralTag ;
}  
}
//--- d.cppmap
module "//d" {
}
//--- b.cppmap
module "//b" {
    header "b.h"
}
//--- e.cppmap
module "//e" {
}
//--- c.cppmap
module "//c" {
}
//--- f.cppmap
module "//f" {
}
//--- i.cppmap
module "//i" {
}
//--- g.cppmap
module "//g" {
}
//--- h.cppmap
module "//h" {
}
//--- k.cppmap
module "//k" {
    header "k.h"
}
//--- l.cppmap
module "//l" {
}
//--- m.cppmap
module "//m" {
}
//--- j.cppmap
module "//j" {
}
//--- o.cppmap
module "//o" {
}
//--- b.h
namespace base {}
//--- n.cppmap
module "//n" {
    header "n.h"
}
//--- n.h
namespace _View {}
// RUN: rm -rf %t
// RUN: mkdir %t
// RUN: split-file %s %t
// RUN: cd %t
//
// RUN: %clang -fmodule-name=//b -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -c b.cppmap -o b.pic.pcm
// RUN: %clang -fmodule-name=//c -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=b.pic.pcm -c c.cppmap -o c.pic.pcm
// RUN: %clang -fmodule-name=//d -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=c.pic.pcm -c d.cppmap -o d.pic.pcm
// RUN: %clang -fmodule-name=//e -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=d.pic.pcm -c e.cppmap -o e.pic.pcm
// RUN: %clang -fmodule-name=//f -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=e.pic.pcm -c f.cppmap -o f.pic.pcm
// RUN: %clang -fmodule-name=//g -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=f.pic.pcm -c g.cppmap -o g.pic.pcm
// RUN: %clang -fmodule-name=//h -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=g.pic.pcm -c h.cppmap -o h.pic.pcm
// RUN: %clang -fmodule-name=//i -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=h.pic.pcm -c i.cppmap -o i.pic.pcm
// RUN: %clang -fmodule-name=//j -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=i.pic.pcm -c j.cppmap -o j.pic.pcm
// RUN: %clang -fmodule-name=//k -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -c k.cppmap -o k.pic.pcm
// RUN: %clang -fmodule-name=//l -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=j.pic.pcm -c l.cppmap -o l.pic.pcm
// RUN: %clang -fmodule-name=//m -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=k.pic.pcm -c m.cppmap -o m.pic.pcm
// RUN: %clang -fmodule-name=//n -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=l.pic.pcm -Xclang=-fmodule-file=m.pic.pcm -c n.cppmap -o n.pic.pcm
// RUN: %clang -fmodule-name=//o -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=n.pic.pcm -c o.cppmap -o o.pic.pcm
// RUN: %clang -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=o.pic.pcm -c a.cc -o a.o

//--- a.cc
#include "k.h"
namespace base {
namespace internal {}  
}
#define REGISTER_MODULE_INITIALIZER(name, body) REGISTER_INITIALIZER(, , )
class FooInitializer ;
REGISTER_MODULE_INITIALIZER(, );
// RUN: %clang_cc1 -std=c++2c -fexperimental-new-constant-interpreter -verify=expected,both %s
// RUN: %clang_cc1 -std=c++2c  -verify=ref,both %s

// both-no-diagnostics

namespace std {
inline namespace {
template <bool, class _IfRes, class> using conditional_t = _IfRes;
template <class _Ip>
concept input_iterator = requires { typename _Ip; };
auto end = int{};
namespace ranges {
template <class>
concept range = requires { end; };
template <class _Tp>
concept input_range = input_iterator<_Tp>;
template <class>
concept forward_range = false;
template <range _Rp> struct owning_view {
  _Rp __r_;
};
} // namespace ranges
template <int _Size> struct array {
  int __elems_[_Size];
};
template <class> struct allocator {
  constexpr array<2> *allocate(decltype(sizeof(int))) {
    return static_cast<array<2> *>(operator new(sizeof(array<2>)));
  }
};
namespace ranges {
template <input_range _View, forward_range _Pattern> struct join_with_view {
  join_with_view(_View, _Pattern);
};
} // namespace ranges
template <class> struct vector {
  constexpr ~vector() {
    (__end_ - 1)->~array<2>();
  }
  constexpr vector() {
    __end_ = __alloc_.allocate(0);
    _ConstructTransaction __tx(*this);
    ++__tx.__pos_;
  }
  array<2>* __end_;
  allocator<array<2>> __alloc_;
  struct _ConstructTransaction {
    constexpr _ConstructTransaction(vector &__v)
        : __v_(__v), __pos_(__v.__end_) {}
    constexpr ~_ConstructTransaction() { __v_.__end_ = __pos_; }
    vector __v_;
    array<2>* __pos_;
  };
};
} // namespace
}
// namespace std
template <bool RefIsGlvalue, class Inner>
using VRange = std::conditional_t<RefIsGlvalue, std::vector<Inner>, Inner>;
#define REGISTER_INITIALIZER(type, name, body)              void foo_init__() ;   FooInitializer initializer_name( base::internal::LiteralTag\
      foo_init__)
template <int RefIsGlvalue> void test_pre_increment() {
  using V = VRange<RefIsGlvalue, std::array<2>>;
  using Pattern = std::array<2>;
  using JWV = std::ranges::join_with_view<std::ranges::owning_view<V>,
                                          std::ranges::owning_view<Pattern>>;
  JWV jwv({}, {});
}