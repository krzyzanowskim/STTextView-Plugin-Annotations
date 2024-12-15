import AppKit
import SwiftUI
import STTextView

import STAnnotationsPlugin

final class ViewController: NSViewController, STAnnotationsDataSource {

    @ViewLoading
    private var annotationsPlugin: STAnnotationsPlugin

    @ViewLoading
    private var textView: STTextView

    var textViewAnnotations: [any STLineAnnotation] = [] {
        didSet {
            annotationsPlugin.reloadAnnotations()
        }
    }

    override func loadView() {
        let scrollView = STTextView.scrollableTextView()
        self.textView = scrollView.documentView as! STTextView
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
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)

        let defaultParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        defaultParagraphStyle.lineHeightMultiple = 1.2

        textView.defaultParagraphStyle = defaultParagraphStyle
        textView.highlightSelectedLine = true
        textView.showsLineNumbers = true

        textView.text = """
        
        import Foundation

        func main() {
            print("Hello World!")
        }
        """

        // add annotation
        let annotation1 = try! STMessageLineAnnotation(
            id: UUID().uuidString,
            message: AttributedString(markdown: "Swift Foundation framework"),
            kind: .info,
            location: textView.textLayoutManager.location(textView.textLayoutManager.documentRange.location, offsetBy: 17)!
        )

        let annotation2 = try! STMessageLineAnnotation(
            id: UUID().uuidString,
            message: AttributedString(markdown: "**ERROR**: Missing \" at the end of the string literal"),
            kind: .error,
            location: textView.textLayoutManager.location(textView.textLayoutManager.documentRange.location, offsetBy: 56)!
        )

        textViewAnnotations += [annotation1, annotation2]
    }
}
