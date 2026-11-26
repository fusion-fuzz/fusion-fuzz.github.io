package codegen

// asmcheck

// Copyright 2026 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.


// From issue #77720: cmd/compile: field access on struct-returning method copies entire struct

type moveLoadBig struct {
	typ   int8
	index int64
	str   string
	pkgID string
}

type moveLoadHandle[T any] struct {
	value *T
}

func (h moveLoadHandle[T]) Value() T { return *h.value }

type moveLoadS struct {
	h moveLoadHandle[moveLoadBig]
}

func moveLoadFieldViaValue(s moveLoadS) int8 {
	// amd64:-`MOVUPS`
	// amd64:`MOVBLZX`
	return s.h.Value().typ
}

func moveLoadFieldViaValueInline(ss []moveLoadS, i int) int8 {
	// amd64:-`MOVUPS`
	// amd64:`MOVBLZX`
	return ss[i&7].h.Value().typ
}

// compile

// Copyright 2018 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Issue 27143: cmd/compile: erroneous application of walkinrange
// optimization for const over 2**63


var c uint64

// compile

// Copyright 2018 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Issue 27143: cmd/compile: erroneous application of walkinrange
// optimization for const over 2**63


var c_d3eecef uint64

var b1_d3eecef bool = 0x7fffffffffffffff < c_d3eecef && c_d3eecef < 0x8000000000000000
var b2_d3eecef bool = c_d3eecef < 0x8000000000000000 && 0x7fffffffffffffff < c_d3eecef
var b3_d3eecef bool = 0x8000000000000000 < c_d3eecef && c_d3eecef < 0x8000000000000001
var b1 bool = 0x7fffffffffffffff < c && c < 0x8000000000000000
var b2 bool = c < 0x8000000000000000 && 0x7fffffffffffffff < c
var b3 bool = 0x8000000000000000 < c && c < 0x8000000000000001
var b4 bool = c < 0x8000000000000001 && 0x8000000000000000 < c
var b4_d3eecef bool = c_d3eecef < 0x8000000000000001 && 0x8000000000000000 < c_d3eecef
