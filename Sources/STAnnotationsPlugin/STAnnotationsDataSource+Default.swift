import SwiftUI
import STTextView

#if os(macOS)
import AppKit
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

public extension STAnnotationsDataSource {

#if os(macOS)
    /// Default implementation
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> NSView? {
        defaultAnnotationView(for: lineAnnotation, frame: proposedViewFrame)
    }
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
    /// Default implementation
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> UIView? {
        defaultAnnotationView(for: lineAnnotation, frame: proposedViewFrame)
    }
#endif
}

private extension STAnnotationsDataSource {

    /// The message annotation view the plugin draws when the data source does
    /// not provide one. Its button removes the annotation.
    func defaultAnnotationView(for lineAnnotation: any STLineAnnotation, frame: CGRect) -> STAnnotationView? {
        guard let lineAnnotation = lineAnnotation as? STMessageLineAnnotation else {
            assertionFailure()
            return nil
        }

        return STAnnotationView(frame: frame) {
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
