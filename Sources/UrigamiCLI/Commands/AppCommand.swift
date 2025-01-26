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
            print("Found no app '\(nameOrPath)'. \n try a relative or absolute path")
            return
        }
        
        let app = apps[0]
        let detailOptions = detailOptions.options
        
        console.output(
            try appDetail(app, options: detailOptions)
        )
        //
        //        if apps.count > 1 {
        //            let restApps = apps.dropFirst()
        //            print("""
        //            Found \(restApps.count) alternate possibilit\(apps.count > 1 ? "ies" : "y") for '\(nameOrPath)'.
        //            \(restApps.map({ "\n - \($0)" }))
        //            use a relative or absolute path to be more precise
        //            """)
        //        }
    }
}

func appDetail(_ app: Application, options: AppDetailSections) throws -> ConsoleRepresentable {
    let info: InfoPlist!
    
    var detailContent = [ConsoleText]()
    
    // MARK: Metadata
    var appContent: [ConsoleText] = [
        "Path: '\(app.url.path(), style: .value)'"
    ]
    
    do {
        info = try app.info()
    } catch {
        print("Failed to read app info: \(error)")
        return ConsoleBox(
            style: .init(symbols: .arc, style: .warning),
            decorations: [.topLeft: "Application"],
            content: appContent.joined(separator: "\n")
        )
    }
    
    appContent.append("Identifier: '\(info.identifier, style: .value)'")
    
    if let displayName = info.name {
        appContent.append("Display Name: '\(displayName, style: .value)'")
    }
    
    if let version = info.version {
        appContent.append("Version: '\(version, style: .value)'")
    }
    
    
    detailContent.append(
        ConsoleBox(
            style: .init(symbols: .arc, style: .warning),
            decorations: [
                .topLeft: "Application",
                .topRight: info.name ?? info.identifier
            ],
            content: appContent.joined(separator: "\n")
        ).consoleRepresentation()
    )
    
    // MARK: Exported Types
    if options.contains(.exportedTypes), let types = info.exportedTypes {
        var content = [ConsoleText]()
        
        for type in types {
            var documentTypeText: ConsoleText = """
            Identifier: '\(type.identifier ?? "-", style: .value)'
            """
            
            if let iconLegacy = type.iconLegacy {
                documentTypeText.appendLine("""
                Icon (legacy): '\(iconLegacy)'
                """)
            }
            
            if let icons = type.icons {
                documentTypeText.appendLine("""
                Icons: 
                 - Background: \(icons.backgroundName, style: .value)
                 - Badge: \(icons.backgroundName, style: .value)
                 - Text: \(icons.backgroundName, style: .value)
                """)
            }
            
            if type.conformsToTypes?.isEmpty != false {
                documentTypeText.appendLine("Conforming Types: None")
            } else if type.conformsToTypes?.count == 1 {
                documentTypeText.appendLine("""
                Conforming Type: '\(type.conformsToTypes!.first!, style: .value)'
                """)
            } else {
                let contentTypeIds: ConsoleText = type
                    .conformsToTypes!
                    .map({ " - '\($0, style: .value)'" })
                    .joined(separator: "\n")
                
                documentTypeText.appendLine("""
                Conforming Types:
                \(contentTypeIds)
                """)
            }
            
            if let equivalentTypes = type.equivalentTypes {
                var content = [ConsoleText]()
                
                if let extensions = equivalentTypes.extensions {
                    if extensions.count > 1 {
                        content.append("Extensions: ")
                        content
                            .append(
                                extensions
                                    .map({ " - '\($0, style: .value)'"})
                                    .joined(separator: "\n")
                            )
                    } else {
                        content.append(
                            "Extensions: '\(extensions.first!, style: .value)'"
                        )
                    }
                }
                
                if let mimeTypes = equivalentTypes.mimeTypes {
                    if mimeTypes.count > 1 {
                        content.append("Mime-Types: ")
                        content
                            .append(
                                mimeTypes
                                    .map({ " - '\($0, style: .value)'"})
                                    .joined(separator: "\n")
                            )
                    } else {
                        content.append(
                            "Mime-Types: '\(mimeTypes.first!, style: .value)'"
                        )
                    }
                }
                
                documentTypeText.appendLine(content.joined(separator: "\n"))
            }
            
            content.append(ConsoleBox(
                style: .init(symbols: .arc),
                decorations: [
                    .topLeft: type.description ?? type.identifier ?? "Unknown"
                ],
                content: documentTypeText
            ).consoleRepresentation())
        }
        
        detailContent.append(ConsoleBox(
            style: .init(symbols: .arc),
            decorations: [.topLeft: "Exported Types"],
            content: content.joined(separator: "\n")
        ).consoleRepresentation())
    }
    
    // MARK: Imported Types
    if options.contains(.importedTypes), let types = info.importedTypes {
        var content = [ConsoleText]()
        
        for type in types {
            var documentTypeText: ConsoleText = """
            Identifier: '\(type.identifier ?? "-", style: .value)'
            """
            
            if let iconLegacy = type.iconLegacy {
                documentTypeText.appendLine("""
                Icon (legacy): '\(iconLegacy)'
                """)
            }
            
            if let icons = type.icons {
                documentTypeText.appendLine("""
                Icons: 
                 - Background: \(icons.backgroundName, style: .value)
                 - Badge: \(icons.backgroundName, style: .value)
                 - Text: \(icons.backgroundName, style: .value)
                """)
            }
            
            if type.conformsToTypes?.isEmpty != false {
                documentTypeText.appendLine("Conforming Types: None")
            } else if type.conformsToTypes?.count == 1 {
                documentTypeText.appendLine("""
                Conforming Type: '\(type.conformsToTypes!.first!, style: .value)'
                """)
            } else {
                let contentTypeIds: ConsoleText = type
                    .conformsToTypes!
                    .map({ " - '\($0, style: .value)'" })
                    .joined(separator: "\n")
                
                documentTypeText.appendLine("""
                Conforming Types:
                \(contentTypeIds)
                """)
            }
            
            if let equivalentTypes = type.equivalentTypes {
                var content = [ConsoleText]()
                
                if let extensions = equivalentTypes.extensions {
                    if extensions.count > 1 {
                        content.append("Extensions: ")
                        content
                            .append(
                                extensions
                                    .map({ " - '\($0, style: .value)'"})
                                    .joined(separator: "\n")
                            )
                    } else {
                        content.append(
                            "Extensions: '\(extensions.first!, style: .value)'"
                        )
                    }
                }
                
                if let mimeTypes = equivalentTypes.mimeTypes {
                    if mimeTypes.count > 1 {
                        content.append("Mime-Types: ")
                        content
                            .append(
                                mimeTypes
                                    .map({ " - '\($0, style: .value)'"})
                                    .joined(separator: "\n")
                            )
                    } else {
                        content.append(
                            "Mime-Types: '\(mimeTypes.first!, style: .value)'"
                        )
                    }
                }
                
                documentTypeText.appendLine(content.joined(separator: "\n"))
            }
            
            content.append(ConsoleBox(
                style: .init(symbols: .arc),
                decorations: [
                    .topLeft: type.description ?? type.identifier ?? "Unknown"
                ],
                content: documentTypeText
            ).consoleRepresentation())
        }
        
        detailContent.append(ConsoleBox(
            style: .init(symbols: .arc),
            decorations: [.topLeft: "Imported Types"],
            content: content.joined(separator: "\n")
        ).consoleRepresentation())
    }


    // MARK: Documents
    if options.contains(.documents), let documentTypes = info.documentTypes {
        var documentContent = [ConsoleText]()
        
        for type in documentTypes {
            var documentTypeText: ConsoleText = """
            Name: '\(type.name ?? "", style: .value)'
            Handler Role: '\(type.role.map(\.rawValue) ?? "-", style: .value)'
            Handler rank: '\(type.handlerRank.map(\.rawValue) ?? "-", style: .value)'
            """
            
            if let icon = type.icon {
                documentTypeText.appendLine("""
                Icon: \(icon)
                """)
            }
            
            if type.contentTypeIdentifiers?.isEmpty != false {
                documentTypeText.appendLine("Type Identifiers: -")
            } else if type.contentTypeIdentifiers?.count == 1 {
                documentTypeText.appendLine("""
                Type Identifiers: '\(type.contentTypeIdentifiers!.first!, style: .value)'
                """)
            } else {
                let contentTypeIds: ConsoleText = type
                    .contentTypeIdentifiers!
                    .map({ " - '\($0, style: .value)'" })
                    .joined(separator: "\n")
                
                documentTypeText.appendLine("""
                Type Identifier:
                \(contentTypeIds)
                """)
            }
            
            documentContent.append(ConsoleBox(
                style: .init(symbols: .arc),
                decorations: [
                    .topLeft: type.name ?? type.contentTypeIdentifiers!.first ?? "Unnamed"
                ],
                content: documentTypeText
            ).consoleRepresentation())
        }
        
        detailContent.append(ConsoleBox(
            style: .init(symbols: .arc),
            decorations: [.topLeft: "Document Types"],
            content: documentContent.joined(separator: "\n")
        ).consoleRepresentation())
    }
    
    // MARK: URL
    if options.contains(.urls), let urlTypes = info.urlTypes {
        var documentContent = [ConsoleText]()
        
        for type in urlTypes {
            var content: ConsoleText = """
            Identifier: '\(type.identifier, style: .value)'
            Handler Role: '\(type.role.map(\.rawValue) ?? "-", style: .value)'
            """
            
            if let icon = type.icon {
                content.appendLine("""
                Icon: \(icon)
                """)
            }
            
            if type.schemes.isEmpty != false {
                content.appendLine("Schemes: -")
            } else if type.schemes.count == 1 {
                content.appendLine("""
                Schemes: '\(type.schemes.first!, style: .value)'
                """)
            } else {
                let contentTypeIds: ConsoleText = type
                    .schemes
                    .map({ " - '\($0, style: .value)'" })
                    .joined(separator: "\n")
                
                content.appendLine("""
                Type Identifier:
                \(contentTypeIds)
                """)
            }
            
            documentContent.append(ConsoleBox(
                style: .init(symbols: .arc),
                decorations: [
                    .topLeft: type.identifier
                ],
                content: content
            ).consoleRepresentation())
        }
        
        detailContent.append(ConsoleBox(
            style: .init(symbols: .arc),
            decorations: [.topLeft: "URL Types"],
            content: documentContent.joined(separator: "\n")
        ).consoleRepresentation())
    }
    
    return detailContent.joined(separator: "\n\n")
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

