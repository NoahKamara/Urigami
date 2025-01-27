//
//  Application+info.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public extension Application {
    func info(fileManager _: FileManager = .default) throws -> InfoPlist {
        let fileURL = url.appending(components: "Contents", "Info.plist")
        let data = try Data(contentsOf: fileURL)
        let decoder = PropertyListDecoder()
        return try decoder.decode(InfoPlist.self, from: data)
    }
}
