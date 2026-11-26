#include <stdio.h>
#include <stdlib.h>
#include <string.h>




typedef struct {
    float volume;
    int playing;
    FILE *file;
    char *buffer;
    size_t bufsize;
} SoundStream;

typedef struct {
    int initialized;
} AudioEngine;

AudioEngine *AudioEngine_CreateDefault(void) {
    AudioEngine *e = malloc(sizeof(AudioEngine));
    e->initialized = 1;
    return e;
}

void AudioEngine_Destroy(AudioEngine *e) {
    free(e);
}

SoundStream *SoundStream_Create(FILE *f, AudioEngine *engine) {
    SoundStream *s = malloc(sizeof(SoundStream));
    s->volume = 1.0f;
    s->playing = 0;
    s->file = f;
    s->bufsize = 4096;
    s->buffer = malloc(s->bufsize);
    return s;
}

void SoundStream_Play(SoundStream *s) {
    if (s && s->file) {
        s->playing = 1;
        fread(s->buffer, 1, s->bufsize, s->file);
    }
}

void SoundStream_Dispose(SoundStream *s) {
    if (s) {
        if (s->file) fclose(s->file);
        free(s->buffer);
        free(s);
    }
}

int main(void) {
    AudioEngine *engine = AudioEngine_CreateDefault();
    FILE *mp3 = fopen("test.mp3", "rb");
    if (!mp3) return 0;

    SoundStream *stream = SoundStream_Create(mp3, engine);
    SoundStream_Play(stream);
    SoundStream_Dispose(stream);

    mp3 = fopen("test.mp3", "rb");
    if (!mp3) { AudioEngine_Destroy(engine); return 0; }

    stream = SoundStream_Create(mp3, engine);
    stream->volume = 1.0f;
    SoundStream_Dispose(stream);
    AudioEngine_Destroy(engine);
    return 0;
}
// RUN: clang++ -c -std=c++2b %s
// EXPECT-CRASH-ASSERT: DiagnoseBadDeduction
// EXPECT-CRASH-ASSERT: ParamD
// EXPECT-CRASH-ASSERT: invalid

struct S {
  template <class... args> static void f() {};
  template <class... args> void f(this S *, ...) {};
};

void g() { S::f(0); }
