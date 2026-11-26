
void walk(int *arr, int len, void (*f)(int)) {
    for (int i = 0; i < len; i++) f(arr[i]);
}

void noop(int x) {}

int main() {
    int x = 0;
    walk(&x, 10, noop);
    return 0;
    __real__ val = r;
    __imag__ val = i;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ClassifyImpl
// EXPECT-CRASH-ASSERT: isLValue 

template <typename _Tp> class complex;

template <> class complex<double> {
private:
  double val;
};

complex<double>::complex(double r, double i) {
  __real__ val = r;
  __imag__ val = i;
}
