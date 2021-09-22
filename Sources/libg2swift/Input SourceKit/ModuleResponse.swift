import SourceKittenFramework
import Foundation

// MARK: - Representation
// reference: https://github.com/apple/swift/blob/main/tools/SourceKit/docs/Protocol.md#response-2


struct Col {
    static var a = Col ()
    static var e = Col ()

    mutating func put<T: Sequence>(_ val: T) where T.Element == String {
        keys.formUnion(val)

        nonOpt = nonOpt ?? Set(val)
        nonOpt?.formIntersection(val)
    }

    var keys = Set<String>() 
    var nonOpt: Set<String>?
}

// linux
// Col(
//     keys: Set(["key.offset", "key.length", "key.name", "key.usr", "key.kind"]), 
//     nonOpt: Optional(Set(["key.offset", "key.kind", "key.length"]))
// )
//
// macOS
// Col(
//     keys: Set(["key.usr", "key.name", "key.length", "key.offset", "key.kind"]),
//     nonOpt: Optional(Set(["key.offset", "key.kind", "key.length"]))
// )
//
struct Annotation {

    /// UID for the declaration kind (function, class, etc.).
    let kind: String
    /// Location of the annotated token.
    let offset: Int64
    /// Length of the annotated token.
    let length: Int64

    init(skRepresentable: SourceKitRepresentable) throws {
        guard let response = skRepresentable as? [String: SourceKitRepresentable] else {
            throw ModuleResponse.Error.valueMissingOrMismatch(forKey: nil)
        }

        Col.a.put(response.keys)

        guard let kind = response["key.kind"] as? String else {
            throw ModuleResponse.Error.valueMissingOrMismatch(forKey: "key.kind")
        }
        self.kind = kind

        guard let offset = response["key.offset"] as? Int64 else {
            throw ModuleResponse.Error.valueMissingOrMismatch(forKey: "key.offset")
        }
        self.offset = offset

        guard let length = response["key.length"] as? Int64 else {
            throw ModuleResponse.Error.valueMissingOrMismatch(forKey: "key.length")
        }
        self.length = length
        
    }
}

// linux
// Col(
//     keys: Set(["key.is_deprecated", "key.doc.full_as_xml", "key.conforms", "key.original_usr", "key.attributes", "key.keyword", "key.offset", "key.extends", "key.is_unavailable", "key.entities", "key.usr", "key.generic_params", "key.default_implementation_of", "key.length", "key.kind", "key.name", "key.inherits", "key.generic_requirements", "key.fully_annotated_decl"]), 
//     nonOpt: Optional(Set(["key.length", "key.kind", "key.offset"]))
// )
//
// macOS
// Col(
//     keys: Set(["key.modulename", "key.usr", "key.keyword", "key.attributes", "key.extends", "key.name", "key.offset", "key.generic_requirements", "key.is_deprecated", "key.is_optional", "key.doc.full_as_xml", "key.inherits", "key.kind", "key.default_implementation_of", "key.fully_annotated_decl", "key.conforms", "key.is_async", "key.length", "key.is_unavailable", "key.entities", "key.original_usr", "key.generic_params"]),
//     nonOpt: Optional(Set(["key.length", "key.offset", "key.kind"]))
// )
struct Entity {
    /// UID for the declaration or reference kind (function, class, etc.).
    let kind: String
    /// Displayed name for the entity.
    let name: String?
    /// USR string for the entity.
    let usr: String?
    /// Location of the entity.
    let offset: Int64
    /// Length of the entity.
    let length: Int64
    /// XML representing the entity, its USR, etc.
    let fulltAnnotatedDeclaration: String?
    /// XML representing the entity and its documentation. Only present
    /// when the entity is documented.
    let docAsXml: String?
    /// One or more entities contained in the particular entity (sub-classes, references, etc.).
    let entities: [Entity]

    init(skRepresentable: SourceKitRepresentable) throws {
        guard let response = skRepresentable as? [String: SourceKitRepresentable] else {
            throw ModuleResponse.Error.valueMissingOrMismatch(forKey: nil)
        }

        Col.e.put(response.keys)

        guard let kind = response["key.kind"] as? String else {
            throw ModuleResponse.Error.valueMissingOrMismatch(forKey: "key.kind")
        }
        self.kind = kind

        self.name = response["key.name"] as? String

        self.usr = response["key.usr"] as? String

        guard let offset = response["key.offset"] as? Int64 else {
            throw ModuleResponse.Error.valueMissingOrMismatch(forKey: "key.offset")
        }
        self.offset = offset

        guard let length = response["key.length"] as? Int64 else {
            throw ModuleResponse.Error.valueMissingOrMismatch(forKey: "key.length")
        }
        self.length = length

        self.fulltAnnotatedDeclaration = response["key.fully_annotated_decl"] as? String

        self.docAsXml = response["key.doc.full_as_xml"] as? String
        self.entities = try (response["key.entities"] as? [SourceKitRepresentable])?.map(Entity.init(skRepresentable:)) ?? []
    }
}

final class ModuleResponse {

    enum Error: Swift.Error {
        case valueMissingOrMismatch(forKey: String?)
    }

    let annotations: [Annotation]
    let entities: [Entity]

    init(response: [String : SourceKitRepresentable]) throws {
        guard let annotations = response["key.annotations"] as? [SourceKitRepresentable] else {
            throw Error.valueMissingOrMismatch(forKey: "key.annotations")
        }
        self.annotations = try annotations.map(Annotation.init(skRepresentable:))

        guard let entities = response["key.entities"] as? [SourceKitRepresentable] else {
            throw Error.valueMissingOrMismatch(forKey: "key.entities")
        }
        self.entities = try entities.map(Entity.init(skRepresentable:))
    }
}
