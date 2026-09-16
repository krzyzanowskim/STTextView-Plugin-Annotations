@_spi(Plugins) import STTextView

// TextKit 2 types come from the platform framework.
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public class STAnnotationsPlugin: STPlugin {

    /// Data Source
    private weak var dataSource: STAnnotationsDataSource?

    /// Weak on purpose: the text view owns the plugin, so holding it strongly -
    /// directly, or by capturing the plugin context in an event handler - keeps
    /// both alive forever.
    private weak var textView: STTextView?

    private var coordinator: Coordinator?

    /// Surface the annotation views live on.
    private var annotationsContentView: STAnnotationsContentView?

    public init(dataSource: STAnnotationsDataSource) {
        self.dataSource = dataSource
    }

    public func setUp(context: any Context) {
        let textView = context.textView
        self.textView = textView
        self.coordinator = context.coordinator

        let annotationsContentView = STAnnotationsContentView(frame: textView.bounds)
        annotationsContentView.attach(to: textView)
        self.annotationsContentView = annotationsContentView

        context.events.onDidChangeText { [weak self] affectedRange, replacementString in
            self?.didChangeText(in: affectedRange, replacementString: replacementString)
        }

        context.events.onDidLayoutViewport { [weak self] _ in
            self?.didLayoutViewport()
        }
    }

    public func tearDown() {
        annotationsContentView?.removeFromSuperview()
        annotationsContentView = nil
        coordinator = nil
        textView = nil
    }

    private func didChangeText(in affectedRange: NSTextRange, replacementString: String?) {

        guard let textView, let replacementString else {
            return
        }

        // Move the annotations with the text, so they stay on the line they
        // annotate. The ones the edit replaced outright are pinned to the start
        // of the edit, rather than left pointing past the end of the document.
        let textContentManager = textView.textContentManager
        let deltaCount = replacementString.utf16.count - textContentManager.offset(from: affectedRange.location, to: affectedRange.endLocation)

        for var annotation in dataSource?.textViewAnnotations ?? [] {
            if textContentManager.offset(from: affectedRange.endLocation, to: annotation.location) >= 0 {
                annotation.location = textContentManager.location(annotation.location, offsetBy: deltaCount) ?? annotation.location
            } else if textContentManager.offset(from: affectedRange.location, to: annotation.location) > 0 {
                annotation.location = affectedRange.location
            }
        }

        coordinator?.layoutAnnotationViews()
    }

    private func didLayoutViewport() {
        if let textView {
            annotationsContentView?.follow(textView)
        }
        coordinator?.layoutAnnotationViews()
    }

    public func makeCoordinator(context: CoordinatorContext) -> Coordinator {
        Coordinator(parent: self)
    }

    /// Lays out the views for the annotations the data source currently holds.
    ///
    /// Call this after changing ``STAnnotationsDataSource/textViewAnnotations``.
    /// Only annotations inside the laid out viewport get a view.
    public func reloadAnnotations() {
        coordinator?.layoutAnnotationViews()
    }
}

extension STAnnotationsPlugin {

    public class Coordinator {

        /// Weak, although the plugin owns the coordinator: makeCoordinator(context:)
        /// is public, so a caller can outlive the plugin and has to get a no-op
        /// rather than a crash.
        private weak var parent: STAnnotationsPlugin?

        init(parent: STAnnotationsPlugin) {
            self.parent = parent
        }

        @MainActor
        func layoutAnnotationViews() {
            guard let parent, let dataSource = parent.dataSource, let textView = parent.textView else {
                return
            }

            let textLayoutManager = textView.textLayoutManager

            // Only the annotations the viewport covers can be placed: outside it
            // there is no layout to position against, and forcing one is both slow
            // and provisional. The viewport carries a prefetch band already.
            let annotations = textLayoutManager.textViewportLayoutController.viewportRange.map { viewportRange in
                dataSource.textViewAnnotations.filter { annotation in
                    viewportRange.contains(annotation.location) || viewportRange.endLocation.isSame(as: annotation.location)
                }
            } ?? dataSource.textViewAnnotations

            let annotationViews = annotations.compactMap { annotation -> PlatformView? in
                guard let (textLayoutFragment, textLineFragment) = textLayoutManager.annotationLineFragment(at: annotation.location) else {
                    logger.error("No fragment for location \(annotation.location.description)?")
                    return nil
                }

                // The fragments are in textView.contentFrame coordinates.
                var lineFragmentFrame = textLayoutFragment.layoutFragmentFrame
                lineFragmentFrame.size.height = textLineFragment.typographicBounds.height

                let rightPadding: CGFloat = 24
                let x = textView.contentFrame.origin.x + lineFragmentFrame.maxX + 2 + rightPadding
                let proposedFrame = CGRect(
                    x: x,
                    y: textView.contentFrame.origin.y + lineFragmentFrame.origin.y + textLineFragment.typographicBounds.minY,
                    width: textView.annotationsTrailingEdge - x,
                    height: lineFragmentFrame.height
                ).pixelAligned

                return dataSource.textView(textView, viewForLineAnnotation: annotation, textLineFragment: textLineFragment, proposedViewFrame: proposedFrame)
            }

            parent.annotationsContentView?.setAnnotationViews(annotationViews)
        }
    }

}

private extension CGRect {

    var pixelAligned: CGRect {
        // https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/APIs/APIs.html#//apple_ref/doc/uid/TP40012302-CH5-SW9
        // NSIntegralRectWithOptions(self, [.alignMinXOutward, .alignMinYOutward, .alignWidthOutward, .alignMaxYOutward])
#if os(macOS)
        NSIntegralRectWithOptions(self, .alignAllEdgesNearest)
#else
        // NSIntegralRectWithOptions is not available in ObjC Foundation on iOS
        // "self.integral" is not the same, but for now it has to be enough
        // https://twitter.com/krzyzanowskim/status/1512451888515629063
        self.integral
#endif
    }

}
