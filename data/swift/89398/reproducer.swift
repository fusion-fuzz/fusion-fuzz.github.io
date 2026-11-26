@available(*, unavailable)
struct S: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {}
}
@available(*, unavailable)
typealias StringLiteralType = S

let i = ""

@available(*, unavailable)
struct S1<T>: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {}
}
@available(*, unavailable)
typealias IntegerLiteralType = S1<Int>

let a = 0

func id<T>(_ x: T) -> T { x }
func ohno<T>(_ x: T) -> T? { nil }

func test_compatibility_coercions(_ arr: [Int], _ optArr: [Int]?, _ dict: [String: Int], _ set: Set<Int>, _ i: Int, _ stringAnyDict: [String: Any]) {
    _ = arr as [Any]?
    _ = dict as [String: Int]?
    _ = set as Set<Int>
    _ = arr as [String]
    _ = dict as [String: String]
    _ = dict as [String: String]?
    _ = (dict as [String: Int]?) as [String: Int]
    _ = set as Set<String>
    _ = id(arr) as [String]
    _ = (arr ?? []) as [String]
    _ = (arr ?? [] ?? []) as [String]
    _ = (optArr ?? []) as [String]
    _ = (arr ?? []) as [String]?
    _ = (arr ?? []) as [String?]?
    _ = (arr ?? []) as [String??]??
    _ = (dict ?? [:]) as [String: String?]?
    _ = (set ?? []) as Set<String>??
    _ = ohno(ohno(ohno(arr))) as [String]
    _ = ohno(ohno(ohno(arr))) as [Int]
    _ = ohno(ohno(ohno(Set<Int>()))) as Set<String>
    _ = ohno(ohno(ohno(["": ""]))) as [Int: String]
    _ = ohno(ohno(ohno(dict))) as [String: Int]
    _ = ([] ?? []) as [String]
    _ = (([] as Optional) ?? []) as [String]
    _ = ([] ?? []) as Array
    typealias Magic<T> = T
    _ = [i] as [String]
    _ = [i] as Magic as [String]
    _ = ([i]) as Magic as [String]
    _ = [i: i] as [String: Any]
    _ = ([i: i]) as [String: Any]
    _ = [i: stringAnyDict] as [String: Any]
    _ = [i].self as Magic as [String]
    _ = (try [i]) as Magic as [String]
    _ = [i: i] as! [String: Any]
    _ = [i: stringAnyDict] as! [String: Any]
}
