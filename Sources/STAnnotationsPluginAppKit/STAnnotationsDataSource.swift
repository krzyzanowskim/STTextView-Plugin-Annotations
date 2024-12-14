import AppKit
import SwiftUI
import STTextView
import STAnnotationsPluginShared

public extension STAnnotationsDataSource where Self: AnyObject {

    /// Default implementation
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> NSView? {
        guard let lineAnnotation = lineAnnotation as? STMessageLineAnnotation else {
            assertionFailure()
            return nil
        }

        return STAnnotationView(frame: proposedViewFrame) {
            STAnnotationLabelView(Text(lineAnnotation.message), annotation: lineAnnotation, color: lineAnnotation.kind.color) { [weak self] lineAnnotation in
                self?.textViewAnnotations.removeAll(where: { $0.id == lineAnnotation.id })
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
