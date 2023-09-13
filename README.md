[STTextView](https://github.com/krzyzanowskim/STTextView) Annotations Plugin

## Installation

Add the plugin package as a dependency of your application, then register/add it to the STTextView instance:

```swift
import AnnotationsPlugin

// Implement AnnotationsDataSource protocol to provide annotations
annotationsPlugin = AnnotationsPlugin(dataSource: self)

textView.addPlugin(
    annotationsPlugin
)
```

Check DemoApp for reference implementation

<img width="499" alt="Screenshot 2023-09-13 at 19 00 09" src="https://github.com/krzyzanowskim/STTextView-Plugin-Annotations/assets/758033/49f6392b-fbce-47e9-a6ee-f4828c095cbd">
