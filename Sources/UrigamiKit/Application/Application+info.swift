//
//  Application+info.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
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
