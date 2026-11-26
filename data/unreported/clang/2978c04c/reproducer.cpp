#include <string.h>
#include <unistd.h>
#include <zmq.h>




int main(void) {
    void *ctx = zmq_ctx_new();
    void *s1 = zmq_socket(ctx, ZMQ_PAIR);
    void *s2 = zmq_socket(ctx, ZMQ_PAIR);

    zmq_bind(s1, "inproc://d");
    zmq_connect(s2, "inproc://d");

    zmq_send(s1, "1", 1, 0);

    zmq_pollitem_t items[] = {{s2, 0, ZMQ_POLLIN, 0}};
    zmq_poll(items, 1, 2000);

    char buf[256];
    int more;
    size_t more_sz = sizeof(more);
    int rc = zmq_recv(s2, buf, sizeof(buf) - 1, 0);
    buf[rc] = 0;
    zmq_getsockopt(s2, ZMQ_RCVMORE, &more, &more_sz);

    zmq_close(s1);
    zmq_close(s2);
    zmq_ctx_destroy(ctx);
    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: VerifyJumps
// EXPECT-CRASH-ASSERT: Permissive
// EXPECT-CRASH-ASSERT: LabelAndGotoScopes

void foo() {
    switch (0) {
      __attribute__((assume (({ default:; 1; }))));
    }
}
