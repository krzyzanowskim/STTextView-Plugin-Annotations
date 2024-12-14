#if os(macOS)
import AppKit
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

public enum AnnotationKind {
    case info
    case warning
    case error
}

open class MessageLineAnnotation: NSObject, STLineAnnotation {
    open var location: NSTextLocation
    public let message: AttributedString
    public let kind: AnnotationKind

    public init(message: AttributedString, kind: AnnotationKind, location: NSTextLocation) {
        self.message = message
        self.kind = kind
        self.location = location
    }
}
