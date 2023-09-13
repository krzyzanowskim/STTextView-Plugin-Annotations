import AppKit

public protocol LineAnnotation: Identifiable {
    var location: NSTextLocation { get set }
}
