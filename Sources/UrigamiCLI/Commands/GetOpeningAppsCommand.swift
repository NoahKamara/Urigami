//
//  GetOpeningAppsCommand.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
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
        let kind = input.kind!
        let rawValue = input.input

        if list {
            try listApps(kind: kind, rawValue: rawValue)
        } else {
            try defaultApp(kind: kind, rawValue: rawValue)
        }
    }

    func defaultApp(kind: InputKind, rawValue: String) throws {
        let console = Terminal()
        let app = try Application.default(rawValue: rawValue, kind: kind)

        guard let app else {
            console.warning("No default app for \(kind.displayName) '\(rawValue)'")
            try? listApps(kind: kind, rawValue: rawValue)
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
