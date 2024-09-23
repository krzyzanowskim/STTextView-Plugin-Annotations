//  Created by Qian Qian (Cubik65536), adapted from macOS version created by Marcin Krzyzanowski to work on iOS/iPadOS.
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import UIKit
import SwiftUI

/// Covenience annotation view implementation provided by the framework.
open class STAnnotationView: UIView {

    public init<Content: View>(frame: CGRect, @ViewBuilder content: () -> Content) {
        super.init(frame: .zero)
        
        let hostingView = _UIHostingView(rootView: content())
        hostingView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(hostingView)
        
        self.frame = frame
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
