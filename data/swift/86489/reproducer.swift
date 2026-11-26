var x = 0
throw E()

struct E: Error {
    init() {
        _ = x
    }
}
