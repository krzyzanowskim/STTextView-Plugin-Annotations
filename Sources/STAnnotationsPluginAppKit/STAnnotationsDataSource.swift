import AppKit
import SwiftUI
import STTextView
import STAnnotationsPluginShared

public extension STAnnotationsDataSource {

    /// Default implementation
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> NSView? {
        guard let lineAnnotation = lineAnnotation as? STMessageLineAnnotation else {
            assertionFailure()
            return nil
        }

        return STAnnotationView(frame: proposedViewFrame) {
            STAnnotationLabelView(Text(lineAnnotation.message), annotation: lineAnnotation) { annotation in
                // Remove annotation
                // self?.annotations.removeAll(where: { $0.id == annotation.id })
            }
            .font(.body)
        }
    }
}
