//
//  File.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//

import Foundation

extension Application {
    public static func find(
        _ nameOrPath: consuming String,
        fileManager: FileManager = .default
    ) -> [Application] {
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
