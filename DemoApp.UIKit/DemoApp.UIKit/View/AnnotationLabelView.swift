import SwiftUI

import STTextView
import STAnnotationsPlugin

struct AnnotationLabelView : View {
    @Environment(\.colorScheme) private var colorScheme
    
    private let text: Text
    private let annotation: MessageLineAnnotation
    private let textWidth: CGFloat
    private let textHeight: CGFloat
    
    init(_ text: Text, annotation: MessageLineAnnotation, textWidth: CGFloat, textHeight: CGFloat) {
        self.text = text
        self.annotation = annotation
        self.textWidth = textWidth
        self.textHeight = textHeight
    }
    
    var body: some View {
        Label {
            text
                .foregroundColor(.primary)
                .frame(minWidth: textWidth, maxWidth: .infinity, alignment: .leading)
        } icon: {
            ZStack {
                // the way it draws bothers me
                // https://twitter.com/krzyzanowskim/status/1527723492002643969
                Image(systemName: "octagon")
                    .symbolVariant(.fill)
                    .foregroundStyle(.red)
                
                Image(systemName: "xmark.octagon")
                    .foregroundStyle(.white)
            }
            .shadow(color: annotation.kind.color, radius: 1)
        }
        .labelStyle(
            AnnotationLabelStyle()
        )
        .background(
            ZStack {
                ContainerRelativeShape()
                    .fill(annotation.kind.color)
                    .background(.background)
                
                ContainerRelativeShape()
                    .stroke(annotation.kind.color)
            }
        )
        .containerShape(
            UnevenRoundedRectangle(
                cornerRadii: RectangleCornerRadii(topLeading: 2, bottomLeading: 2),
                style: .circular
            )
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
