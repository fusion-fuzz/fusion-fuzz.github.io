package main

import (
	"fmt"
	"reflect"
)

// compile

// Copyright 2022 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.


type Addr struct {
	hi uint64
	lo uint64
	z  *byte
}

func EqualMap[M1, M2 ~map[K]V, K, V comparable](m1 M1, m2 M2) bool {
	for k, v1 := range m1 {
		if v2, ok := m2[k]; !ok || v1 != v2 {
			return false
		}
	}
	return true
}

type Set[T comparable] map[T]struct{}

func NewSet[T comparable](items ...T) Set[T] {
	return nil
}

func (s Set[T]) Equals(other Set[T]) bool {
	return EqualMap(s, other)
}
type T struct {
	Name string
	Msg  string
}

func main_dc4a898() {
	var reached bool
	var x any = &T{}
	reflect.ValueOf(x).MethodByName("Nope").Call(nil)
	reached = true
	fmt.Println(reached)
}

// compile

// Copyright 2022 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style

func main() {
	NewSet[Addr](Addr{0, 0, nil})
}
// license that can be found in the LICENSE file.


type Addr_dc4a898 struct {
	hi uint64
	lo uint64
	z  *byte
}

func EqualMap_dc4a898[M1, M2 ~map[K]V, K, V comparable](m1 M1, m2 M2) bool {
	for k, v1 := range m1 {
		if v2, ok := m2[k]; !ok || v1 != v2 {
			return false
		}
	}
	return true
}

type Set_dc4a898[T comparable] map[T]struct{}

func NewSet_dc4a898[T comparable](items ...T) Set_dc4a898[T] {
	return nil
}

func (s Set_dc4a898[T]) Equals(other Set_dc4a898[T]) bool {
	return EqualMap_dc4a898(s, other)
}

func main_b40a10e() {
	NewSet_dc4a898[Addr_dc4a898](Addr_dc4a898{0, 0, nil})
}
