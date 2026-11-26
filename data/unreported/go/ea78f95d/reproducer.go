package main

type T [1 << 34]byte

func op(h func(T)) {
	var t T
	h(t)
}

func get(h func(T)) {
	op(h)
}

func main() {
	get(func(T) {})
}
