import SwiftUI
import UIKit

import STTextView
import STAnnotationsPlugin
import STAnnotationsPluginShared

class ViewController: UIViewController, STAnnotationsDataSource {

    @ViewLoading
    private var textView: STTextView
    
    @ViewLoading
    private var annotationsPlugin: STAnnotationsPlugin
    
    var textViewAnnotations: [any STLineAnnotation] = [] {
        didSet {
            annotationsPlugin.reloadAnnotations()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let textView = STTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false

        let defaultParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        defaultParagraphStyle.lineHeightMultiple = 1.2

        textView.defaultParagraphStyle = defaultParagraphStyle
        textView.highlightSelectedLine = true

        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.showsLineNumbers = false

        textView.text = """
        
        import Foundation
        
        func main() {
            print("Hello World!)
        }
        """
        
        view.addSubview(textView)
        self.textView = textView
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        annotationsPlugin = STAnnotationsPlugin(dataSource: self)
        
        textView.addPlugin(
            annotationsPlugin
        )
        
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
