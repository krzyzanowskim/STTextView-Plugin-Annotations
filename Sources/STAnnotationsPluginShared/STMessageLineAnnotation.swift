#if os(macOS)
import AppKit
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

open class STMessageLineAnnotation: STLineAnnotation {

    public enum AnnotationKind {
        case info
        case warning
        case error
    }

    open var id: String
    open var location: NSTextLocation
    public let message: AttributedString
    public let kind: AnnotationKind

    public init(id: String, message: AttributedString, kind: AnnotationKind, location: NSTextLocation) {
        self.id = id
        self.message = message
        self.kind = kind
        self.location = location
    }
}
