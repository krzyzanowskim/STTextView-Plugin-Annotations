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
