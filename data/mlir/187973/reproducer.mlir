module {
  func.func @f() {
    %0 = "emitc.constant"() {value = 1 : ui32} : () -> ui32
    emitc.switch %0 : ui32
    case 2 {
      emitc.yield
    }
    default {
      emitc.yield
    }
    return
  }
}
