import AppKit

/// Line annotation entity.
/// Usually work with subclass that carry more information about the annotation
/// needed for the annotation view
open class STLineAnnotation: NSObject {
    /// Location in content storage
    public var location: NSTextLocation

    public init(location: NSTextLocation) {
        self.location = location
    }
}
