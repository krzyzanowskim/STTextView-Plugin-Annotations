#if os(macOS)
import AppKit

/// Surface the annotation views are added to.
///
/// Transparent to interaction: only the annotation views themselves take
/// events, so the text view underneath keeps its behaviour.
final class STAnnotationsContentView: NSView {

    override var canBecomeKeyView: Bool {
        false
    }

    override var acceptsFirstResponder: Bool {
        false
    }

    override var isFlipped: Bool {
        true
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        let result = super.hitTest(point)

        if let view = result, view != self, view.isDescendant(of: self) {
            return view
        }

        return nil
    }
}
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit

/// Surface the annotation views are added to.
///
/// Transparent to interaction: only the annotation views themselves take
/// events, so the text view underneath keeps its behaviour.
final class STAnnotationsContentView: UIView {

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
#endif
