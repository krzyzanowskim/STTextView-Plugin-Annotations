[STTextView](https://github.com/krzyzanowskim/STTextView) Annotations Plugin

## Installation

Add the plugin package as a dependency of your application, then register/add it to the STTextView instance:

```swift
import STAnnotationsPlugin

class AnnotationDataSource: STAnnotationsDataSource {

    // Optional. Default implementation provided.
    // func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> NSView? {
    //    // view for annotation
    // }

    var textViewAnnotations: [any STLineAnnotation] = []
}

let dataSource = AnnotationDataSource()

// Implement AnnotationsDataSource protocol to provide annotations
let plugin = STAnnotationsPlugin(dataSource: dataSource)

// Add/register the plugin in the STTextView instance
textView.addPlugin(plugin)
```

Check the Demo application (AppKit or UIKit) for a reference implementation.

![Untitled](https://github.com/user-attachments/assets/c29fb7c2-5417-4487-a67a-4e7e20758b73)

