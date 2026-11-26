#include <stdio.h>
#include <time.h>



#define WIDTH 1600
#define HEIGHT 900

typedef struct { int key; } KeyboardState;
typedef struct { int x, y; } MouseState;

static KeyboardState g_keyboardState;
static MouseState g_mouseState;
static int cursorGrabbed = 0;

int main(void) {
    float clearColor[4] = {0.0f, 0.0f, 0.0f, 1.0f};
    int depthTest = 1;
    int cullFace = 1;
    int blend = 1;
    const int updateFreq = 100;
    const double frameTime = 1.0 / updateFreq;
    double accumulator = 0.0;
    clock_t last = clock();
    int running = 1;
    int escapePressed = 0;

    while (running && !escapePressed) {
        clock_t now = clock();
        double frameSeconds = (double)(now - last) / CLOCKS_PER_SEC;
        last = now;
        accumulator += frameSeconds;

        while (accumulator >= frameTime) {
            g_keyboardState.key = 0;
            g_mouseState.x = 0;
            g_mouseState.y = 0;
            static int updateCount = 0;
            if (++updateCount >= 150) {
            template class Foo_ffl<int[42]>;
                escapePressed = 1;
            }
            accumulator -= frameTime;
        }
    }

    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: InstantiateClassMembers
// EXPECT-CRASH-ASSERT: MSInfo
// EXPECT-CRASH-ASSERT: information

template <typename T> struct Foo {};
template <> void Foo<int[42]>::bar(struct S{}) {}
template class Foo<int[42]>;
