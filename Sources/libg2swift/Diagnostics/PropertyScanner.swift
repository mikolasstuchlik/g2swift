#if DIAGNOSTIC

struct PropertyScanner {
    static var a = PropertyScanner()
    static var e = PropertyScanner()

    mutating func put<T: Sequence>(_ val: T) where T.Element == String {
        keys.formUnion(val)

        nonOpt = nonOpt ?? Set(val)
        nonOpt?.formIntersection(val)
    }

    var keys = Set<String>()
    var nonOpt: Set<String>?
}

#endif