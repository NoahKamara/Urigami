//
//  Application.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//

import Foundation

public struct Application: CustomStringConvertible {
    public var description: String {
        return "\(name) '\(url.path())'"
    }

    /// The name of the application
    /// > the last path component without the extension
    public var name: String {
        String(
            url
                .lastPathComponent
                .prefix((url.lastPathComponent.count - url.pathExtension.count) + 1)
        )
    }

    public let url: URL

    public init(url: URL) {
        precondition(url.isFileURL, "must be file url")
        self.url = url
    }

    public func bundle() -> Bundle? {
        Bundle(url: url)
    }
}
