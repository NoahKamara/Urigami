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
        console.output(try appDetail(app, options: .none))
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
            console.output(try appDetail(app, options: .none))
        }
    }
}


import AppKit
import UniformTypeIdentifiers

fileprivate extension Application {
    static func `default`(
        rawValue: String,
        kind: InputKind,
        workspace: NSWorkspace = .shared
    ) throws -> Application? {
        switch kind {
        case .uri:
            let scheme = rawValue.prefix(while: { $0 != ":" }).map(String.init)
            
            let url = URL(string: rawValue) ?? URL(string: "\(scheme)://")
            
            guard let url else {
                throw ValidationError("Neither URL nor scheme: '\(rawValue)'")
            }
            
            return workspace
                .urlForApplication(toOpen: url)
                .map(Application.init(url:))
            
        case .mime:
            guard let utType = UTType(mimeType: rawValue) else {
                throw ValidationError("Unknown mime type '\(rawValue)'")
            }
            return workspace
                .urlForApplication(toOpen: utType)
                .map(Application.init(url:))
            
        case .fileExtension:
            let utType = UTType(filenameExtension: String(rawValue.trimmingPrefix(".")))
            
            guard let utType else {
                throw ValidationError("Unknown file extension '\(rawValue)'")
            }
            
            return workspace
                .urlForApplication(toOpen: utType)
                .map(Application.init(url:))
            
        case .identifier:
            guard let utType = UTType(rawValue) else {
                throw ValidationError("Unknown type identifier '\(rawValue)'")
            }
            
            return workspace
                .urlForApplication(toOpen: utType)
                .map(Application.init(url:))
        }
    }

    static func all(
        rawValue: String,
        kind: InputKind,
        workspace: NSWorkspace = .shared
    ) throws -> [Application] {
        switch kind {
        case .uri:
            let scheme = rawValue.prefix(while: { $0 != ":" }).map(String.init)
            
            let url = URL(string: rawValue) ?? URL(string: "\(scheme)://")
            
            guard let url else {
                throw ValidationError("Neither URL nor scheme: '\(rawValue)'")
            }
            
            return workspace
                .urlsForApplications(toOpen: url)
                .map(Application.init(url:))
            
        case .mime:
            guard let utType = UTType(mimeType: rawValue) else {
                throw ValidationError("Unknown mime type '\(rawValue)'")
            }
            return workspace
                .urlsForApplications(toOpen: utType)
                .map(Application.init(url:))
            
        case .fileExtension:
            let utType = UTType(filenameExtension: String(rawValue.trimmingPrefix(".")))
            
            guard let utType else {
                throw ValidationError("Unknown file extension '\(rawValue)'")
            }
            
            return workspace
                .urlsForApplications(toOpen: utType)
                .map(Application.init(url:))
            
        case .identifier:
            guard let utType = UTType(rawValue) else {
                throw ValidationError("Unknown type identifier '\(rawValue)'")
            }
            
            return workspace
                .urlsForApplications(toOpen: utType)
                .map(Application.init(url:))
        }
    }
}
