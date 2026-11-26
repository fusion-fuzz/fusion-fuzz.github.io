void *operator new (decltype (sizeof 0), void *) noexcept;
void f () { new ((void *) "1") long long; }
