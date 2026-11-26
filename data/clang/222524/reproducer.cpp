typedef void (^DeferBlock)(void);
struct ExportMembers {
  struct Nested;
}
struct ExportMembers::Nested {
}
  DeferBlock x __attribute__((cleanup(cleanup))) = ^{};
