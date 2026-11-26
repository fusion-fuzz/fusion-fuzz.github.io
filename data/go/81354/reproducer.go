package main
import "reflect"
func g(x struct{ a, b int }) { reflect.ValueOf(x) }
func f[T any](i interface{}) {
	switch i.(type) {
	case T:
	case struct{ a, b T }:
	}
}
func main() { f[int](0); f[any](0) }
