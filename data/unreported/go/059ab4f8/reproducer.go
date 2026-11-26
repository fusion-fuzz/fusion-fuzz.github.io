package main

import (
	"fmt"
)

// run

// Copyright 2011 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Issue 2423


// run

// Copyright 2022 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
func main() {
	var x interface{} = "hello"

	switch x {
	case "hello":
	default:
		println("FAIL")
	}
}


// Numeric expresses a type constraint satisfied by any numeric type.
type Numeric interface {
	~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 |
		~int | ~int8 | ~int16 | ~int32 | ~int64 |
		~float32 | ~float64 |
		~complex64 | ~complex128
}

// Sum returns the sum of the provided arguments.
func Sum[T Numeric](args ...T) T {
	var sum T
	for i := 0; i < len(args); i++ {
		sum += args[i]
	}
	return sum
}

// Ledger is an identifiable, financial record.
type Ledger[T ~string, K Numeric] struct {
	// ID identifies the ledger.
	ID_ T

	// Amounts is a list of monies associated with this ledger.
	Amounts_ []K

	// SumFn is a function that can be used to sum the amounts
	// in this ledger.
	SumFn_ func(...K) K
}

// Field accesses through type parameters are disabled
// until we have a more thorough understanding of the
// implications on the spec. See issue #51576.
// Use accessor methods instead.

func (l Ledger[T, _]) ID() T               { return l.ID_ }
func (l Ledger[_, K]) Amounts() []K        { return l.Amounts_ }
func (l Ledger[_, K]) SumFn() func(...K) K { return l.SumFn_ }

func PrintLedger[
	T ~string,
	K Numeric,
	L interface {
		~struct {
			ID_      T
			Amounts_ []K
			SumFn_   func(...K) K
		}
		ID() T
		Amounts() []K
		SumFn() func(...K) K
	},
](l L) {
	fmt.Printf("%s has a sum of %v\n", l.ID(), l.SumFn()(l.Amounts()...))
}

func main_dbd5b3a() {
	PrintLedger(Ledger[string, int]{
		ID_:      "fake",
		Amounts_: []int{1, 2, 3},
		SumFn_:   Sum[int],
	})
}

// run

// Copyright 2022 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.


// Numeric_bbd5b3a expresses a type constraint satisfied by any numeric type.
type Numeric_bbd5b3a interface {
	~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 |
		~int | ~int8 | ~int16 | ~int32 | ~int64 |
		~float32 | ~float64 |
		~complex64 | ~complex128
}

// Sum_bbd5b3a returns the sum of the provided arguments.
func Sum_bbd5b3a[T Numeric_bbd5b3a](args ...T) T {
	var sum T
	for i := 0; i < len(args); i++ {
		sum += args[i]
	}
	return sum
}

// Ledger_bbd5b3a is an identifiable, financial record.
type Ledger_bbd5b3a[T ~string, K Numeric_bbd5b3a] struct {
	// ID identifies the ledger.
	ID_ T

	// Amounts is a list of monies associated with this ledger.
	Amounts_ []K

	// SumFn is a function that can be used to sum the amounts
	// in this ledger.
	SumFn_ func(...K) K
}

// Field accesses through type parameters are disabled
// until we have a more thorough understanding of the
// implications on the spec. See issue #51576.
// Use accessor methods instead.

func (l Ledger_bbd5b3a[T, _]) ID() T               { return l.ID_ }
func (l Ledger_bbd5b3a[_, K]) Amounts() []K        { return l.Amounts_ }
func (l Ledger_bbd5b3a[_, K]) SumFn() func(...K) K { return l.SumFn_ }

func PrintLedger_bbd5b3a[
	T ~string,
	K Numeric_bbd5b3a,
	L interface {
		~struct {
			ID_      T
			Amounts_ []K
			SumFn_   func(...K) K
		}
		ID() T
		Amounts() []K
		SumFn() func(...K) K
	},
](l L) {
	fmt.Printf("%s has a sum of %v\n", l.ID(), l.SumFn()(l.Amounts()...))
}

func main_bbd5b3a() {
	PrintLedger_bbd5b3a(Ledger_bbd5b3a[string, int]{
		ID_:      "fake",
		Amounts_: []int{1, 2, 3},
		SumFn_:   Sum_bbd5b3a[int],
	})
}
