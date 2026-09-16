#if os(macOS)
import AppKit
#endif
#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

public protocol STLineAnnotation {
    typealias ID = String
    var id: ID { get }
    var location: any NSTextLocation { get set }
}

extension NSTextLocation {

    /// Whether two locations point at the same place in the document.
    ///
    /// `NSTextLocation` is a protocol, so `==` is not available on existentials.
    func isSame(as other: any NSTextLocation) -> Bool {
        compare(other) == .orderedSame
    }
}
