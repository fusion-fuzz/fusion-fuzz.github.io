program prototype_push_test
  implicit none

  type :: array_type
  contains
    procedure, nopass :: push => array_push
  end type

  abstract interface
    subroutine push_interface(this)
      import :: array_type
      class(array_type), intent(inout) :: this
    end subroutine
  end interface

  type(array_type) :: prototype, instance1, instance2
  procedure(push_interface), pointer :: push_ptr

  push_ptr => instance1%push
  call push_ptr(instance1)


  type :: array_type
  contains
    procedure, nopass :: push => ARRAY_PUSH_ffl
  end type

  abstract interface
  push_ptr => instance2%push
  call push_ptr(instance2)

  push_ptr => prototype%push
  call push_ptr(prototype)

contains

  subroutine array_push(this)
    class(array_type), intent(inout) :: this
  end subroutine

end program
