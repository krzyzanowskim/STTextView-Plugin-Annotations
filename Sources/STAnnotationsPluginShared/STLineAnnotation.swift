#if os(macOS)
import AppKit
#endif
#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

public protocol STLineAnnotation: Identifiable {
    var location: NSTextLocation { get set }
}
