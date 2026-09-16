import STTextView

#if os(macOS)
import AppKit

typealias PlatformView = NSView
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit

typealias PlatformView = UIView
#endif

/// Surface the annotation views are added to.
///
/// Transparent to interaction: only the annotation views themselves take
/// events, so the text view underneath keeps its behaviour.
final class STAnnotationsContentView: PlatformView {

#if os(macOS)
    override var canBecomeKeyView: Bool { false }
    override var acceptsFirstResponder: Bool { false }
    override var isFlipped: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? {
        annotationView(hitBy: super.hitTest(point))
    }
#else
    override var canBecomeFocused: Bool { false }
    override var canBecomeFirstResponder: Bool { false }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        annotationView(hitBy: super.hitTest(point, with: event))
    }
#endif

    private func annotationView(hitBy view: PlatformView?) -> PlatformView? {
        guard let view, view != self, view.isDescendant(of: self) else {
            return nil
        }

        return view
    }
}

// MARK: - Platform differences

extension STAnnotationsContentView {

    /// Adds the surface to `textView`, covering it as it resizes.
    func attach(to textView: STTextView) {
#if os(macOS)
        wantsLayer = true
        autoresizingMask = [.height, .width]
        textView.addSubview(self)
#else
        translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: textView.topAnchor),
            leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            widthAnchor.constraint(equalTo: textView.widthAnchor),
            heightAnchor.constraint(equalTo: textView.heightAnchor)
        ])
#endif
    }

    /// Keeps the surface over the text view after a viewport layout.
    func follow(_ textView: STTextView) {
#if os(macOS)
        frame = textView.bounds
#endif
        // On iOS the constraints from attach(to:) already do this.
    }

    func setAnnotationViews(_ annotationViews: [PlatformView]) {
#if os(macOS)
        subviews = annotationViews
#else
        subviews.forEach { $0.removeFromSuperview() }
        annotationViews.forEach(addSubview)
#endif
    }
}

extension STTextView {

    /// Where an annotation view has to stop on the trailing side.
    var annotationsTrailingEdge: CGFloat {
#if os(macOS)
        visibleRect.maxX
#else
        textInputView.frame.maxX
#endif
    }
}
