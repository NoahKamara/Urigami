//
//  SetDefaultAppCommand.swift
//
//  Copyright © 2024 Noah Kamara.
//

import ArgumentParser
import UrigamiKit

struct SetOpeningAppCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "setdefault",
        abstract: "find the default app(s) for the input"
    )

    @OptionGroup
    var input: Input

    @Argument(help: "name or path to the app")
    var nameOrPath: String

    func run() async throws {
        let console = Terminal()

        let apps = Application.find(self.nameOrPath)

        guard !apps.isEmpty else {
            console.error("Found no app '\(self.nameOrPath)'")
            return
        }

        let app = if apps.count > 1 {
            console.choose(
                "Found multiple possible apps for '\(self.nameOrPath)'",
                from: apps,
                display: { "\($0.name)" }
            )
        } else { apps.first! }

        console.info(
            "setting '\(app.name)' as default handler for \(self.input.kind!.displayName) '\(self.input.input)'"
        )
        try await app.set(rawValue: self.input.input, kind: self.input.kind!)
        try console.output(app.detail(.none))
    }
}
