template <unsigned Size> struct S : public CBdVfsImpl {
  double A[Size];
};
template <unsigned Size> struct SS {
  S<Size> A[Size];
void foo() { SS<-123> ss; }
}
