import ArgumentParser
import libg2swift

@main
struct G2Swift: ParsableCommand {
    mutating func run() throws {
        Foo.greet()
    }
}