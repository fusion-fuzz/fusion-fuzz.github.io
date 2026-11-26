package main
import (
	"reflect"
)
func intPtrTypeKind() reflect.Kind {
	return reflect.TypeFor[*int]().Kind()
}
type large struct {
	large_d430158
	b [1500000000]byte
}
type large_d430158 struct {
	b [1500000000]byte
}
