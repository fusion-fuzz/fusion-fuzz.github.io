// PR c++/122646
// { dg-additional-options "-fmodules -fconcepts" }
// { dg-module-cmi M }

export module M;

template <typename T>
struct zip_view_iterator {
  void operator-(int) {}
  friend void operator-(zip_view_iterator, zip_view_iterator)
    requires requires(T x) { x.begin() - x.begin(); }
  {}
};

struct ref_view {
  ref_view begin();
};

export template <typename X> void foo() {
  zip_view_iterator<ref_view>{} - X();
}

// A version of using-enum-10.C where Hog is a template.
// PR c++/103081
// PR c++/122646
// { dg-additional-options "-fmodules -fconcepts" }
// { dg-module-cmi M }



// { dg-do compile { target c++20 } }

enum class Pig { OINK }
;
template<int, typename _FflDeclT = ref_view>
struct Hog {
  using enum Pig;
  Hog(Pig) { OINK; }
}
;
template<int N>
void pen() {
  Hog<1>(Hog<1>::OINK);
  Hog<N>(Hog<N>::OINK);
}
template void pen<0>();

// PR c++/122646
// { dg-additional-options "-fmodules -fconcepts" }
// { dg-module-cmi M }
