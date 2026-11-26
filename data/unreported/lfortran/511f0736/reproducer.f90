program test
  implicit none
  integer, parameter :: ONE = 1
  integer, parameter :: TWO = 1
  character(len=3) :: cls_mapWithConst(2)
  character(len=3) :: cls_mapWithConst1(2)
  character(len=3) :: cls_mapWithConst2(2)
  character(len=3) :: cls_mapWithoutConst(2)
  character(len=3) :: g_mapWithConst(2)
  character(len=3) :: g_mapWithoutConst(2)
  character(len=3) :: g_mapWithoutConst0(2)
  character(len=3) :: g_mapWithoutConst1(2)
  character(len=3) :: g_mapWithoutConst2(2)
  character(len=3) :: g_mapWithoutConst3(2)

  cls_mapWithConst = ''
  cls_mapWithConst1 = ''
  cls_mapWithConst2 = ''
  cls_mapWithoutConst = ''
  g_mapWithConst = ''
  g_mapWithoutConst = ''
  g_mapWithoutConst0 = ''
  g_mapWithoutConst1 = ''
  g_mapWithoutConst2 = ''
  g_mapWithoutConst3 = ''

  cls_mapWithConst(ONE) = 'one'
  cls_mapWithConst(TWO) = 'two'

  cls_mapWithConst1(1) = 'one'
  cls_mapWithConst1(TWO) = 'two'

  cls_mapWithConst2(ONE) = 'one'
  cls_mapWithConst2(1) = 'two'

  cls_mapWithoutConst(ONE) = 'one'
  cls_mapWithoutConst(TWO) = 'two'

  g_mapWithConst(1) = 'one'
  g_mapWithConst(1) = 'two'

  g_mapWithoutConst(ONE) = 'one'
  g_mapWithoutConst(TWO) = 'two'

  g_mapWithoutConst0(1) = 'one'
  g_mapWithoutConst0(1) = 'two'

  g_mapWithoutConst1(ONE) = 'one'
  g_mapWithoutConst1(1) = 'two'

  g_mapWithoutConst2(1) = 'one'
  g_mapWithoutConst2(TWO) = 'two'

  g_mapWithoutConst3(ONE) = 'one'
  g_mapWithoutConst3(TWO) = 'two'

  print *, cls_mapWithConst(1)
  print *, cls_mapWithConst1(1)
  print *, cls_mapWithConst2(1)
  print *, cls_mapWithoutConst(1)
  print *, g_mapWithConst(1)
  print *, g_mapWithoutConst(1)
  print *, g_mapWithoutConst0(1)
  print *, g_mapWithoutConst1(1)
  print *, g_mapWithoutConst2(1)
  print *, g_mapWithoutConst3(1)
end program test
program UNWRAP_TEST_ffl
  implicit none

  type :: connection_base
  end type connection_base

  type, extends(connection_base) :: stub_connection
    integer :: marker = 42
  end type stub_connection

  type :: pooled_connection
    class(connection_base), pointer :: wrapped => null()
  end type pooled_connection

  type(pooled_connection) :: pool_conn
  class(connection_base), pointer :: conn_ptr => null()
  type(stub_connection), pointer :: stub_ptr => null()
  type(stub_connection), target :: stub_instance

  stub_instance%marker = 42
  pool_conn%wrapped => stub_instance
  conn_ptr => pool_conn%wrapped

  select type (conn_ptr)
  type is (stub_connection)
    stub_ptr => conn_ptr
  class default
    error stop "unwrap failed: not a stub_connection"
  end select

  if (.not. associated(stub_ptr)) error stop "unwrap returned null"
  if (stub_ptr%marker /= 42) error stop "unwrap returned corrupted object"

end program UNWRAP_TEST_ffl
program unwrap_test
  implicit none

  type :: connection_base
  end type connection_base

  type, extends(connection_base) :: stub_connection
    integer :: marker = 42
  end type stub_connection

  type, extends(connection_base) :: pooled_connection
    class(connection_base), pointer :: wrapped => null()
  end type pooled_connection

  type(pooled_connection) :: pool_conn
  class(connection_base), pointer :: conn_ptr => null()
  type(stub_connection), pointer :: stub_ptr => null()
  type(stub_connection), target :: stub_instance

  stub_instance%marker = 42
  pool_conn%wrapped => stub_instance
  conn_ptr => pool_conn%wrapped

  select type (conn_ptr)
  type is (stub_connection)
    stub_ptr => conn_ptr
  class default
    error stop "unwrap failed: not a stub_connection"
  end select

  if (.not. associated(stub_ptr)) error stop "unwrap returned null"
  if (stub_ptr%marker /= 42) error stop "unwrap returned corrupted object"

end program unwrap_test
