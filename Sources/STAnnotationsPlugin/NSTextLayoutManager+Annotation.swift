import Foundation
import STTextView

#if os(macOS)
import AppKit
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

extension NSTextLayoutManager {

    /// The layout fragment and line fragment that place an annotation at `location`.
    ///
    /// There is no layout fragment at the document end location, so an annotation
    /// pinned there - the natural place for "unexpected end of file" - would never
    /// get a view. That position belongs to the last fragment's last line fragment,
    /// which is the extra line fragment when the document ends with a line break.
    func annotationLineFragment(at location: any NSTextLocation) -> (NSTextLayoutFragment, NSTextLineFragment)? {
        if textLayoutFragment(for: location) == nil {
            ensureLayout(for: NSTextRange(location: location))
        }

        if let textLayoutFragment = textLayoutFragment(for: location),
           let textLineFragment = textLayoutFragment.textLineFragment(at: location) {
            return (textLayoutFragment, textLineFragment)
        }

        guard location.isSame(as: documentRange.endLocation) else {
            return nil
        }

        var lastTextLayoutFragment: NSTextLayoutFragment?
        enumerateTextLayoutFragments(from: documentRange.endLocation, options: .reverse) { textLayoutFragment in
            lastTextLayoutFragment = textLayoutFragment
            return false
        }

        guard let lastTextLayoutFragment,
              let textLineFragment = lastTextLayoutFragment.textLineFragments.last else {
            return nil
        }

        return (lastTextLayoutFragment, textLineFragment)
    }
}
