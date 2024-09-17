//
//  MessageLineAnnotation.swift
//  DemoApp
//
//  Created by Cubik65536 on 2024-09-16.
//

import UIKit

import STAnnotationsPlugin

enum AnnotationKind {
    case info
    case warning
    case error
}

final class MessageLineAnnotation: NSObject, STLineAnnotation {
    var location: NSTextLocation
    let message: AttributedString
    let kind: AnnotationKind

    init(message: AttributedString, kind: AnnotationKind, location: NSTextLocation) {
        self.message = message
        self.kind = kind
        self.location = location
    }
}
