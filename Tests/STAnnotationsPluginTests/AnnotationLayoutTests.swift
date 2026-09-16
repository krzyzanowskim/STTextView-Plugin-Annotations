import XCTest
import STTextView
@testable import STAnnotationsPlugin

#if os(macOS)
import AppKit

@MainActor
final class AnnotationLayoutTests: XCTestCase {

    final class DataSource: STAnnotationsDataSource {
        weak var plugin: STAnnotationsPlugin?
        var textViewAnnotations: [any STLineAnnotation] = [] {
            didSet { plugin?.reloadAnnotations() }
        }
    }

    struct Editor {
        let textView: STTextView
        let dataSource: DataSource
        let plugin: STAnnotationsPlugin
        let pluginID: STPluginIdentifier
        let window: NSWindow
    }

    private func makeEditor(_ text: String) -> Editor {
        let scrollView = STTextView.scrollableTextView()
        scrollView.frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        let textView = scrollView.documentView as! STTextView
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)

        let window = NSWindow(contentRect: scrollView.frame, styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = scrollView

        let dataSource = DataSource()
        let plugin = STAnnotationsPlugin(dataSource: dataSource)
        dataSource.plugin = plugin
        let pluginID = textView.addPlugin(plugin)

        textView.text = text
        textView.layoutSubtreeIfNeeded()
        return Editor(textView: textView, dataSource: dataSource, plugin: plugin, pluginID: pluginID, window: window)
    }

    private func annotationViews(in textView: STTextView) -> [NSView] {
        textView.subviews
            .filter { String(describing: type(of: $0)).contains("STAnnotationsContentView") }
            .flatMap(\.subviews)
    }

    private func offset(of location: any NSTextLocation, in textView: STTextView) -> Int {
        let contentManager = textView.textContentManager
        return contentManager.offset(from: contentManager.documentRange.location, to: location)
    }

    private func annotation(at offset: Int, in textView: STTextView, id: String = "a") -> STMessageLineAnnotation {
        let textLayoutManager = textView.textLayoutManager
        return STMessageLineAnnotation(
            id: id,
            message: AttributedString("note"),
            kind: .error,
            location: textLayoutManager.location(textLayoutManager.documentRange.location, offsetBy: offset)!
        )
    }

    func testAnnotationFollowsTextInsertedAbove() {
        let editor = makeEditor("line0\nline1\nline2\nline3\nline4")
        let textView = editor.textView
        let annotation = annotation(at: 18, in: textView)
        editor.dataSource.textViewAnnotations = [annotation]
        textView.layoutSubtreeIfNeeded()
        let before = annotationViews(in: textView).first?.frame.minY

        textView.replaceCharacters(in: NSRange(location: 0, length: 0), with: "inserted\n")
        textView.layoutSubtreeIfNeeded()

        XCTAssertEqual(offset(of: annotation.location, in: textView), 27)
        XCTAssertGreaterThan(annotationViews(in: textView).first!.frame.minY, before!)
    }

    func testAnnotationFollowsTextDeletedAbove() {
        let editor = makeEditor("line0\nline1\nline2\nline3\nline4")
        let textView = editor.textView
        let annotation = annotation(at: 18, in: textView)
        editor.dataSource.textViewAnnotations = [annotation]
        textView.layoutSubtreeIfNeeded()

        textView.replaceCharacters(in: NSRange(location: 0, length: 6), with: "")
        textView.layoutSubtreeIfNeeded()

        XCTAssertEqual(offset(of: annotation.location, in: textView), 12)
    }

    func testAnnotationInsideDeletedRangeIsPinnedToTheEdit() {
        let editor = makeEditor("line0\nline1\nline2\nline3\nline4")
        let textView = editor.textView
        let annotation = annotation(at: 18, in: textView)
        editor.dataSource.textViewAnnotations = [annotation]
        textView.layoutSubtreeIfNeeded()

        // Delete the range that contains the annotation.
        textView.replaceCharacters(in: NSRange(location: 12, length: 12), with: "")
        textView.layoutSubtreeIfNeeded()

        let documentLength = offset(of: textView.textContentManager.documentRange.endLocation, in: textView)
        XCTAssertLessThanOrEqual(offset(of: annotation.location, in: textView), documentLength,
                                 "annotation location must stay inside the document")
        XCTAssertEqual(annotationViews(in: textView).count, 1, "annotation must remain visible")
    }

    func testAnnotationAtEndOfDocumentIsPlaced() {
        for text in ["line one\nline two", "line one\nline two\n"] {
            let editor = makeEditor(text)
            let textView = editor.textView
            editor.dataSource.textViewAnnotations = [
                STMessageLineAnnotation(id: "end", message: AttributedString("eof"), kind: .error,
                                        location: textView.textLayoutManager.documentRange.endLocation)
            ]
            textView.layoutSubtreeIfNeeded()
            XCTAssertEqual(annotationViews(in: textView).count, 1, "no view for \(text.debugDescription)")
        }
    }

    func testOnlyAnnotationsInsideTheViewportGetViews() {
        let editor = makeEditor((0..<400).map { "line \($0)" }.joined(separator: "\n"))
        let textView = editor.textView
        editor.dataSource.textViewAnnotations = (0..<40).map { annotation(at: $0 * 9, in: textView, id: "a\($0)") }
        textView.layoutSubtreeIfNeeded()

        let views = annotationViews(in: textView)
        XCTAssertGreaterThan(views.count, 0)
        XCTAssertLessThan(views.count, 40, "annotations outside the viewport must not be laid out")
    }

    func testRemovingThePluginRemovesItsViews() {
        let editor = makeEditor("line one\nline two")
        let textView = editor.textView
        editor.dataSource.textViewAnnotations = [annotation(at: 3, in: textView)]
        textView.layoutSubtreeIfNeeded()
        XCTAssertEqual(annotationViews(in: textView).count, 1)

        textView.removePlugin(editor.pluginID)

        XCTAssertEqual(annotationViews(in: textView).count, 0)
        XCTAssertFalse(textView.subviews.contains { String(describing: type(of: $0)).contains("STAnnotationsContentView") })
    }

    func testTextViewIsReleasedWhileThePluginIsInstalled() {
        weak var weakTextView: STTextView?

        autoreleasepool {
            let editor = makeEditor("line one\nline two")
            weakTextView = editor.textView
            editor.window.contentView = NSView()
            editor.window.orderOut(nil)
        }

        for _ in 0..<3 {
            autoreleasepool { RunLoop.current.run(until: Date().addingTimeInterval(0.05)) }
        }

        XCTAssertNil(weakTextView, "the plugin must not keep the text view alive")
    }
}
#endif
