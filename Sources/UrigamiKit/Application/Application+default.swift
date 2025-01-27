//
//  Application+default.swift
//
//  Copyright © 2024 Noah Kamara.
//

import AppKit
import UniformTypeIdentifiers

// MARK: Get Default

public extension Application {
    static func `default`(
        opening utType: UTType,
        workspace: NSWorkspace = .shared
    ) -> Application? {
        workspace
            .urlForApplication(toOpen: utType)
            .map(Application.init(url:))
    }

    static func `default`(
        opening url: URL,
        workspace: NSWorkspace = .shared
    ) -> Application? {
        workspace
            .urlForApplication(toOpen: url)
            .map(Application.init(url:))
    }

    static func all(
        opening utType: UTType,
        workspace: NSWorkspace = .shared
    ) -> [Application] {
        workspace
            .urlsForApplications(toOpen: utType)
            .map(Application.init(url:))
    }

    static func all(
        opening url: URL,
        workspace: NSWorkspace = .shared
    ) -> [Application] {
        workspace
            .urlsForApplications(toOpen: url)
            .map(Application.init(url:))
    }
}

// MARK: Set Defaults

public extension Application {
    func set(opening utType: UTType, workspace: NSWorkspace = .shared) async throws {
        try await workspace
            .setDefaultApplication(at: self.url, toOpen: utType)
    }

    func set(opening url: URL, workspace: NSWorkspace = .shared) async throws {
        try await workspace
            .setDefaultApplication(at: self.url, toOpenURLsWithScheme: url.scheme!)
    }
}
