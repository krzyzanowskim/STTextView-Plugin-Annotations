//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import AppKit
import SwiftUI

/// Covenience annotation view implementation provided by the framework.
open class AnnotationView: NSView {

    private struct ContentView<Content: View>: View {
        @Environment(\.isEnabled) private var isEnabled
        var content: Content

        init(_ content: Content) {
            self.content = content
        }

        var body: some View {
            content
                .disabled(!isEnabled)
        }
    }

    public init<Content: View>(_ content: Content) {
        super.init(frame: .zero)
        
        let hostingView = NSHostingView(rootView: ContentView(content))
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
