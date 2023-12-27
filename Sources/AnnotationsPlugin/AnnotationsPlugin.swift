import Cocoa
import STTextView

public class AnnotationsPlugin: STPlugin {

    /// Data Source
    private weak var dataSource: AnnotationsDataSource?
    private var reloadDataHandler: (() -> Void)?

    public init(dataSource: AnnotationsDataSource) {
        self.dataSource = dataSource
    }

    public func setUp(context: any Context) {
        context.events.onDidChangeText { [weak self] affectedRange, replacementString in
            self?.didChangeText(context: context, in: affectedRange, replacementString: replacementString)
        }

        context.events.onDidLayoutViewport { [weak self] range in
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

extension AnnotationsPlugin {

    public class Coordinator {
        private var annotationsViews: [NSView] = []
        private let parent: AnnotationsPlugin
        private let context: CoordinatorContext

        init(parent: AnnotationsPlugin, context: CoordinatorContext) {
            self.context = context
            self.parent = parent
        }

        @MainActor
        func layoutAnnotationViewsIfNeeded() {
            guard let dataSource = parent.dataSource else {
                return
            }
            
            let annotations = dataSource.textViewAnnotations()
            guard annotations.count != annotationsViews.count else {
                return
            }

            // Remove all views
            for view in annotationsViews {
                view.removeFromSuperview()
            }
            annotationsViews.removeAll()

            // Add views for annotations
            let textLayoutManager = context.textView.textLayoutManager
            for annotation in annotations {
                textLayoutManager.ensureLayout(for: NSTextRange(location: annotation.location))
                if let textLineFragment = textLayoutManager.textLineFragment(at: annotation.location) {
                    if let annotationView = dataSource.textView(context.textView, viewForLineAnnotation: annotation, textLineFragment: textLineFragment) {
                        // Set or Update view
                        context.textView.addSubview(annotationView)
                        annotationsViews.append(annotationView)
                    } else {
                        assertionFailure()
                    }
                }

            }
        }

    }

}
