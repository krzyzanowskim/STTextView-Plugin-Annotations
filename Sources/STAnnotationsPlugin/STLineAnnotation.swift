#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol STLineAnnotation {
    typealias ID = String
    var id: ID { get }
    var location: any NSTextLocation { get set }
}
