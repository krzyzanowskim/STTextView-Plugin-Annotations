//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import AppKit
import SwiftUI

/// Covenience annotation view implementation provided by the framework.
open class STAnnotationView: NSView {

    public init<Content: View>(frame: CGRect, @ViewBuilder content: () -> Content) {
        super.init(frame: .zero)
        
        let hostingView = NSHostingView(rootView: content())
        hostingView.autoresizingMask = [.height, .width]
        addSubview(hostingView)

        self.frame = frame
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
