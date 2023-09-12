## [STTextView](https://github.com/krzyzanowskim/STTextView) Plugin Template

This is a template repository for [STTextView](https://github.com/krzyzanowskim/STTextView) Plugin.
It consists of a Dummy Plugin implementation that is a good starting point for a new Plugin.

### Content
1. `DummyPlugin` SwiftPM package
2. Companion `DemoApp` with the setup [STTextView](https://github.com/krzyzanowskim/STTextView), ready to play with a Plugin.
    1. Add a plugin as an app dependency
    2. Add plugin to [STTextView](https://github.com/krzyzanowskim/STTextView) instance in file [EditorViewController.swift](DemoApp/EditorViewController.swift#L21)
    ```swift
    import MyPlugin

    textView.addPlugin(
      MyPlugin()
    )
    ```
