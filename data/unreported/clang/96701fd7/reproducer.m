void takeBlock(void (^)(void));
void val(void) {
  __autoreleasing id p;
  takeBlock(^{ (void) p; });
}
