export module M;
template <typename T> T t;
template <typename T> extern T *t<T *>;
template <typename T> T *t<T *> = nullptr;
