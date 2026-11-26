
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: operator[]
// EXPECT-CRASH-ASSERT: size
// EXPECT-CRASH-ASSERT: Out-of-bounds

template <class, class> struct S {};
struct t_1 {
template <class T_ffl, class U_ffl> struct O_ffl {
  template <class V_ffl> using T2 = S_ffl<O_ffl, T_ffl>;
  template <class V_ffl> struct I_ffl {
    I_ffl(ffl_fusion, V_ffl v, T2<V_ffl> t2) {}
  };
}
;
S_ffl<int, char> s;
O_ffl<char, int>::I _1(t1, 42, s);
} t1;

template <class T, class U> struct O {
  template <class V> using T2 = S<O, T>;
  template <class V> struct I {
    I(t_1, V v, T2<V> t2) {}
  };
};

S<int, char> s;
O<char, int>::I _1(t1, 42, s);
