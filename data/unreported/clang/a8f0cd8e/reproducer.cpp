#include <coroutine>
template <typename T> struct P {
  void f(Invalid);
};
struct awaiter : P<int> {
  ~awaiter();
  bool await_ready() noexcept;
  void await_suspend(std::coroutine_handle<>) noexcept;
  void await_resume() noexcept;
};
struct task {
  struct promise_type {
    task get_return_object();
    awaiter initial_suspend() noexcept;
    awaiter final_suspend() noexcept;
    void return_void();
    void unhandled_exception();
  };
};
task foo() { co_return; }
