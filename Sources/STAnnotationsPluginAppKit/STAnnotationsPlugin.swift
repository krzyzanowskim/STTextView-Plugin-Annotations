import Cocoa
import SwiftUI
import STTextView
import STAnnotationsPluginShared

public class STAnnotationsPlugin: STPlugin {

    /// Data Source
    private weak var dataSource: STAnnotationsDataSource?
    private var reloadDataHandler: (() -> Void)?

    // Annotations surface view. Add annotations to this view.
    private var annotationsContentView: STAnnotationsContentView!

    public init(dataSource: STAnnotationsDataSource) {
        self.dataSource = dataSource
    }

    public func setUp(context: any Context) {
        self.annotationsContentView = STAnnotationsContentView(frame: context.textView.frame)
        annotationsContentView.wantsLayer = true
        annotationsContentView.autoresizingMask = [.height, .width]
        context.textView.addSubview(annotationsContentView)

        context.events.onDidChangeText { [weak self] affectedRange, replacementString in
            self?.didChangeText(context: context, in: affectedRange, replacementString: replacementString)
        }

        context.events.onDidLayoutViewport { [weak self] range in
            self?.annotationsContentView.frame = context.textView.frame
            self?.didLayoutViewport(context: context, range)
        }

        reloadDataHandler = {
            context.coordinator.layoutAnnotationViewsIfNeeded()
        }
    }

    private func didChangeText(context: any Context, in affectedRange: NSTextRange, replacementString: String?) {

        guard let replacementString else {
            return
        }

        // Adjust annotation location based on the edit
        // The annotation location have to update its absolut position
        // to accomodate insert/delete change in the document, to visually
        // stay in the same place
        let affectedCount = context.textView.textContentManager.offset(from: affectedRange.location, to: affectedRange.endLocation)
        let replacementCount = replacementString.utf16.count
        let deltaCount = replacementCount - affectedCount

        for var annotation in dataSource?.textViewAnnotations ?? [] where context.textView.textContentManager.offset(from: affectedRange.endLocation, to: annotation.location) >= 0 {
            annotation.location = context.textView.textContentManager.location(annotation.location, offsetBy: deltaCount) ?? annotation.location
        }

        // Because annotation location position changed
        // we need to reposition all views that may be
        // affected by the text change
        context.coordinator.layoutAnnotationViewsIfNeeded()
    }

    private func didLayoutViewport(context: any Context, _ range: NSTextRange?) {
        context.coordinator.layoutAnnotationViewsIfNeeded()
    }

    public func makeCoordinator(context: CoordinatorContext) -> Coordinator {
        Coordinator(parent: self, context: context)
    }

    /// Reloads the rows and sections of the table view.
    ///
    /// Performs the layout for annotation views.
    public func reloadAnnotations() {
        reloadDataHandler?()
    }
}

extension STAnnotationsPlugin {

    public class Coordinator {

        class State {
            var lastAnnotationIDs: Set<STLineAnnotation.ID> = []
        }

        private let parent: STAnnotationsPlugin
        private let context: CoordinatorContext
        private var state: State = State()

        init(parent: STAnnotationsPlugin, context: CoordinatorContext) {
            self.context = context
            self.parent = parent
        }

        @MainActor
        func layoutAnnotationViewsIfNeeded() {
            guard let dataSource = parent.dataSource else {
                return
            }

            let annotations = dataSource.textViewAnnotations

            if state.lastAnnotationIDs == Set(annotations.map(\.id)) {
                // skip if annotations did not change
                return
            }

            state.lastAnnotationIDs = Set(annotations.map(\.id))

            // Add views for annotations
            let textLayoutManager = context.textView.textLayoutManager

            var annotationViews: [NSView] = []
            for annotation in annotations {
                textLayoutManager.ensureLayout(for: NSTextRange(location: annotation.location))
                // textLayoutFragment is in the textView.contentFrame coordinates
                if let textLayoutFragment = textLayoutManager.textLayoutFragment(for: annotation.location),
                    let textLineFragment = textLayoutFragment.textLineFragment(at: annotation.location) {

                    var lineFragmentFrame = textLayoutFragment.layoutFragmentFrame
                    lineFragmentFrame.size.height = textLineFragment.typographicBounds.height

                    let rightPadding: CGFloat = 24

                    // Calculate proposed annotation view frame
                    let x = context.textView.contentFrame.origin.x + lineFragmentFrame.maxX + 2 + rightPadding
                    let proposedFrame = CGRect(
                        x: x,
                        y: context.textView.contentFrame.origin.y + lineFragmentFrame.origin.y + textLineFragment.typographicBounds.minY,
                        width: context.textView.visibleRect.maxX - x,
                        height: lineFragmentFrame.height
                    ).pixelAligned

                    if let annotationView = dataSource.textView(context.textView, viewForLineAnnotation: annotation, textLineFragment: textLineFragment, proposedViewFrame: proposedFrame) {
                        annotationViews.append(annotationView)
                    }
                } else {
                    logger.error("No fragment for location \(annotation.location.description)?")
                }
            }

            parent.annotationsContentView.subviews = annotationViews
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


