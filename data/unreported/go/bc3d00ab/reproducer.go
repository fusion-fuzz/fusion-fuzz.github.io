package main

import (
	"os"
)

// run

// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.


const (
	x float64 = iota
	g float64 = 4.5 * iota
)

func main() {
	if g == 0.0 {
		print("zero\n")
	}
	if g != 4.5 {
		print(" fail\n")
		os.Exit(1)
	}
}

// asmcheck -race

// Copyright 2019 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.


// Check that we elide racefuncenter/racefuncexit for
// functions with no calls (but which might panic
// in various ways). See issue 31219.
// amd64:-"CALL.*racefuncenter.*"
// arm64:-"CALL.*racefuncenter.*"
// ppc64le:-"CALL.*racefuncenter.*"
func RaceMightPanic(a []int, i, j, k, s int) {
	var b [4]int
	_ = b[i]     // panicIndex
	_ = a[i:j]   // panicSlice
	_ = a[i:j:k] // also panicSlice
	_ = i << x   // panicShift
	_ = i / j    // panicDivide
}
// asmcheck -race

// Copyright 2019 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.


// Check that we elide racefuncenter/racefuncexit for
// functions with no calls (but which might panic
// in various ways). See issue 31219.
// amd64:-"CALL.*racefuncenter.*"
// arm64:-"CALL.*racefuncenter.*"
// ppc64le:-"CALL.*racefuncenter.*"
func RaceMightPanic_daaa397(a []int, i, j, k, s int) {
	var b [4]int
	_ = b[i]     // panicIndex
	_ = a[i:j]   // panicSlice
	_ = a[i:j:k] // also panicSlice
	_ = i << s   // panicShift
	_ = i / j    // panicDivide
}
