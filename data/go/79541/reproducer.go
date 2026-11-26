package main

func G[U any]() (u U) { return }

func F[T ~*[1]byte]() {
	_ = G[T]()[:]
}

var _ = F[*[1]byte]

func main() {}
