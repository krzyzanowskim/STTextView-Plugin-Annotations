#if os(macOS)
import AppKit

/// The view type the platform's annotation views are built from.
typealias PlatformView = NSView
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit

/// The view type the platform's annotation views are built from.
typealias PlatformView = UIView
#endif
