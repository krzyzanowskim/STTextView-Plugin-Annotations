[STTextView](https://github.com/krzyzanowskim/STTextView) Annotations Plugin

## Installation

Add the plugin package as a dependency of your application, then register/add it to the STTextView instance:

```swift
import STAnnotationsPlugin

// Implement AnnotationsDataSource protocol to provide annotations
let plugin = STAnnotationsPlugin(dataSource: self)

// Add/register plugin in the STTextView instance
textView.addPlugin(plugin)
```

Check DemoApp for reference implementation

<img width="499" alt="Demo9" src="https://github.com/krzyzanowskim/STTextView-Plugin-Annotations/assets/758033/ce1e2050-977e-4be9-b78c-81023d66b4f2">
