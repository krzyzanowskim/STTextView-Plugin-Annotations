#if os(macOS)
import AppKit
#endif
#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

public protocol STLineAnnotation {
    var id: String { get }
    var location: any NSTextLocation { get set }
}
