struct Butz<Flubz: Comparable> { }
extension Butz: Collection {
    public var startIndex: Flubz { fatalError() }
    public var endIndex: Flubz { fatalError() }
    public subscript (_ position: Flubz) -> Flubz {
        get { fatalError() }
    }
    public func index(after i: Flubz) -> Flubz { fatalError() }
}
