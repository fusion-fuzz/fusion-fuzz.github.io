func foo<T>(x: T) {
    protocol rdar27680407Proto {
        associatedtype T
        init(value: T)
    }
    struct rdar27680407Struct: rdar27680407Proto {
        init(value: rdar27680407Struct.T) {}
    }
}
