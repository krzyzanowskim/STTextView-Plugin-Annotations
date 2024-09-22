import UIKit

public protocol STLineAnnotation: Identifiable {
    var location: NSTextLocation { get set }
}
