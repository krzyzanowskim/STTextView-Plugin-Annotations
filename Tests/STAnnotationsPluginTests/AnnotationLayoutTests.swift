import XCTest
import STTextView
@testable import STAnnotationsPlugin

#if os(macOS)
import AppKit
#else
import UIKit
#endif

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
        let pluginID: STPluginIdentifier

        /// Takes the text view out of its window, so only the test holds it.
        let detachFromWindow: () -> Void
    }

    private func makeEditor(_ text: String) -> Editor {
        let frame = CGRect(x: 0, y: 0, width: 600, height: 400)

#if os(macOS)
        let scrollView = STTextView.scrollableTextView()
        scrollView.frame = frame
        let textView = scrollView.documentView as! STTextView

        let window = NSWindow(contentRect: frame, styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = scrollView
        let detachFromWindow = {
            window.contentView = NSView()
            window.orderOut(nil)
        }
#else
        let textView = STTextView(frame: frame)
        let window = UIWindow(frame: frame)
        window.addSubview(textView)
        window.makeKeyAndVisible()
        let detachFromWindow = {
            textView.removeFromSuperview()
            window.isHidden = true
        }
#endif

        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)

        let dataSource = DataSource()
        let plugin = STAnnotationsPlugin(dataSource: dataSource)
        dataSource.plugin = plugin
        let pluginID = textView.addPlugin(plugin)

        textView.text = text
        textView.layoutNow()

        return Editor(textView: textView, dataSource: dataSource, pluginID: pluginID, detachFromWindow: detachFromWindow)
    }

    private func annotationViews(in textView: STTextView) -> [PlatformView] {
        textView.subviews
            .filter { $0 is STAnnotationsContentView }
            .flatMap(\.subviews)
    }

    private func hasAnnotationsContentView(_ textView: STTextView) -> Bool {
        textView.subviews.contains { $0 is STAnnotationsContentView }
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

    // MARK: - Following the text

    func testAnnotationFollowsTextInsertedAbove() {
        let editor = makeEditor("line0\nline1\nline2\nline3\nline4")
        let textView = editor.textView
        let annotation = annotation(at: 18, in: textView)
        editor.dataSource.textViewAnnotations = [annotation]
        textView.layoutNow()
        let before = annotationViews(in: textView).first?.frame.minY

        textView.replaceCharacters(in: NSRange(location: 0, length: 0), with: "inserted\n")
        textView.layoutNow()

        XCTAssertEqual(offset(of: annotation.location, in: textView), 27)
        XCTAssertGreaterThan(annotationViews(in: textView).first!.frame.minY, before!)
    }

    func testAnnotationFollowsTextDeletedAbove() {
        let editor = makeEditor("line0\nline1\nline2\nline3\nline4")
        let annotation = annotation(at: 18, in: editor.textView)
        editor.dataSource.textViewAnnotations = [annotation]
        editor.textView.layoutNow()

        editor.textView.replaceCharacters(in: NSRange(location: 0, length: 6), with: "")
        editor.textView.layoutNow()

        XCTAssertEqual(offset(of: annotation.location, in: editor.textView), 12)
    }

    func testAnnotationInsideDeletedRangeIsPinnedToTheEdit() {
        let editor = makeEditor("line0\nline1\nline2\nline3\nline4")
        let textView = editor.textView
        let annotation = annotation(at: 18, in: textView)
        editor.dataSource.textViewAnnotations = [annotation]
        textView.layoutNow()

        // Delete the range that contains the annotation.
        textView.replaceCharacters(in: NSRange(location: 12, length: 12), with: "")
        textView.layoutNow()

        let documentLength = offset(of: textView.textContentManager.documentRange.endLocation, in: textView)
        XCTAssertLessThanOrEqual(offset(of: annotation.location, in: textView), documentLength,
                                 "annotation location must stay inside the document")
        XCTAssertEqual(annotationViews(in: textView).count, 1, "annotation must remain visible")
    }

    // MARK: - Placement

    func testAnnotationAtEndOfDocumentIsPlaced() {
        for text in ["line one\nline two", "line one\nline two\n"] {
            let editor = makeEditor(text)
            let textView = editor.textView
            editor.dataSource.textViewAnnotations = [
                STMessageLineAnnotation(id: "end", message: AttributedString("eof"), kind: .error,
                                        location: textView.textLayoutManager.documentRange.endLocation)
            ]
            textView.layoutNow()
            XCTAssertEqual(annotationViews(in: textView).count, 1, "no view for \(text.debugDescription)")
        }
    }

    func testOnlyAnnotationsInsideTheViewportGetViews() {
        let editor = makeEditor((0..<400).map { "line \($0)" }.joined(separator: "\n"))
        let textView = editor.textView
        editor.dataSource.textViewAnnotations = (0..<40).map { annotation(at: $0 * 9, in: textView, id: "a\($0)") }
        textView.layoutNow()

        let views = annotationViews(in: textView)
        XCTAssertGreaterThan(views.count, 0)
        XCTAssertLessThan(views.count, 40, "annotations outside the viewport must not be laid out")
    }

    // MARK: - Lifecycle

    func testRemovingThePluginRemovesItsViews() {
        let editor = makeEditor("line one\nline two")
        let textView = editor.textView
        editor.dataSource.textViewAnnotations = [annotation(at: 3, in: textView)]
        textView.layoutNow()
        XCTAssertEqual(annotationViews(in: textView).count, 1)

        textView.removePlugin(editor.pluginID)

        XCTAssertEqual(annotationViews(in: textView).count, 0)
        XCTAssertFalse(hasAnnotationsContentView(textView))
    }

    func testTextViewIsReleasedWhileThePluginIsInstalled() {
        weak var weakTextView: STTextView?

        autoreleasepool {
            let editor = makeEditor("line one\nline two")
            weakTextView = editor.textView
            editor.detachFromWindow()
        }

        for _ in 0..<3 {
            autoreleasepool { RunLoop.current.run(until: Date().addingTimeInterval(0.05)) }
        }

        XCTAssertNil(weakTextView, "the plugin must not keep the text view alive")
    }
}

private extension STTextView {

    /// Lays out now, so a test can read the annotation views the pass produced.
    func layoutNow() {
#if os(macOS)
        layoutSubtreeIfNeeded()
#else
        layoutIfNeeded()
#endif
    }
}
