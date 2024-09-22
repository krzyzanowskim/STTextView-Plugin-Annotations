import AppKit

public protocol STLineAnnotation: Identifiable {
    var location: NSTextLocation { get set }
}
