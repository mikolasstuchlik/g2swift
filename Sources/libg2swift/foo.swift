public enum Foo { 
    public static func greet() {
        let resp = try! SourceKitDriver.request(for: .foundation)
        let resp2 = try! SourceKitDriver.request(for: .swift)
        #if os(Linux)
        let resp3 = try! SourceKitDriver.request(for: .glibc)
        #else
        let resp3 = try! SourceKitDriver.request(for: .darwin)
        #endif

        #if DIAGNOSTIC
        print("ColA  \(PropertyScanner.a)")
        print("ColE \(PropertyScanner.e)")
        #endif
        //print(resp2.entities.filter { $0.kind.contains("typealias")} )
    }
}