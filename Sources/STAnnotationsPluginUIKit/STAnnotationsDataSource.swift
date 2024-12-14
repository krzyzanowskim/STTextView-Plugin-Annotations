import UIKit
import SwiftUI
import STTextView
import STAnnotationsPluginShared

public extension STAnnotationsDataSource {

    /// Default implementation
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> UIView? {
        guard let lineAnnotation = lineAnnotation as? STMessageLineAnnotation else {
            assertionFailure()
            return nil
        }

        return STAnnotationView(frame: proposedViewFrame) {
            STAnnotationLabelView(Text(lineAnnotation.message), annotation: lineAnnotation, color: lineAnnotation.kind.color) { [weak self] annotation in
                // Remove annotation
                self?.textViewAnnotations.removeAll(where: { $0.id == annotation.id })
            }
            .font(.body)
        }
    }
}

private extension STMessageLineAnnotation.AnnotationKind {
    var color: Color {
        switch self {
        case .info:
            Color.accentColor.opacity(0.2)
        case .warning:
            Color.yellow.opacity(0.2)
        case .error:
            Color.red.opacity(0.2)
        }
    }
}
