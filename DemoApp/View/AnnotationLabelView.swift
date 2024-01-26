//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import SwiftUI
import Foundation
import STTextView
import STAnnotationsPlugin

struct AnnotationLabelView : View {
    @Environment(\.colorScheme) private var colorScheme

    private let text: Text
    private let annotation: MessageLineAnnotation
    private let action: (MessageLineAnnotation) -> Void

    init(_ text: Text, annotation: MessageLineAnnotation, action: @escaping (MessageLineAnnotation) -> Void) {
        self.text = text
        self.action = action
        self.annotation = annotation
    }

    var body: some View {
        Label {
            text
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } icon: {
            Button {
                action(annotation)
            } label: {
                ZStack {
                    // the way it draws bothers me
                    // https://twitter.com/krzyzanowskim/status/1527723492002643969
                    Image(systemName: "octagon")
                        .symbolVariant(.fill)
                        .foregroundStyle(.red)

                    Image(systemName: "xmark.octagon")
                        .foregroundStyle(.white)
                }
                .shadow(radius: 1)
            }
            .buttonStyle(.plain)
        }
        .background(
            annotation.kind.color.background(Color.white)
        )
        .clipShape(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 2, bottomLeading: 2), style: .circular))
        .labelStyle(AnnotationLabelStyle())
        .shadow(radius: 1, x: 0.3, y: 0.5)
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
        }
    }
}

private extension AnnotationKind {
    var color: Color {
        switch self {
        case .info:
            Color.accentColor.opacity(0.2)
        case .warning:
            Color.yellow.opacity(0.2)
        case .error:
            Color.red.opacity(0.2)
        }
    }

}
