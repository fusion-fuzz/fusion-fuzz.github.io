constexpr auto b = [](this int) { return 1; };
constexpr int (*fp)(int) = b;
