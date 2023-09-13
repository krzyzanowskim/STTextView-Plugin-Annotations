import Cocoa
import STTextView

public struct AnnotationsPlugin: STPlugin {

    /// Data Source
    public weak var dataSource: AnnotationsDataSource?

    public init() { }

    public func setUp(context: Context) {
        context.events.onDidChangeText { affectedRange, replacementString in
            didChangeText(context: context, in: affectedRange, replacementString: replacementString)
        }
        context.events.onDidLayoutViewport { range in
            didLayoutViewport(context: context, range)
        }
    }

    private func didChangeText(context: Context, in affectedRange: NSTextRange, replacementString: String?) {
        // Because annotation location position changed
        // we need to reposition all views that may be
        // affected by the text change
        context.coordinator.layoutAnnotationViewsIfNeeded(forceLayout: true)
    }

    private func didLayoutViewport(context: Context, _ range: NSTextRange?) {
        context.coordinator.layoutAnnotationViewsIfNeeded(forceLayout: true)
    }

    public func makeCoordinator(context: CoordinatorContext) -> Coordinator {
        Coordinator(parent: self, context: context)
    }
}

extension AnnotationsPlugin {

    public class Coordinator {
        private let annotationViewMap: NSMapTable<STLineAnnotation, NSView>
        private let parent: AnnotationsPlugin
        private let context: CoordinatorContext

        init(parent: AnnotationsPlugin, context: CoordinatorContext) {
            self.context = context
            self.parent = parent
            self.annotationViewMap = .strongToWeakObjects()
        }

        func layoutAnnotationViewsIfNeeded(forceLayout: Bool = false) {
            guard let dataSource = parent.dataSource else {
                return
            }

            let oldAnnotations = {
                var result: [STLineAnnotation] = []
                result.reserveCapacity(self.annotationViewMap.count)

                let enumerator = self.annotationViewMap.keyEnumerator()
                while let key = enumerator.nextObject() as? STLineAnnotation {
                    result.append(key)
                }
                return result
            }()

            let newAnnotations = dataSource.textViewAnnotations()
            let change = Set(oldAnnotations).symmetricDifference(Set(newAnnotations))
            if forceLayout || !change.isEmpty {

                for element in change {
                    if oldAnnotations.contains(element) {
                        annotationViewMap.object(forKey: element)?.removeFromSuperview()
                        annotationViewMap.removeObject(forKey: element)
                    }
                }

                let textLayoutManager = context.textView.textLayoutManager
                for annotation in newAnnotations {
                    textLayoutManager.ensureLayout(for: NSTextRange(location: annotation.location))
                    if let textLineFragment = textLayoutManager.textLineFragment(at: annotation.location) {
                        if let annotationView = dataSource.textView(context.textView, viewForLineAnnotation: annotation, textLineFragment: textLineFragment) {
                            // Set or Update view
                            annotationViewMap.object(forKey: annotation)?.removeFromSuperview()
                            annotationViewMap.setObject(annotationView, forKey: annotation)
                            context.textView.addSubview(annotationView)
                        } else {
                            assertionFailure()
                        }
                    }
                }
            }
        }

    }

}

//// Reloads the rows and sections of the table view.
////
//// Performs the layout for annotation views.
//public func reloadData() {
//    layoutAnnotationViewsIfNeeded(forceLayout: true)
//}
//
///// Layout annotations views if annotations changed since last time.
/////
///// Called from layout()
//internal func layoutAnnotationViewsIfNeeded(forceLayout: Bool = false) {
//    guard let dataSource = dataSource else {
//        return
//    }
//
//    let oldAnnotations = {
//        var result: [STLineAnnotation] = []
//        result.reserveCapacity(self.annotationViewMap.count)
//
//        let enumerator = self.annotationViewMap.keyEnumerator()
//        while let key = enumerator.nextObject() as? STLineAnnotation {
//            result.append(key)
//        }
//        return result
//    }()
//
//    let newAnnotations = dataSource.textViewAnnotations(self)
//    let change = Set(oldAnnotations).symmetricDifference(Set(newAnnotations))
//    if forceLayout || !change.isEmpty {
//
//        for element in change {
//            if oldAnnotations.contains(element) {
//                annotationViewMap.object(forKey: element)?.removeFromSuperview()
//                annotationViewMap.removeObject(forKey: element)
//            }
//        }
//
//        for annotation in newAnnotations {
//            textLayoutManager.ensureLayout(for: NSTextRange(location: annotation.location))
//            if let textLineFragment = textLayoutManager.textLineFragment(at: annotation.location) {
//                if let annotationView = dataSource.textView(self, viewForLineAnnotation: annotation, textLineFragment: textLineFragment) {
//                    // Set or Update view
//                    annotationViewMap.object(forKey: annotation)?.removeFromSuperview()
//                    annotationViewMap.setObject(annotationView, forKey: annotation)
//                    addSubview(annotationView)
//                } else {
//                    assertionFailure()
//                }
//            }
//        }
//    }
//}
