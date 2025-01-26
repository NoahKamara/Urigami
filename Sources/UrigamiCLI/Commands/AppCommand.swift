//
//  File.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//

import Foundation
import ArgumentParser
import UrigamiKit


struct AppDetailSections: OptionSet {
    let rawValue: UInt8
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    static let documents     = Self(rawValue: 1 << 0)
    static let exportedTypes = Self(rawValue: 1 << 1)
    static let importedTypes = Self(rawValue: 1 << 2)
    static let urls = Self(rawValue: 1 << 3)
    
    static let types: Self   = [exportedTypes, importedTypes]
    static let all: Self   = [documents, exportedTypes, importedTypes, urls]
    static let none: Self   = []
}

struct AppDetailSectionOptions: ParsableArguments {
    @Flag(help: .init("all details", discussion: "equivalent to specifying all detail flags"))
    var detail = false
    
    @Flag(help: .init("declared types", discussion: "equivalent to specify --exported-utis and --imported-utis"))
    var uti = false
    
    @Flag(help: "exported ut-types")
    var exportUTI = false
    
    @Flag(help: "imported ut-types")
    var importUTI = false
    
    @Flag(name: .long, help: "document types")
    var doc = false
    
    @Flag(help: "declared URL types")
    var url = false
    
    var options: AppDetailSections {
        var options = AppDetailSections()
        
        if detail {
            return AppDetailSections.all
        }
        
        if uti { options.insert(.types) }
        else if exportUTI { options.insert(.exportedTypes) }
        else if importUTI { options.insert(.importedTypes) }
        
        if doc { options.insert(.documents) }
        
        if url { options.insert(.urls) }
        
        return options
    }
}

struct AppCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "app")
    
    @Argument
    var nameOrPath: String
    
    @OptionGroup(title: "Configure which details to show")
    var detailOptions: AppDetailSectionOptions
    
    func run() throws {
        let console = Terminal()
        
        let apps = Application.find(nameOrPath)
        
        guard !apps.isEmpty else {
            console.error("Found no app '\(nameOrPath)'. \n try a relative or absolute path")
            return
        }
        
        if apps.count == 1 {
            let app = apps[0]
            let detailOptions = detailOptions.options
            
            console.output(try app.detail(detailOptions))
        } else {
            console.warning("Found multiple possible matches for '\(nameOrPath)'. \n try a relative or absolute path to be more precise")
            for app in apps {
                console.output(try app.detail(.none))
            }
        }
    }
}



struct FileSearch {
    enum SearchMode {
        case shallow
        case deep
    }
    
    struct Source {
        let filePath: String
        let mode: SearchMode
    }
    
    var sources: [Source]
    
    init(sources: [Source]) {
        self.sources = sources
    }
    
    mutating func addSource(_ filePath: String, mode: SearchMode = .shallow) {
        sources.append(.init(filePath: filePath, mode: mode))
    }
}

import AppKit

extension Application {
    public func info(fileManager: FileManager = .default) throws -> InfoPlist {
        let fileURL = url.appending(components: "Contents", "Info.plist")
        let data = try Data(contentsOf: fileURL)
        let decoder = PropertyListDecoder()
        return try decoder.decode(InfoPlist.self, from: data)
    }
}

extension Application {
    static func find(_ nameOrPath: consuming String, fileManager: FileManager = .default) -> [Application] {
        // is a path
        if nameOrPath.contains("/") {
            let fileURL = if nameOrPath.starts(with: "/") {
                URL(filePath: nameOrPath)
            } else {
                URL.currentDirectory().appending(path: nameOrPath)
            }
            
            guard fileManager.fileExists(atPath: fileURL.path()) else {
                return []
            }
            
            return [Application(url: fileURL)]
        }
        
        let searchDirectories = [
            URL.currentDirectory(),
            URL(filePath: "/System/Applications"),
            URL.applicationDirectory,
        ]
        var results = [Application]()
        for directory in searchDirectories {
            let searchURLs = [
                directory.appending(component: nameOrPath),
                directory.appending(component: nameOrPath.appending(".app"))
            ]
            
            for searchURL in searchURLs {
                if fileManager.fileExists(atPath: searchURL.path()) {
                    results.append(Application(url: searchURL))
                }
            }
        }
        
        return results
    }
}

