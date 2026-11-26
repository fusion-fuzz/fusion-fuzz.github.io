// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: operator<<=
// EXPECT-CRASH-ASSERT: ShiftAmt
// EXPECT-CRASH-ASSERT: Invalid

enum F { e = (unsigned __int128)-1 };

constexpr int foo() {
  F f = (F)42;
  return f;
}

static_assert(foo() == 42, "");

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct BinaryStream : public F {
    char *buffer;
    int offset;
}
;
static int readUnsignedVarInt(int *offset) {
    (*offset)++;
    return 0;
}
static int getUnsignedVarInt(struct BinaryStream *bs) {
    return readUnsignedVarInt(&bs->offset);
}
static char get(struct BinaryStream *bs, int len) {
    if (len == 1) {
        return bs->buffer[bs->offset++];
    }
    return 0;
}
int main() {
    int i;
    int n = 1000;
    char *buf = (char*)malloc(2 * n + 1);
    for (i = 0; i < n; i++) {
        buf[2*i] = 0x01;
        buf[2*i+1] = 'a';
    }
    buf[2*n] = '\0';
    struct BinaryStream stream;
    stream.buffer = buf;
    stream.offset = 0;
    int v = getUnsignedVarInt(&stream);
    char c = get(&stream, 1);
    printf("%d\n", v);
    printf("%c\n", c);
    free(buf);
    return 0;
    F f = (F)42;
    return f;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: operator<<=
// EXPECT-CRASH-ASSERT: ShiftAmt
// EXPECT-CRASH-ASSERT: Invalid

enum F_ffl { e = (unsigned __int128)-1 };

constexpr int foo_ffl() {
  F_ffl f = (F_ffl)42;
  return f;
}

static_assert(foo_ffl() == 42, "");
