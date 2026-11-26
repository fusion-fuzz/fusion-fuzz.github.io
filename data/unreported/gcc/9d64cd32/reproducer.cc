#include <meta>
using namespace std::meta;
consteval bool foo () {
  data_member_options a = { .name = "_", .annotations = { ^^a } };
  auto d = data_member_spec (^^int, a);
  return d == data_member_spec (^^int, { .name = "_", .annotations = { reflect_constant (1) } });
}
static_assert (foo ());
