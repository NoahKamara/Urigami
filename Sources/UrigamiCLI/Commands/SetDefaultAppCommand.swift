//
//  File.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
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
        
        let apps = Application.find(nameOrPath)
        
        guard !apps.isEmpty else {
            console.error("Found no app '\(nameOrPath)'")
            return
        }
        
        let app = if apps.count > 1 {
            console.choose(
                "Found multiple possible apps for '\(nameOrPath)'",
                from: apps,
                display: { "\($0.name)" }
            )
        } else { apps.first! }
        
        console.info(
            "setting '\(app.name)' as default handler for \(input.kind!.displayName) '\(input.input)'"
        )
        try await app.set(rawValue: input.input, kind: input.kind!)
    }
}

