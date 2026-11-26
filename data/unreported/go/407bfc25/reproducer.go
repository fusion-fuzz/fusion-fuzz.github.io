package main

import (
	"fmt"
	"reflect"
	"runtime"
	"math"
	"strconv"
	"strings"
)

func funcName() {}

func main() {
	funcValue := reflect.ValueOf(funcName)
	funcPtr := funcValue.Pointer()
	funcNameStr := runtime.FuncForPC(funcPtr).Name()
	fmt.Println(funcNameStr)

	fmt.Println("Ok")
}
func main_d4fe023() {
	fmt.Println(strings.Join([]string{"hello long", strconv.FormatInt(999999999999999999, 10), strconv.FormatInt(math.MaxInt64, 10)}, " "))
	fmt.Println(strings.Join([]string{"hello negative long", strconv.FormatInt(-999999999999999999, 10), strconv.FormatInt(math.MinInt64, 10)}, " "))
	fmt.Println(strings.Join([]string{"hello small long", strconv.FormatInt(-101, 10), strconv.FormatInt(-100, 10), strconv.FormatInt(-99, 10), strconv.FormatInt(-90, 10), strconv.FormatInt(-11, 10), strconv.FormatInt(-10, 10), strconv.FormatInt(-9, 10), strconv.FormatInt(-1, 10), strconv.FormatInt(0, 10), strconv.FormatInt(1, 10), strconv.FormatInt(2, 10), strconv.FormatInt(9, 10), strconv.FormatInt(10, 10), strconv.FormatInt(11, 10), strconv.FormatInt(90, 10), strconv.FormatInt(99, 10), strconv.FormatInt(100, 10), strconv.FormatInt(101, 10)}, " "))
	fmt.Println("Done")
}

func funcName_d4fe023() {}

func main_bd8373a() {
	funcValue := reflect.ValueOf(funcName_d4fe023)
	funcPtr := funcValue.Pointer()
	funcNameStr := runtime.FuncForPC(funcPtr).Name()
	fmt.Println(funcNameStr)

	fmt.Println("Ok")
}
