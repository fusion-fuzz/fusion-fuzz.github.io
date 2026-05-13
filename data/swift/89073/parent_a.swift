func myPrintR(_ dict: [String: Any]) {
    let sortedDict = dict.sorted(by: { $0.key < $1.key })
    for (key, value) in sortedDict {
        print("\(key): \(value)")
    }
}

func f1() {
    let c = 1
    print("Extracted:")
    myPrintR(["": c])
    myPrintR(["c": c])
}

func f2() {
    let a = 1
    let c = 1
    print("Extracted:")
    myPrintR(["a": c])
    myPrintR(["c": c, "a": a])
}

func f3() {
    let a = 1
    let c = 1
    print("Extracted:")
    myPrintR(["a": c])
    myPrintR(["c": c, "prefix_a": a])
}

func f4() {
    let c = 1
    print("Extracted:")
    myPrintR(["": c])
    myPrintR(["c": c])
}

func f5() {
    let c = 1
    print("Extracted:")
    myPrintR(["111": c])
    myPrintR(["c": c])
}

f1()
f2()
f3()
f4()
f5()