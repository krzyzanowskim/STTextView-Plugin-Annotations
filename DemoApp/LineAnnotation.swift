import Cocoa
import AnnotationsPlugin

final class LineAnnotation: STLineAnnotation {
    let message: AttributedString

    init(message: AttributedString, location: NSTextLocation) {
        self.message = message
        super.init(location: location)
    }
}
