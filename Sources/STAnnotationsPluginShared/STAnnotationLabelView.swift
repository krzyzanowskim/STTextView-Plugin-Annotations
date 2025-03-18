//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import SwiftUI
import Foundation
import STTextView

public struct STAnnotationLabelView: View {
    @Environment(\.colorScheme) private var colorScheme

    private let text: Text
    private let annotation: any STLineAnnotation
    private let action: (any STLineAnnotation) -> Void
    private let color: Color

    public init(_ text: Text, annotation: any STLineAnnotation, color: Color, action: @escaping (any STLineAnnotation) -> Void) {
        self.text = text
        self.action = action
        self.annotation = annotation
        self.color = color
    }

    public var body: some View {
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
                    Group {
                        Image(systemName: "octagon")
                            .symbolVariant(.fill)
                            .foregroundStyle(color).brightness(-0.4)

                        Image(systemName: "xmark.octagon")
                            .foregroundStyle(.background)
                    }.compositingGroup()
                }
                .shadow(color: color, radius: 1)
            }
            .buttonStyle(.plain)
        }
        .labelStyle(
            AnnotationLabelStyle()
        )
        .background(
            ZStack {
                ContainerRelativeShape()
                    .fill(color)
                    .background(.background)

                ContainerRelativeShape()
                    .stroke(color)
            }
        )
        .containerShape(
            RoundedRectangle(cornerRadius: 2, style: .circular)
        )
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
                .foregroundStyle(.background)
                .frame(width: 1)
                .frame(maxHeight: .infinity)
                .padding(.vertical, 0.5)

            configuration.title
                .padding(.leading, 4)
                .padding(.trailing, 16)
                .lineLimit(1)
                .truncationMode(.tail)
                .textSelection(.enabled)
        }
    }
}
