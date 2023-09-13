import AppKit
import STTextView

import AnnotationsPlugin

class EditorViewController: NSViewController {

    private var annotationsPlugin = AnnotationsPlugin()
    private var textView: STTextView!
    private var annotations: [MessageLineAnnotation] = [] {
        didSet {
            // TODO: reload annotations
        }
    }

    override func loadView() {
        let scrollView = STTextView.scrollableTextView()
        self.textView = scrollView.documentView as? STTextView
        self.view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame.size = CGSize(width: 500, height: 500)

        annotationsPlugin.dataSource = self

        textView.addPlugin(
           annotationsPlugin
        )

        textView.backgroundColor = .controlBackgroundColor
        textView.font = .monospacedSystemFont(ofSize: 0, weight: .regular)

        textView.string = """
        import Foundation

        func hello() {
            print("Hello World!")
        }
        """

        // add annotation
        do {
            let stringRange = textView.string.startIndex..<textView.string.endIndex
            if let ocurrenceRange = textView.string.range(of: "Foundation", range: stringRange) {
                let characterLocationOffset = textView.string.distance(from: textView.string.startIndex, to: ocurrenceRange.upperBound)
                let annotation = try! MessageLineAnnotation(
                    message: AttributedString(markdown: "**TODO**: to cry _or_ not to cry"),
                    location: textView.textLayoutManager.location(textView.textLayoutManager.documentRange.location, offsetBy: characterLocationOffset)!
                )
                annotations.append(annotation)
            }
        }
    }
}

import SwiftUI

extension EditorViewController: AnnotationsDataSource {

    private func removeAnnotation(_ annotation: STLineAnnotation) {
        annotations.removeAll(where: { $0 == annotation })
    }

    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: STLineAnnotation, textLineFragment: NSTextLineFragment) -> NSView? {
        guard let myLineAnnotation = lineAnnotation as? MessageLineAnnotation else {
            return nil
        }

        let messageFont = NSFont.preferredFont(forTextStyle: .body)

        let decorationView = STAnnotationLabelView(
            annotation: myLineAnnotation,
            label: AnnotationLabelView(
                message: myLineAnnotation.message,
                action: { [weak self] annotation in
                    self?.removeAnnotation(annotation)
                },
                lineAnnotation: lineAnnotation
            )
            .font(Font(messageFont))
        )

        // Position

        let segmentFrame = textView.textLayoutManager.textSegmentFrame(at: lineAnnotation.location, type: .standard)!
        let annotationHeight = min(textLineFragment.typographicBounds.height, textView.font?.boundingRectForFont.height ?? 24)

        decorationView.frame = CGRect(
            x: segmentFrame.maxX,
            y: segmentFrame.minY + (segmentFrame.height - annotationHeight),
            width: textView.bounds.width - segmentFrame.maxX,
            height: annotationHeight
        )
        return decorationView
    }

    func textViewAnnotations() -> [STLineAnnotation] {
        annotations
    }

}
