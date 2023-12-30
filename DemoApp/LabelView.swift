//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import SwiftUI
import Foundation
import STTextView
import AnnotationsPlugin

struct LabelView<T: LineAnnotation>: View {
    let message: AttributedString
    let action: (T) -> Void
    let lineAnnotation: T

    var body: some View {
        Label {
            Text(message)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } icon: {
            Button {
                action(lineAnnotation)
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
        .background(Color.yellow)
        .clipShape(RoundedRectangle(cornerRadius:4))
        .labelStyle(AnnotationLabelStyle())
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
