#include <coroutine>

struct future {
  ~future ();
  struct promise_type {
    future get_return_object () { return {}; }
    std::suspend_never initial_suspend () { return {}; }
    std::suspend_never final_suspend () noexcept { return {}; }
    void return_void () {}
    void unhandled_exception () {}
  };
  bool await_ready () { return false; }
  void await_suspend (std::coroutine_handle<>) {}
  int await_resume () { return 42; }
};

future failcase () {
  co_await ({ auto x = future{}; x; });
}
