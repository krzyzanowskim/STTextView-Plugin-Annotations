import Foundation
import AppKit
import STTextView

public protocol AnnotationsDataSource: AnyObject {

    /// View for annotaion
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any LineAnnotation, textLineFragment: NSTextLineFragment) -> NSView?

    /// Annotations.
    ///
    /// Call `reloadData()` to notify STTextView about changes to annotations returned by this method.
    func textViewAnnotations() -> [any LineAnnotation]
}
