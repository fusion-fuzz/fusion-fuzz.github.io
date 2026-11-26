program main
  implicit none
  type :: myclass
  end type myclass

  type, extends(myclass) :: myotherclass
  end type myotherclass

  class(*), pointer :: obj_id_p => null()
  class(myclass), pointer :: obj_c_cat_p => null()
  class(myotherclass), pointer :: obj_c_super_p => null()
  class(myotherclass), pointer :: obj_c_super_p_q => null()
  class(myclass), pointer :: obj_c_cat_p_q => null()

  integer :: a(10) = [0, 2, 0, 0, 0, 0, 0, 0, 0, 0]
  character(len=10) :: str = 'x'
  type :: test_t
     integer :: x
     real(8) :: y
  end type test_t
  type(test_t) :: array(10) = [test_t(2, 12.0d0), test_t(3, 24.0d0), test_t(0, 0.0d0), test_t(0, 0.0d0), test_t(0, 0.0d0), test_t(0, 0.0d0), test_t(0, 0.0d0), test_t(0, 0.0d0), test_t(0, 0.0d0), test_t(0, 0.0d0)]
  integer :: b(4,4) = reshape([1,2,3,4,5,6,7,0,8,9,0,0,0,0,0,0], [4,4])
  real :: f(12) = [1.23, 34.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  class(*), allocatable :: arr(:)
  obj_c_cat_p => obj_id_p
  obj_c_super_p => obj_id_p
  obj_id_p => obj_c_cat_p
  obj_id_p => obj_c_super_p

  if (.not. associated(obj_c_cat_p, obj_id_p)) continue
  if (.not. associated(obj_c_super_p, obj_id_p)) continue
  if (.not. associated(obj_id_p, obj_c_cat_p)) continue
  if (.not. associated(obj_id_p, obj_c_super_p)) continue

  obj_c_cat_p => obj_c_super_p
  obj_c_cat_p => obj_c_super_p_q
  obj_c_super_p => null()
  obj_c_cat_p_q => obj_c_super_p

  allocate(arr(5), source=[null(), null(), null(), null(), null()])
  deallocate(arr)
end program main
