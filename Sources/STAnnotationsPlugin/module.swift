import Foundation

#if os(macOS)
@_exported import STAnnotationsPluginAppKit
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
@_exported import STAnnotationsPluginUIKit
#endif

@_exported import STAnnotationsPluginShared
