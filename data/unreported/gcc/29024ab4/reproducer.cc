#define A8 1, 2, 3, 4, 5, 6, 7, 8
#define A64 A8, A8, A8, A8, A8, A8, A8, A8

struct T { unsigned char h[64]; short i; unsigned char j[64]; long long e; };
T b = { A64, 1, A64, 1 };

int main () { return b.e; }
