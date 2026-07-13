// RUN: %clang_cc1 -x c++ -std=c++11 -fblocks -emit-llvm %s -o - | FileCheck %s

// CHECK: %struct.__block_byref_baz = type { ptr, ptr, i32, i32, i32 }
// CHECK: [[baz:%[0-9a-z_]*]] = alloca %struct.__block_byref_baz
// CHECK: [[bazref:%[0-9a-z_\.]*]] = getelementptr inbounds nuw %struct.__block_byref_baz, ptr [[baz]], i32 0, i32 1
// CHECK: store ptr [[baz]], ptr [[bazref]]
// CHECK: call void @_Block_object_dispose(ptr [[baz]]

int main() {
  __block int baz = [&]() { return 0; }();
  ^{ (void)baz; };
  return 0;
}
// variable template specialization

template <typename T>
struct Wrapper {
  template <typename U> static constexpr baz my_const = U(1);
   // Variable template partial specialization with member variable.
  template <typename U> static constexpr U *my_const<const U *> = (U *)(0);
}
template <typename T>
constexpr T my_pi = T(3.1415926535897932385L);
// variable template

template <> constexpr char my_pi<char> = '3';
template <> template <>
constexpr const char *Wrapper<float>::my_const<const char *> = a;
constexpr char a[] = "hello";
;