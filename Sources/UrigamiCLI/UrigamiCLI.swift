// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import AppKit
import ArgumentParser
import Foundation
import UniformTypeIdentifiers

@main
struct UrigamiCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "urigami",
        abstract: "a command line utility for getting or setting default apps",
        version: "0.1.0",
        shouldDisplay: true,
        subcommands: [
            GetOpeningAppsCommand.self,
            AppInfoCommand.self,
            SetOpeningAppCommand.self
        ]
    )
}

