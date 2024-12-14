import Foundation
import STTextView

#if os(macOS)
import AppKit
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

public protocol STAnnotationsDataSource: AnyObject {

    /// View for annotation.
#if os(macOS)
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> NSView?
#endif
#if os(iOS) || targetEnvironment(macCatalyst)
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> UIView?
#endif

    /// Annotations.
    ///
    /// Call `reloadData()` to notify STTextView about changes to annotations returned by this method.
    var textViewAnnotations: [any STLineAnnotation] { get set }
}
