module function_with_max_result_extent_module
  interface function_with_max_result_extent
  end interface function_with_max_result_extent
end module function_with_max_result_extent_module
submodule (function_with_max_result_extent_module) function_with_max_result_extent_submodule
contains
  pure module function function_with_max_result_extent(n) result(res)
      y(:) = 0
    end function function_with_max_result_extent
end submodule function_with_max_result_extent_submodule
  block
  end block
end program
