import Cocoa
import SwiftUI
@_spi(Plugins) import STTextView
import STAnnotationsPluginShared

public class STAnnotationsPlugin: STPlugin {

    /// Data Source
    private weak var dataSource: STAnnotationsDataSource?

    /// The text view this plugin is installed in.
    ///
    /// Deliberately weak: the text view owns the plugin, so holding the plugin
    /// context (or the text view) strongly - directly or by capturing it in one
    /// of the event handlers - would form a cycle and keep both alive forever.
    private weak var textView: STTextView?

    /// Owned by the plugin. The coordinator refers back to the plugin unowned.
    private var coordinator: Coordinator?

    // Annotations surface view. Add annotations to this view.
    private var annotationsContentView: STAnnotationsContentView?

    public init(dataSource: STAnnotationsDataSource) {
        self.dataSource = dataSource
    }

    public func setUp(context: any Context) {
        let textView = context.textView
        self.textView = textView
        self.coordinator = context.coordinator

        let annotationsContentView = STAnnotationsContentView(frame: textView.frame)
        annotationsContentView.wantsLayer = true
        annotationsContentView.autoresizingMask = [.height, .width]
        textView.addSubview(annotationsContentView)
        self.annotationsContentView = annotationsContentView

        context.events.onDidChangeText { [weak self] affectedRange, replacementString in
            self?.didChangeText(in: affectedRange, replacementString: replacementString)
        }

        context.events.onDidLayoutViewport { [weak self] range in
            self?.didLayoutViewport(range)
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

        // Adjust annotation location based on the edit
        // The annotation location have to update its absolut position
        // to accomodate insert/delete change in the document, to visually
        // stay in the same place
        let affectedCount = textView.textContentManager.offset(from: affectedRange.location, to: affectedRange.endLocation)
        let replacementCount = replacementString.utf16.count
        let deltaCount = replacementCount - affectedCount

        for var annotation in dataSource?.textViewAnnotations ?? [] where textView.textContentManager.offset(from: affectedRange.endLocation, to: annotation.location) >= 0 {
            annotation.location = textView.textContentManager.location(annotation.location, offsetBy: deltaCount) ?? annotation.location
        }

        // Because annotation location position changed
        // we need to reposition all views that may be
        // affected by the text change
        coordinator?.layoutAnnotationViewsIfNeeded()
    }

    private func didLayoutViewport(_ range: NSTextRange?) {
        if let textView {
            annotationsContentView?.frame = textView.frame
        }
        coordinator?.layoutAnnotationViewsIfNeeded()
    }

    public func makeCoordinator(context: CoordinatorContext) -> Coordinator {
        Coordinator(parent: self, context: context)
    }

    /// Reloads the rows and sections of the table view.
    ///
    /// Performs the layout for annotation views.
    public func reloadAnnotations() {
        coordinator?.layoutAnnotationViewsIfNeeded()
    }
}

extension STAnnotationsPlugin {

    public class Coordinator {

        /// The plugin owns the coordinator, so this never outlives its parent.
        private unowned let parent: STAnnotationsPlugin
        private weak var textView: STTextView?

        init(parent: STAnnotationsPlugin, context: CoordinatorContext) {
            self.parent = parent
            self.textView = context.textView
        }

        @MainActor
        func layoutAnnotationViewsIfNeeded() {
            guard let dataSource = parent.dataSource, let textView else {
                return
            }

            let textLayoutManager = textView.textLayoutManager

            // Only lay out annotations the viewport covers. Anything outside it
            // has no layout to position against, and forcing one is both slow and
            // provisional - the frame it reports changes once the text is really
            // laid out. The viewport already includes a prefetch band around the
            // visible area, so a small scroll does not need a new pass.
            let annotations = textLayoutManager.textViewportLayoutController.viewportRange.map { viewportRange in
                dataSource.textViewAnnotations.filter { annotation in
                    viewportRange.contains(annotation.location) || viewportRange.endLocation.isSame(as: annotation.location)
                }
            } ?? dataSource.textViewAnnotations

            var annotationViews: [NSView] = []
            for annotation in annotations {
                // textLayoutFragment is in the textView.contentFrame coordinates
                if let (textLayoutFragment, textLineFragment) = textLayoutManager.annotationLineFragment(at: annotation.location) {

                    var lineFragmentFrame = textLayoutFragment.layoutFragmentFrame
                    lineFragmentFrame.size.height = textLineFragment.typographicBounds.height

                    let rightPadding: CGFloat = 24

                    // Calculate proposed annotation view frame
                    let x = textView.contentFrame.origin.x + lineFragmentFrame.maxX + 2 + rightPadding
                    let proposedFrame = CGRect(
                        x: x,
                        y: textView.contentFrame.origin.y + lineFragmentFrame.origin.y + textLineFragment.typographicBounds.minY,
                        width: textView.visibleRect.maxX - x,
                        height: lineFragmentFrame.height
                    ).pixelAligned

                    if let annotationView = dataSource.textView(textView, viewForLineAnnotation: annotation, textLineFragment: textLineFragment, proposedViewFrame: proposedFrame) {
                        annotationViews.append(annotationView)
                    }
                } else {
                    logger.error("No fragment for location \(annotation.location.description)?")
                }
            }

            parent.annotationsContentView?.subviews = annotationViews
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
