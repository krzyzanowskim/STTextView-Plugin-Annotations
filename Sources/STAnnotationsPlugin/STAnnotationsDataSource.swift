import Foundation
import STTextView

#if os(macOS)
import AppKit
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

@MainActor
public protocol STAnnotationsDataSource: AnyObject {

    /// View for annotation.
    ///
    /// A default implementation is provided; implement this to draw something else.
#if os(macOS)
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> NSView?
#endif
#if os(iOS) || targetEnvironment(macCatalyst)
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> UIView?
#endif

    /// Annotations.
    ///
    /// Call ``STAnnotationsPlugin/reloadAnnotations()`` after changing this
    /// property, to lay out the views for the new set of annotations.
    var textViewAnnotations: [any STLineAnnotation] { get set }
}
