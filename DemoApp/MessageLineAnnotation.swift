import Cocoa
import AnnotationsPlugin

final class MessageLineAnnotation: NSObject, LineAnnotation {
    var location: NSTextLocation
    let message: AttributedString

    init(message: AttributedString, location: NSTextLocation) {
        self.message = message
        self.location = location
    }
}
