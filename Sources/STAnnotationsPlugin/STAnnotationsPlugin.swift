import Cocoa
import STTextView

public class STAnnotationsPlugin: STPlugin {

    /// Data Source
    private weak var dataSource: STAnnotationsDataSource?
    private var reloadDataHandler: (() -> Void)?

    // Annotations surface view. Add annotations to this view.
    private var annotationsContentView: AnnotationsContentView!

    public init(dataSource: STAnnotationsDataSource) {
        self.dataSource = dataSource
    }

    public func setUp(context: any Context) {
        self.annotationsContentView = AnnotationsContentView(frame: context.textView.frame)
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

        for var annotation in dataSource?.textViewAnnotations() ?? [] where context.textView.textContentManager.offset(from: affectedRange.endLocation, to: annotation.location) >= 0 {
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
        private let parent: STAnnotationsPlugin
        private let context: CoordinatorContext

        init(parent: STAnnotationsPlugin, context: CoordinatorContext) {
            self.context = context
            self.parent = parent
        }

        @MainActor
        func layoutAnnotationViewsIfNeeded() {
            guard let dataSource = parent.dataSource else {
                return
            }

            // Add views for annotations
            var annotationViews: [NSView] = []
            let textLayoutManager = context.textView.textLayoutManager
            for annotation in dataSource.textViewAnnotations() {
                textLayoutManager.ensureLayout(for: NSTextRange(location: annotation.location))
                if let textLineFragment = textLayoutManager.textLineFragment(at: annotation.location) {

                    // Calculate proposed annotation view frame
                    let segmentFrame = context.textView.textLayoutManager.textSegmentFrame(at: annotation.location, type: .standard, options: [.upstreamAffinity])!
                    let proposedFrame = CGRect(
                        x: segmentFrame.maxX + 1.4,
                        y: segmentFrame.minY,
                        width: context.textView.visibleRect.maxX - segmentFrame.maxX,
                        height: textLineFragment.typographicBounds.height
                    )
                    
                    if let annotationView = dataSource.textView(context.textView, viewForLineAnnotation: annotation, textLineFragment: textLineFragment, proposedViewFrame: proposedFrame) {
                        annotationViews.append(annotationView)
                    }
                }
            }

            parent.annotationsContentView.subviews = annotationViews
        }
    }

}
