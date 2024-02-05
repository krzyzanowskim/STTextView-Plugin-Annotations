[STTextView](https://github.com/krzyzanowskim/STTextView) Annotations Plugin

## Installation

Add the plugin package as a dependency of your application, then register/add it to the STTextView instance:

```swift
import STAnnotationsPlugin

// Implement AnnotationsDataSource protocol to provide annotations
let plugin = STAnnotationsPlugin(dataSource: self)

// Add/register the plugin in the STTextView instance
textView.addPlugin(plugin)
```

Check DemoApp for a reference implementation.

![Screenshot 2024-02-05 at 02 23 26](https://github.com/krzyzanowskim/STTextView-Plugin-Annotations/assets/758033/9f77d1ea-097d-4325-b8ab-dac1da9a8ad1)
