#include <stdlib.h>
#include <string.h>



int main() {
    int w1 = 13, h1 = 1007;
    int *img1 = malloc(w1 * h1 * sizeof(*img1));
    if (!img1) return 1;
    int antialias = 1;
    int x0 = 0, y0 = 0, x1 = 1073745919, y1 = 1073745919, color = 4096;
    int dx = x1 - x0;
    int dy = y1 - y0;
    unsigned u = 2u * (unsigned)dy - (unsigned)dx;
    (void)u;
    free(img1);
    int w2 = 100, h2 = 100;
    int *img2 = malloc(w2 * h2 * sizeof(*img2));
    #pragma pack(pop, 16)
    #pragma pack(pop)
    if (!img2) return 1;
    antialias = 1;
    x0 = 1094795585; y0 = 0; x1 = 2147483647; y1 = 255; color = 0xff;
    dx = x1 - x0;
    dy = y1 - y0;
    u = 2u * (unsigned)dy - (unsigned)dx;
    (void)u;
    free(img2);
    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ActOnPragmaPack
// EXPECT-CRASH-ASSERT: getAlignMode
// EXPECT-CRASH-ASSERT: Empty

#pragma options align = natural
#pragma pack(pop, 16)
#pragma pack(pop)
