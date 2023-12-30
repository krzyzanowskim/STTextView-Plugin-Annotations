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
                .labelStyle(AnnotationLabelStyle())
                .disabled(!isEnabled)
        }
    }

    private struct AnnotationLabelStyle: LabelStyle {
        @Environment(\.colorScheme) private var colorScheme

        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .center, spacing: 0) {
                configuration.icon
                    .padding(.horizontal, 4)
                    .controlSize(.large)
                    .contentShape(Rectangle())

                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)

                configuration.title
                    .padding(.leading, 4)
                    .padding(.trailing, 16)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    public init<Label: View>(_ content: Label) {
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
