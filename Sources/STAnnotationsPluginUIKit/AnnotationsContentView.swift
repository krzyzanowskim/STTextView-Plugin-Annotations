import UIKit

final class AnnotationsContentView: UIView {

    override var canBecomeFocused: Bool {
        false
    }

    override var canBecomeFirstResponder: Bool {
        false
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)

        if let view = result, view != self, view.isDescendant(of: self) {
            return view
        }

        return nil
    }
}
