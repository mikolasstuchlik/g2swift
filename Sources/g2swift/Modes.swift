import libg2swift

enum SourceKitMode { 
    #if DIAGNOSTIC
    static var generateModuleDefinition: Bool = false
    #endif

    private static func printRecursive(element entities: inout [Entities]?, kind: String?) {
        for i in 0..<(entities ?? []).count {
            printRecursive(element: &entities![i].entities, kind: kind)
            guard entities![i].name != nil else {
                continue
            }

            guard kind == nil || entities![i].kind == kind else {
                continue
            } 

            print(entities![i].name!.padding(toLength: 40, withPad: " ", startingAt: 0) + entities![i].kind)
        }
    }
    
    public static func loadModule(name: String, path: String?, sourceKitKind: String?) {
        let response = try! SourceKitDriver.request(for: name, path: path)

        #if DIAGNOSTIC
        if generateModuleDefinition {
            var all = PropertyScanner()
            for item in PropertyScanner.responses {
                all.merge(item)
            }
            print(all.modelDeclaration)
            return
        }
        #endif

        var entities: [Entities]? = response.entities 
        printRecursive(element: &entities, kind: sourceKitKind)
    }
}