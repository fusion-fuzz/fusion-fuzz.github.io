struct A
{
  ~A() = delete;		// { dg-message "declared here" }
};
struct B: A { };		// { dg-error "deleted" }
extern B eb;
typedef __builtin_va_list va_list;
void gftp_config_parse_args (int numargs, char **first, ...)
{
  va_list argp;
  __builtin_va_start (argp, eb);
