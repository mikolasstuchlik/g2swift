public enum Foo { 
    public static func greet() {
        let resp = try! SourceKitDriver.request(for: .foundation)
        let resp2 = try! SourceKitDriver.request(for: .swift)
        #if os(Linux)
        let resp3 = try! SourceKitDriver.request(for: .glibc)
        #else
        let resp3 = try! SourceKitDriver.request(for: .darwin)
        #endif
        print("ColA  \(Col.a)")
        print("ColE \(Col.e)")
    }
}