import Foundation
import AppKit
import STTextView

public protocol STAnnotationsDataSource: AnyObject {

    /// View for annotation.
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> NSView?

    /// Annotations.
    ///
    /// Call `reloadData()` to notify STTextView about changes to annotations returned by this method.
    func textViewAnnotations() -> [any STLineAnnotation]
}
