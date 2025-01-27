//
//  GetOpeningAppsCommand.swift
//
//  Copyright © 2024 Noah Kamara.
//

import ArgumentParser
import UrigamiKit

struct GetOpeningAppsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "opens",
        abstract: "find the default app(s) for the input"
    )

    @OptionGroup
    var input: Input

    @Flag(name: .shortAndLong, help: "list all registerd applications, not just the default")
    var list = false

    func run() throws {
        let kind = self.input.kind!
        let rawValue = self.input.input

        if self.list {
            try self.listApps(kind: kind, rawValue: rawValue)
        } else {
            try self.defaultApp(kind: kind, rawValue: rawValue)
        }
    }

    func defaultApp(kind: InputKind, rawValue: String) throws {
        let console = Terminal()
        let app = try Application.default(rawValue: rawValue, kind: kind)

        guard let app else {
            console.warning("No default app for \(kind.displayName) '\(rawValue)'")
            try? self.listApps(kind: kind, rawValue: rawValue)
            return
        }

        console.info("Default app for \(kind.displayName) '\(rawValue)':")
        try console.output(app.detail(.none))
        console.hint("use `urigami appinfo \"\(app.name)\"` to view details")
    }

    func listApps(kind: InputKind, rawValue: String) throws {
        let console = Terminal()
        let apps = try Application.all(rawValue: rawValue, kind: kind)

        guard !apps.isEmpty else {
            console.warning("No apps for \(kind.displayName) '\(rawValue)'")
            return
        }

        console.info("Registered Apps for \(kind.displayName) '\(rawValue)':")
        for app in apps {
            try console.output(app.detail(.none))
        }
    }
}

import AppKit
import UniformTypeIdentifiers
