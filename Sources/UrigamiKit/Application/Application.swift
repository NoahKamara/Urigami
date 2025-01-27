//
//  Application.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public struct Application: CustomStringConvertible {
    public var description: String {
        "\(self.name) '\(self.url.path())'"
    }

    /// The name of the application
    /// > the last path component without the extension
    public var name: String {
        String(
            self.url
                .lastPathComponent
                .prefix((self.url.lastPathComponent.count - self.url.pathExtension.count) + 1)
        )
    }

    public let url: URL

    public init(url: URL) {
        precondition(url.isFileURL, "must be file url")
        self.url = url
    }

    public func bundle() -> Bundle? {
        Bundle(url: self.url)
    }
}
