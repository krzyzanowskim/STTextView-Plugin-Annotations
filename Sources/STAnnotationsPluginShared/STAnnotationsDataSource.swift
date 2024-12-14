import Foundation
import STTextView

#if os(macOS)
import AppKit
public typealias View = NSView
#endif
#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
public typealias View = UIView
#endif


public protocol STAnnotationsDataSource: AnyObject {

    /// View for annotation.
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> View?

    /// Annotations.
    ///
    /// Call `reloadData()` to notify STTextView about changes to annotations returned by this method.
    func textViewAnnotations() -> [any STLineAnnotation]
}
