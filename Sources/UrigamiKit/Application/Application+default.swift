//
//  Application+default.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//

import AppKit
import UniformTypeIdentifiers

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
