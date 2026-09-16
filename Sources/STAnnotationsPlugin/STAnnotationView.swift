//  Created by Marcin Krzyzanowski
//  iOS/iPadOS version by Qian Qian (Cubik65536), adapted from the macOS one.
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import SwiftUI

#if os(macOS)
import AppKit

/// Covenience annotation view implementation provided by the framework.
open class STAnnotationView: NSView {

    public init<Content: View>(frame: CGRect, @ViewBuilder content: () -> Content) {
        super.init(frame: frame)

        let hostingView = NSHostingView(rootView: content())
        hostingView.frame = bounds
        hostingView.autoresizingMask = [.height, .width]
        addSubview(hostingView)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(bounds, cursor: .arrow)
    }
}
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit

/// Covenience annotation view implementation provided by the framework.
open class STAnnotationView: UIView {

    public init<Content: View>(frame: CGRect, @ViewBuilder content: () -> Content) {
        super.init(frame: frame)

        let hostingView = _UIHostingView(rootView: content())
        hostingView.frame = bounds
        hostingView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(hostingView)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
