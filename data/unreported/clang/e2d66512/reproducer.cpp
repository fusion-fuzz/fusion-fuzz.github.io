class U {
  int b;
};

class T {
  U u;
};

static long ffl_fusion = (long)(u);

// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-NOASSERT

template <typename T, typename U>
concept Bar = false;

void ffl_fusion() { Baz auto [a]; }
