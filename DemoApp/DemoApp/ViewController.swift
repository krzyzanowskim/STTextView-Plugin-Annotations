//
//  ViewController.swift
//  DemoApp
//
//  Created by Cubik65536 on 2024-09-16.
//

import SwiftUI
import UIKit

import STTextView
import STAnnotationsPlugin

class ViewController: UIViewController {
    
    @ViewLoading
    private var textView: STTextView!
    
    private var annotationsPlugin: STAnnotationsPlugin!
    private var annotations: [MessageLineAnnotation] = [] {
        didSet {
            annotationsPlugin.reloadAnnotations()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textView = STTextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.highlightSelectedLine = true
        textView.textDelegate = self
        
        textView.font = UIFont.monospacedSystemFont(ofSize: 0, weight: .regular)
        textView.showsLineNumbers = true
        textView.showsInvisibleCharacters = false
        textView.gutterView?.drawSeparator = true
        
        textView.text = """
                import Foundation
                
                func main() {
                    print("Hello World!")
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
        let annotation1 = try! MessageLineAnnotation(
            message: AttributedString(markdown: "Swift Foundation framework"),
            kind: .info,
            location: textView.textLayoutManager.location(textView.textLayoutManager.documentRange.location, offsetBy: 17)!
        )
        
        let annotation2 = try! MessageLineAnnotation(
            message: AttributedString(markdown: "**ERROR**: Missing \" at the end of the string literal"),
            kind: .error,
            location: textView.textLayoutManager.location(textView.textLayoutManager.documentRange.location, offsetBy: 56)!
        )
        
        annotations += [annotation1, annotation2]
        
        print("done")
    }
    
}

extension ViewController: STTextViewDelegate {
    func textViewWillChangeText(_ notification: Notification) {
    }
    
    func textViewDidChangeText(_ notification: Notification) {
    }
    
    func textViewDidChangeSelection(_ notification: Notification) {
    }
    
    func textView(_ textView: STTextView, shouldChangeTextIn affectedCharRange: NSTextRange, replacementString: String?) -> Bool {
        true
    }
    
    func textView(_ textView: STTextView, willChangeTextIn affectedCharRange: NSTextRange, replacementString: String) {
    }
    
    func textView(_ textView: STTextView, didChangeTextIn affectedCharRange: NSTextRange, replacementString: String) {
    }
    
    func textView(_ textView: STTextView, clickedOnLink link: Any, at location: any NSTextLocation) -> Bool {
        false
    }
}

extension ViewController: STAnnotationsDataSource {
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> UIView? {
        guard let lineAnnotation = lineAnnotation as? MessageLineAnnotation else {
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
