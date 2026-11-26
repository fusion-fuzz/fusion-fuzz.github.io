program main
  type Foo
  end type Foo
  integer foo(bar) /bar*2/ !CHECK: foo (InDataStmt) size=4 offset=4: ObjectEntity type: INTEGER(4) shape: 1_8:1_8 init:[INTEGER(4)::2_4]
end program main
