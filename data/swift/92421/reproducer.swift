import _Differentiation
var global_f_linear: @differentiable(_linear) (Float) -> Float = {$0}
func escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var captured = global_f_linear
    let escaped = escape { captured }
    _ = escaped
    captured = global_f_linear
}
