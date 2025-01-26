//
//  File.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//

import ArgumentParser
import UrigamiKit

struct InfoCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "info")
    
    @OptionGroup
    var input: Input
    
    @Flag(name: .shortAndLong, help: "list all registerd applications")
    var list = false
    
    func run() throws {
        let kind = input.kind!
        let rawValue = input.input
        
        if self.list {
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
        console.output(try app.detail(.none))
        console.info("use `urigami app \(app.url.path())` to view details")
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
            console.output(try app.detail(.none))
        }
    }
}


import AppKit
import UniformTypeIdentifiers




