//
//  Application+default.swift
//
//  Copyright © 2024 Noah Kamara.
//

import AppKit
import ArgumentParser
import UniformTypeIdentifiers
import UrigamiKit

extension Application {
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
            return self.default(opening: url, workspace: workspace)

        case .mime:
            guard let utType = UTType(mimeType: rawValue) else {
                throw ValidationError("Unknown mime type '\(rawValue)'")
            }
            return self.default(opening: utType, workspace: workspace)

        case .fileExtension:
            let utType = UTType(filenameExtension: String(rawValue.trimmingPrefix(".")))

            guard let utType else {
                throw ValidationError("Unknown file extension '\(rawValue)'")
            }
            return self.default(opening: utType, workspace: workspace)

        case .identifier:
            guard let utType = UTType(rawValue) else {
                throw ValidationError("Unknown type identifier '\(rawValue)'")
            }
            return self.default(opening: utType, workspace: workspace)
        }
    }

    static func all(
        rawValue: String,
        kind: InputKind,
        workspace _: NSWorkspace = .shared
    ) throws -> [Application] {
        switch kind {
        case .uri:
            let scheme = rawValue.prefix(while: { $0 != ":" }).map(String.init)

            let url = URL(string: rawValue) ?? URL(string: "\(scheme)://")

            guard let url else {
                throw ValidationError("Neither URL nor scheme: '\(rawValue)'")
            }

            return self.all(opening: url)

        case .mime:
            guard let utType = UTType(mimeType: rawValue) else {
                throw ValidationError("Unknown mime type '\(rawValue)'")
            }
            return self.all(opening: utType)

        case .fileExtension:
            let utType = UTType(filenameExtension: String(rawValue.trimmingPrefix(".")))

            guard let utType else {
                throw ValidationError("Unknown file extension '\(rawValue)'")
            }
            return self.all(opening: utType)

        case .identifier:
            guard let utType = UTType(rawValue) else {
                throw ValidationError("Unknown type identifier '\(rawValue)'")
            }
            return self.all(opening: utType)
        }
    }

    func set(
        rawValue: String,
        kind: InputKind,
        workspace: NSWorkspace = .shared
    ) async throws {
        switch kind {
        case .uri:
            let scheme = rawValue.prefix(while: { $0 != ":" }).map(String.init)

            let url = URL(string: rawValue) ?? URL(string: "\(scheme)://")

            guard let url else {
                throw ValidationError("Neither URL nor scheme: '\(rawValue)'")
            }
            try await self.set(opening: url, workspace: workspace)

        case .mime:
            guard let utType = UTType(mimeType: rawValue) else {
                throw ValidationError("Unknown mime type '\(rawValue)'")
            }
            try await self.set(opening: utType, workspace: workspace)

        case .fileExtension:
            let utType = UTType(filenameExtension: String(rawValue.trimmingPrefix(".")))

            guard let utType else {
                throw ValidationError("Unknown file extension '\(rawValue)'")
            }
            try await self.set(opening: utType, workspace: workspace)

        case .identifier:
            guard let utType = UTType(rawValue) else {
                throw ValidationError("Unknown type identifier '\(rawValue)'")
            }
            try await self.set(opening: utType, workspace: workspace)
        }
    }
}
