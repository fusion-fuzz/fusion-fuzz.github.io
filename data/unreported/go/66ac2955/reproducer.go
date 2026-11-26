package main

import (
	"fmt"
)

func main() {
	for i := 0; i < 100000; i++ {
		v := int32(-2147483642)
		for j := 0; j < 10; j++ {
			if j > 5 {
				v += 42
				break
			}
		}
		_ = v
	}

	m := map[interface{}]interface{}{
		"f": func() int { return x + y },
		2:   func() int { return x - y },
	}
	_ = m
	fmt.Print("")
}
// errorcheck

// Copyright 2021 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.


//go:embed issue48230.go // ERROR `go:embed only allowed in Go files that import "embed"`

var x, y int
var _ string

// errorcheck

// Copyright 2021 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.


//go:embed issue48230.go // ERROR `go:embed only allowed in Go files that import "embed"`
var _ string
