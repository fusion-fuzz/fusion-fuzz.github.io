package p

// errorcheck

// Copyright 2012 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// compile

// Copyright 2022 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.


var x_d797415 T[B]
type A_d797415 T[B]

var init = 1 // ERROR "cannot declare init - must be func"

// compile

// Copyright 2022 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.


var x T[B]

type T[_ any] struct{}
type A T[B]
type B = T[A]
