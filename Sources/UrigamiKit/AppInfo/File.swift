//
//  File.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public struct InfoPlist: Decodable {
    public let identifier: String
    public let name: String?
    public let packageType: String?
    public let version: String?

    /// Document types
    public let documentTypes: [BundleDocumentType]?

    /// URL types
    public let urlTypes: [BundleURLType]?

    /// Exported Type Identifiers
    public let exportedTypes: [BundleTypeDeclaration]?

    /// Imported Type Identifiers
    public let importedTypes: [BundleTypeDeclaration]?

    enum CodingKeys: String, CodingKey {
        case urlTypes = "CFBundleURLTypes"
        case documentTypes = "CFBundleDocumentTypes"
        case exportedTypes = "UTExportedTypeDeclarations"
        case importedTypes = "UTImportedTypeDeclarations"
        case identifier = "CFBundleIdentifier"
        case name = "CFBundleName"
        case packageType = "CFBundlePackageType"
        case version = "CFBundleShortVersionString"
    }
}

public struct BundleURLType: Decodable {
    /// URL Identifier
    public let identifier: String
    /// URL Schemes
    public let schemes: [String]
    /// role
    public let role: BundleTypeRole?
    /// Icon File Name
    public let icon: String?

    enum CodingKeys: String, CodingKey {
        case role = "CFBundleTypeRole"
        case identifier = "CFBundleURLName"
        case schemes = "CFBundleURLSchemes"
        case icon = "CFBundleURLIconFile"
    }
}

public struct BundleDocumentType: Decodable {
    /// Document Type Name
    public let name: String?

    /// Icon File Name
    public let icon: String?

    /// Document Content Type Identifiers
    public let contentTypeIdentifiers: [String]?

    /// role
    public let role: BundleTypeRole?

    /// Handler rank
    public let handlerRank: LSHandlerRank?

    /// Cocoa NSDocument Class
    public let cocoaClass: String?

    enum CodingKeys: String, CodingKey {
        case name = "CFBundleTypeName"
        case icon = "CFBundleTypeIconFile"
        case contentTypeIdentifiers = "LSItemContentTypes"
        case role = "CFBundleTypeRole"
        case handlerRank = "LSHandlerRank"
        case cocoaClass = "NSDocumentClass"
    }
}

public enum LSHandlerRank: String, Decodable {
    case Default
    case owner = "Owner"
    case alternate = "Alternate"
    case none = "None"
}

public enum BundleTypeRole: String, Decodable {
    case editor = "Editor"
    case viewer = "Viewer"
    case shell = "Shell"
    case quickLookGenerator = "QuickLookGenerator"
    case none = "None"
}

public struct EquivalentTypes: Decodable {
    public let extensions: [String]?
    public let mimeTypes: [String]?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.extensions = try container
            .decodeIfPresent(OneOrMoreList.self, forKey: .extensions)?.values

        self.mimeTypes = try container
            .decodeIfPresent(OneOrMoreList.self, forKey: .mimeTypes)?.values
    }

    enum CodingKeys: String, CodingKey {
        case extensions = "public.filename-extension"
        case mimeTypes = "public.mime-type"
    }
}

public struct OneOrMoreList: Decodable {
    let values: [String]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            let singleValue = try container.decode(String.self)
            self.values = [singleValue]
        } catch {
            self.values = try container.decode([String].self)
        }
    }
}

public struct BundleTypeDeclaration: Decodable {
    public let identifier: String?
    public let conformsToTypes: [String]?
    public let equivalentTypes: EquivalentTypes?
    public let referenceURL: String?
    public let description: String?
    public let icons: Icons?
    public let iconLegacy: String?

    public struct Icons: Decodable {
        public let backgroundName: String?
        public let badgeName: String?
        public let text: String?

        init(backgroundName: String?, badgeName: String?, text: String?) {
            self.backgroundName = backgroundName
            self.badgeName = badgeName
            self.text = text
        }

        enum CodingKeys: String, CodingKey {
            case backgroundName = "UTTypeIconBackgroundName"
            case badgeName = "UTTypeIconBadgeName"
            case text = "UTTypeIconText"
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container
            .decodeIfPresent(String.self, forKey: .identifier)
        self.conformsToTypes = try container
            .decodeIfPresent(OneOrMoreList.self, forKey: .conformsToTypes)?.values
        self.equivalentTypes = try container
            .decodeIfPresent(EquivalentTypes.self, forKey: .equivalentTypes)
        self.referenceURL = try container
            .decodeIfPresent(String.self, forKey: .referenceURL)
        self.description = try container
            .decodeIfPresent(String.self, forKey: .description)

        if container.contains(.icons) {
            let icon = try container
                .nestedContainer(keyedBy: Icons.CodingKeys.self, forKey: .icons)

            self.icons = if !icon.allKeys.isEmpty {
                try Icons(
                    backgroundName: icon.decodeIfPresent(String.self, forKey: .backgroundName),
                    badgeName: icon.decodeIfPresent(String.self, forKey: .badgeName),
                    text: icon.decodeIfPresent(String.self, forKey: .text)
                )
            } else {
                nil
            }
        } else {
            self.icons = nil
        }

        self.iconLegacy = try container
            .decodeIfPresent(String.self, forKey: .iconLegacy)
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "UTTypeIdentifier"
        case conformsToTypes = "UTTypeConformsTo"
        case equivalentTypes = "UTTypeTagSpecification"
        case referenceURL = "UTTypeReferenceURL"
        case description = "UTTypeDescription"
        case icons = "UTTypeIcons"
        case iconLegacy = "UTTypeIconFile"
    }
}
