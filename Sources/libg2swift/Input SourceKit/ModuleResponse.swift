import SourceKittenFramework
import Foundation

// MARK: - Representation
// reference: https://github.com/apple/swift/blob/main/tools/SourceKit/docs/Protocol.md#response-2

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
struct Annotation: SKInitializable {

    /// UID for the declaration kind (function, class, etc.).
    @SKValue(key: "key.kind") var kind: String
    /// Location of the annotated token.
    @SKValue(key: "key.offset") var offset: Int64
    /// Length of the annotated token.
    @SKValue(key: "key.length") var length: Int64

    init(from skRepresentable: SourceKitRepresentable) throws {
        guard let object = skRepresentable as? [String: SourceKitRepresentable] else {
            throw SourceKitError.valueMissingOrNotAnObject
        }
        try _kind.get(from: object)
        try _offset.get(from: object)
        try _length.get(from: object)

        #if DIAGNOSTIC
        PropertyScanner.a.put(object.map { "\($0) \(String(describing: type(of: $1)))" })
        #endif
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
struct Entity: SKInitializable {
    /// UID for the declaration or reference kind (function, class, etc.).
    @SKValue(key: "key.kind") var kind: String
    /// Displayed name for the entity.
    @SKValue(key: "key.name") var name: String?
    /// USR string for the entity.
    @SKValue(key: "key.usr") var usr: String?
    /// Location of the entity.
    @SKValue(key: "key.offset") var offset: Int64
    /// Length of the entity.
    @SKValue(key: "key.length") var length: Int64
    /// XML representing the entity, its USR, etc.
    @SKValue(key: "key.fully_annotated_decl") var fulltAnnotatedDeclaration: String?
    /// XML representing the entity and its documentation. Only present
    /// when the entity is documented.
    @SKValue(key: "key.doc.full_as_xml") var docAsXml: String?
    /// One or more entities contained in the particular entity (sub-classes, references, etc.).
    @SKValue(key: "key.entities") var entities: [Entity]?

    init(from skRepresentable: SourceKitRepresentable) throws {
        guard let object = skRepresentable as? [String: SourceKitRepresentable] else {
            throw SourceKitError.valueMissingOrNotAnObject
        }
        try _kind.get(from: object)
        try _name.getOptional(from: object)
        try _usr.getOptional(from: object)
        try _offset.get(from: object)
        try _length.get(from: object)
        try _fulltAnnotatedDeclaration.getOptional(from: object)
        try _docAsXml.getOptional(from: object)
        try _entities.getOptional(from: object)

        #if DIAGNOSTIC
        PropertyScanner.e.put(object.map { "\($0) \(String(describing: type(of: $1)))" })
        #endif
    }
}

final class ModuleResponse {

    @SKValue(key: "key.annotations") var annotations: [Annotation]
    @SKValue(key: "key.entities") var entities: [Entity]

    init(response: [String : SourceKitRepresentable]) throws {
        try _annotations.get(from: response)
        try _entities.get(from: response)
    }
}
