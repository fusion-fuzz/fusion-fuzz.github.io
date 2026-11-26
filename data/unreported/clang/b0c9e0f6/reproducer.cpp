#include <stdlib.h>

int main(void) {
    unsigned char data1[] = {
        0x00,
        0x80, 0x80, 0x80, 0x08,
        0x80, 0x20,
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    };
    unsigned char data2[] = {
        0x00,
        0x02,
        0x80, 0x80, 0x80, 0x08,
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    };

    unsigned char *data[] = {data1, data2};
    int sizes[] = {sizeof(data1), sizeof(data2)};

    for (int i = 0; i < 2; ++i) {
        unsigned char *d = data[i];
        int len = sizes[i];
        int pos = 1;

        unsigned long long wacc = 0;
        while (1) {
            unsigned char b = d[pos++];
            wacc = (wacc << 7) | (b & 0x7F);
            if (!(b & 0x80)) break;
        }
        int width = (int)wacc;

        unsigned long long hacc = 0;
        while (1) {
            unsigned char b = d[pos++];
            hacc = (hacc << 7) | (b & 0x7F);
            if (!(b & 0x80)) break;
        }
        int height = (int)hacc;

        int size = width * height;
        unsigned char *buf = malloc(size);
        if (buf) {
            int payload_len = len - pos;
            unsigned char *dst = buf;
            unsigned char *src = d + pos;
            for (int j = 0; j < payload_len; ++j) {
                dst[j] = src[j];
            }
            free(buf);
        }
    }
    return 0;
}
// RUN: clang++ -c -std=c++23 %s
// EXPECT-CRASH-ASSERT: DiagnoseImmediateEscalatingReason
// EXPECT-CRASH-ASSERT: hasBody
// EXPECT-CRASH-ASSERT: expected

consteval int foo() {}

template <class T> constexpr int bar(T t);

auto a1 = &bar<char>;

template <class T> constexpr int bar(T t) {
  return foo();

  auto a2 = false > ;
