import SourceKittenFramework
import Foundation

//
// This file was autgenerated using -DDIAGNOSTICS and Root type was modified
// Passing platform: Ubuntu 20.04
//
struct Attributes: SKObject {

    @SKValue(key: "key.is_unavailable") var isUnavailable: Int64?
    @SKValue(key: "key.message") var message: String?
    @SKValue(key: "key.obsoleted") var obsoleted: String?
    @SKValue(key: "key.introduced") var introduced: String?
    @SKValue(key: "key.is_deprecated") var isDeprecated: Int64?
    @SKValue(key: "key.kind") var kind: String
    @SKValue(key: "key.deprecated") var deprecated: String?
    @SKValue(key: "key.platform") var platform: String?

    init(from skRepresentable: SourceKitRepresentable?) throws {
        try self.load(from: skRepresentable!)
    }

}


struct GenericRequirements: SKObject {

    @SKValue(key: "key.description") var description: String

    init(from skRepresentable: SourceKitRepresentable?) throws {
        try self.load(from: skRepresentable!)
    }

}

// Root
final class ModuleResponse: SKObject {

    @SKValue(key: "key.annotations") var annotations: [Annotations]
    //@SKValue(key: "key.sourcetext") var sourcetext: String
    @SKValue(key: "key.entities") var entities: [Entities]

    init(from skRepresentable: SourceKitRepresentable?) throws {
        var aSelf = self
        try aSelf.load(from: skRepresentable!)

        #if DIAGNOSTIC
        PropertyScanner.responses.append(PropertyScanner.initialize(from: skRepresentable as! [String: SourceKitRepresentable]))
        #endif
    }

}


struct Inherits: SKObject {

    @SKValue(key: "key.kind") var kind: String
    @SKValue(key: "key.usr") var usr: String
    @SKValue(key: "key.is_deprecated") var isDeprecated: Int64?
    @SKValue(key: "key.name") var name: String

    init(from skRepresentable: SourceKitRepresentable?) throws {
        try self.load(from: skRepresentable!)
    }

}


struct Annotations: SKObject {

    @SKValue(key: "key.offset") var offset: Int64
    @SKValue(key: "key.length") var length: Int64
    @SKValue(key: "key.name") var name: String?
    @SKValue(key: "key.kind") var kind: String
    @SKValue(key: "key.usr") var usr: String?

    init(from skRepresentable: SourceKitRepresentable?) throws {
        try self.load(from: skRepresentable!)
    }

}


struct Extends: SKObject {

    @SKValue(key: "key.usr") var usr: String
    @SKValue(key: "key.is_deprecated") var isDeprecated: Int64?
    @SKValue(key: "key.name") var name: String
    @SKValue(key: "key.kind") var kind: String

    init(from skRepresentable: SourceKitRepresentable?) throws {
        try self.load(from: skRepresentable!)
    }

}


struct GenericParams: SKObject {

    @SKValue(key: "key.name") var name: String

    init(from skRepresentable: SourceKitRepresentable?) throws {
        try self.load(from: skRepresentable!)
    }

}


struct Conforms: SKObject {

    @SKValue(key: "key.kind") var kind: String
    @SKValue(key: "key.name") var name: String
    @SKValue(key: "key.usr") var usr: String

    init(from skRepresentable: SourceKitRepresentable?) throws {
        try self.load(from: skRepresentable!)
    }

}


struct Entities: SKObject {

    @SKValue(key: "key.doc.full_as_xml") var fullAsXml: String?
    @SKValue(key: "key.kind") var kind: String
    @SKValue(key: "key.is_deprecated") var isDeprecated: Int64?
    @SKValue(key: "key.extends") var extends: Extends?
    @SKValue(key: "key.generic_params") var genericParams: [GenericParams]?
    @SKValue(key: "key.attributes") var attributes: [Attributes]?
    @SKValue(key: "key.generic_requirements") var genericRequirements: [GenericRequirements]?
    @SKValue(key: "key.default_implementation_of") var defaultImplementationOf: String?
    @SKValue(key: "key.original_usr") var originalUsr: String?
    @SKValue(key: "key.conforms") var conforms: [Conforms]?
    @SKValue(key: "key.offset") var offset: Int64
    @SKValue(key: "key.name") var name: String?
    @SKValue(key: "key.length") var length: Int64
    @SKValue(key: "key.is_unavailable") var isUnavailable: Int64?
    @SKValue(key: "key.entities") var entities: [Entities]?
    @SKValue(key: "key.inherits") var inherits: [Inherits]?
    @SKValue(key: "key.fully_annotated_decl") var fullyAnnotatedDecl: String?
    @SKValue(key: "key.keyword") var keyword: String?
    @SKValue(key: "key.usr") var usr: String?

    init(from skRepresentable: SourceKitRepresentable?) throws {
        try self.load(from: skRepresentable!)
    }

}
