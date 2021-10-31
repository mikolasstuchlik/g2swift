import SourceKittenFramework
import Foundation

//
// This file was autgenerated using -DDIAGNOSTICS and Root type was modified
// Passing platform: Ubuntu 20.04
//
public struct Attributes: SKObject {

    @SKValue(key: "key.is_unavailable") public var isUnavailable: Int64?
    @SKValue(key: "key.message") public var message: String?
    @SKValue(key: "key.obsoleted") public var obsoleted: String?
    @SKValue(key: "key.introduced") public var introduced: String?
    @SKValue(key: "key.is_deprecated") public var isDeprecated: Int64?
    @SKValue(key: "key.kind") public var kind: String
    @SKValue(key: "key.deprecated") public var deprecated: String?
    @SKValue(key: "key.platform") public var platform: String?

}


public struct GenericRequirements: SKObject {

    @SKValue(key: "key.description") public var description: String

}

// Root
public struct ModuleResponse: SKObject {

    @SKValue(key: "key.annotations") public var annotations: [Annotations]
    //@SKValue(key: "key.sourcetext") public var sourcetext: String
    @SKValue(key: "key.entities") public var entities: [Entities]

}


public struct Inherits: SKObject {

    @SKValue(key: "key.kind") public var kind: String
    @SKValue(key: "key.usr") public var usr: String
    @SKValue(key: "key.is_deprecated") public var isDeprecated: Int64?
    @SKValue(key: "key.name") public var name: String

}


public struct Annotations: SKObject {

    @SKValue(key: "key.offset") public var offset: Int64
    @SKValue(key: "key.length") public var length: Int64
    @SKValue(key: "key.name") public var name: String?
    @SKValue(key: "key.kind") public var kind: String
    @SKValue(key: "key.usr") public var usr: String?

}


public struct Extends: SKObject {

    @SKValue(key: "key.usr") public var usr: String
    @SKValue(key: "key.is_deprecated") public var isDeprecated: Int64?
    @SKValue(key: "key.name") public var name: String
    @SKValue(key: "key.kind") public var kind: String

}


public struct GenericParams: SKObject {

    @SKValue(key: "key.name") public var name: String

}


public struct Conforms: SKObject {

    @SKValue(key: "key.kind") public var kind: String
    @SKValue(key: "key.name") public var name: String
    @SKValue(key: "key.usr") public var usr: String

}


public struct Entities: SKObject {

    @SKValue(key: "key.doc.full_as_xml") public var fullAsXml: String?
    @SKValue(key: "key.kind") public var kind: String
    @SKValue(key: "key.is_deprecated") public var isDeprecated: Int64?
    @SKValue(key: "key.extends") public var extends: Extends?
    @SKValue(key: "key.generic_params") public var genericParams: [GenericParams]?
    @SKValue(key: "key.attributes") public var attributes: [Attributes]?
    @SKValue(key: "key.generic_requirements") public var genericRequirements: [GenericRequirements]?
    @SKValue(key: "key.default_implementation_of") public var defaultImplementationOf: String?
    @SKValue(key: "key.original_usr") public var originalUsr: String?
    @SKValue(key: "key.conforms") public var conforms: [Conforms]?
    @SKValue(key: "key.offset") public var offset: Int64
    @SKValue(key: "key.name") public var name: String?
    @SKValue(key: "key.length") public var length: Int64
    @SKValue(key: "key.is_unavailable") public var isUnavailable: Int64?
    @SKValue(key: "key.entities") public var entities: [Entities]?
    @SKValue(key: "key.inherits") public var inherits: [Inherits]?
    @SKValue(key: "key.fully_annotated_decl") public var fullyAnnotatedDecl: String?
    @SKValue(key: "key.keyword") public var keyword: String?
    @SKValue(key: "key.usr") public var usr: String?

}
