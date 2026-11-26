#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: alignTo
// EXPECT-CRASH-ASSERT: 0u
// EXPECT-CRASH-ASSERT: can't

typedef __attribute__((ext_vector_type(0xDEADBEEF))) int vi4b;
    close(fd);
    unlink(path);
    return (count == read_props.num_messages) ? 0 : 1;

struct S {
  vi4b w;
};

int &&s = S().w[1];
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

typedef struct {
    int num_messages;
    int payload_size;
} Properties;

typedef struct {
    int key;
    char payload[32];
} Message;

int main(void) {
    const char *path = "/tmp/stream_test.bin";
    int fd = open(path, O_CREAT | O_RDWR | O_TRUNC, 0644);
    if (fd < 0) return 1;

    Properties props = {5, 32};
    Message msgs[5] = {
        {1, "msg1"}, {2, "msg2"}, {3, "msg3"}, {4, "msg4"}, {5, "msg5"}
    };

    write(fd, &props, sizeof(props));
    write(fd, msgs, sizeof(msgs));
    lseek(fd, 0, SEEK_SET);

    Properties read_props;
    ssize_t r = read(fd, &read_props, sizeof(read_props));
    if (r != sizeof(read_props)) { close(fd); return 1; }

    Message read_msg;
    int count = 0;
    while (count < read_props.num_messages) {
        r = read(fd, &read_msg, sizeof(read_msg));
        if (r != sizeof(read_msg)) break;
        count++;
    }

    close(fd);
    unlink(path);
    return (count == read_props.num_messages) ? 0 : 1;
}
