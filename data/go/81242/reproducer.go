package main
import (
	"fmt"
	"runtime"
	"unsafe"
)
var callback func()
type T struct{
	big2
}
//go:uintptrescapes
func (T) Mv(ptrs ...uintptr) { callback() }
var tests = []func(ptr unsafe.Pointer){
	func(ptr unsafe.Pointer) { T{}.Mv(uintptr(ptr)) },
}
func main() {
	for i, test := range tests {
		finalized := false
		ptr := new([64]byte)
		runtime.SetFinalizer(ptr, func(*[64]byte) {
		})
		callback = func() {
			if finalized {
				fmt.Printf("test #%d failed\n", i)
			}
		}
		test(unsafe.Pointer(ptr))
	}
}
type big1 struct {
	w [1<<30 - 1]uint32
}
type big2 struct {
	d [1<<29 - 1]uint64
}
func loadLargeOffset(sw *big1, sd *big2) (uint32, uint64) {
	a3 := sw.w[1<<10]
	b3 := sw.w[1<<16]
	c3 := sw.w[1<<28]
	d3 := sw.w[1<<29]
	a4 := sd.d[1<<10]
	b4 := sd.d[1<<16]
	c4 := sd.d[1<<27]
	d4 := sd.d[1<<28]
	return a3 + b3 + c3 + d3, a4 + b4 + c4 + d4
}
type big1_bd84f3a struct {
	w [1<<30 - 1]uint32
}
type big2_bd84f3a struct {
	d [1<<29 - 1]uint64
}
func loadLargeOffset_bd84f3a(sw *big1_bd84f3a, sd *big2_bd84f3a) (uint32, uint64) {
	a3 := sw.w[1<<10]
	b3 := sw.w[1<<16]
	c3 := sw.w[1<<28]
	d3 := sw.w[1<<29]
	a4 := sd.d[1<<10]
	b4 := sd.d[1<<16]
	c4 := sd.d[1<<27]
	d4 := sd.d[1<<28]
	return a3 + b3 + c3 + d3, a4 + b4 + c4 + d4
}
