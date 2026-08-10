#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static int b64val(unsigned char c) {
    if (c >= 'A' && c <= 'Z') return c - 'A';
    if (c >= 'a' && c <= 'z') return c - 'a' + 26;
    if (c >= '0' && c <= '9') return c - '0' + 52;
    if (c == '+') return 62;
    if (c == '/') return 63;
    return -1;
}

static void decode_q(const unsigned char *in, size_t len, char *out, size_t *outlen) {
    size_t i = 0, o = 0;
    while (i < len) {
        unsigned char c = in[i++];
        if (c == '_') out[o++] = ' ';
        else if (c == '=' && i + 1 < len) {
            unsigned char h1 = in[i], h2 = in[i + 1];
            int v1 = (h1 >= '0' && h1 <= '9') ? h1 - '0' : (h1 >= 'A' && h1 <= 'F') ? h1 - 'A' + 10 : (h1 >= 'a' && h1 <= 'f') ? h1 - 'a' + 10 : -1;
            int v2 = (h2 >= '0' && h2 <= '9') ? h2 - '0' : (h2 >= 'A' && h2 <= 'F') ? h2 - 'A' + 10 : (h2 >= 'a' && h2 <= 'f') ? h2 - 'a' + 10 : -1;
            if (v1 >= 0 && v2 >= 0) {
                out[o++] = (char)((v1 << 4) | v2);
                i += 2;
            } else {
                out[o++] = '=';
            }
        } else {
            out[o++] = (char)c;
        }
    }
    out[o] = 0;
    *outlen = o;
}

static int decode_b(const unsigned char *in, size_t len, char *out, size_t *outlen) {
    int val = 0, bits = 0;
    size_t o = 0, i;
    for (i = 0; i < len; i++) {
        int v = b64val(in[i]);
        if (in[i] == '=') break;
        if (v < 0) return -1;
        val = (val << 6) | v;
        bits += 6;
        if (bits >= 8) {
            bits -= 8;
            out[o++] = (char)((val >> bits) & 0xFF);
        }
    }
    out[o] = 0;
    *outlen = o;
    return 0;
}

static void mime_decode(const char *s, int continue_on_error) {
    const char *p = strstr(s, "=?");
    if (!p) {
        puts(s);
        return;
    }
    const char *q = strstr(p + 2, "?");
    if (!q) {
        puts(s);
        return;
    }
    const char *r = strstr(q + 1, "?");
    if (!r) {
        puts(s);
        return;
    }
    const char *e = strstr(r + 1, "?=");
    if (!e) {
        puts(s);
        return;
    }

    char enc = q[1];
    const unsigned char *data = (const unsigned char *)(r + 1);
    size_t len = (size_t)(e - (r + 1));
    char decoded[256];
    size_t outlen = 0;
    int ok = 1;

    if (enc == 'B' || enc == 'b') {
        if (decode_b(data, len, decoded, &outlen) != 0) ok = 0;
    } else if (enc == 'Q' || enc == 'q') {
        decode_q(data, len, decoded, &outlen);
    } else {
        ok = 0;
    }

    if (!ok && !continue_on_error) {
        puts(s);
        return;
    }

    if (ok) {
        fwrite(s, 1, (size_t)(p - s), stdout);
        fwrite(decoded, 1, outlen, stdout);
        fputs(e + 2, stdout);
        putchar('\n');
    } else {
        puts(s);
    }
}

int main(void) {
    const char *tests[] = {
        "Legal encoded-word: =?utf-8?B?Kg==?= .",
        "Legal encoded-word: =?utf-8?Q?*?= .",
        "Illegal encoded-word: =?utf-8?B?\xA1?= .",
        "Illegal encoded-word: =?utf-8?Q?\xA1?= ."
    };

    for (int i = 0; i < 4; i++) mime_decode(tests[i], 1);
    for (int i = 0; i < 4; i++) mime_decode(tests[i], 0);
    return 0;
}