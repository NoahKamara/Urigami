//
//  UrigamiCLI.swift
//
//  Copyright © 2024 Noah Kamara.
//

import AppKit
import ArgumentParser
import Foundation
import UniformTypeIdentifiers

@main
struct UrigamiCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "urigami",
        abstract: "a command line utility for getting or setting default apps",
        version: "0.1.1",
        shouldDisplay: true,
        subcommands: [
            GetOpeningAppsCommand.self,
            AppInfoCommand.self,
            SetOpeningAppCommand.self,
        ]
    )
}
