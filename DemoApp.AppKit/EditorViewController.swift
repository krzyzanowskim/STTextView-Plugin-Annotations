import AppKit
import STTextView

import STAnnotationsPlugin

final class EditorViewController: NSViewController {

    private var annotationsPlugin: STAnnotationsPlugin!
    private var textView: STTextView!
    private var annotations: [STMessageLineAnnotation] = [] {
        didSet {
            annotationsPlugin.reloadAnnotations()
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

        annotationsPlugin = STAnnotationsPlugin(dataSource: self)

        textView.addPlugin(
           annotationsPlugin
        )

        textView.backgroundColor = .controlBackgroundColor
        textView.font = .monospacedSystemFont(ofSize: 0, weight: .regular)

        let defaultParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        defaultParagraphStyle.lineHeightMultiple = 1.2

        textView.defaultParagraphStyle = defaultParagraphStyle
        textView.highlightSelectedLine = true

        textView.text = """
        import Foundation

        func main() {
            print("Hello World!")
        }
        """

        // add annotation
        let annotation1 = try! STMessageLineAnnotation(
            message: AttributedString(markdown: "Swift Foundation framework"),
            kind: .info,
            location: textView.textLayoutManager.location(textView.textLayoutManager.documentRange.location, offsetBy: 17)!
        )

        let annotation2 = try! STMessageLineAnnotation(
            message: AttributedString(markdown: "**ERROR**: Missing \" at the end of the string literal"),
            kind: .error,
            location: textView.textLayoutManager.location(textView.textLayoutManager.documentRange.location, offsetBy: 56)!
        )

        annotations += [annotation1, annotation2]
    }
}

import SwiftUI

extension EditorViewController: STAnnotationsDataSource {

    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> NSView? {
        guard let lineAnnotation = lineAnnotation as? STMessageLineAnnotation else {
            assertionFailure()
            return nil
        }

        return STAnnotationView(frame: proposedViewFrame) {
            AnnotationLabelView(Text(lineAnnotation.message), annotation: lineAnnotation) { [weak self] annotation in
                // Remove annotation
                self?.annotations.removeAll(where: { $0.id == annotation.id })
            }
            .font(.body)
        }
    }


    func textViewAnnotations() -> [any STLineAnnotation] {
        annotations
    }
}
