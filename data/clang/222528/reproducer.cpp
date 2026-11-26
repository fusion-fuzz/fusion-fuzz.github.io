@class incompatible;
static incompatible *g;
void integer(incompatible *o) {
  __sync_bool_compare_and_swap(&g, 0, o);
}
