//
//  File.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//


enum InputKind {
    case uri
    case mime
    case fileExtension
    case identifier
    
    var displayName: String {
        switch self {
        case .uri: "uri scheme"
        case .mime: "mime type"
        case .fileExtension: "file extension"
        case .identifier: "type identifier"
        }
    }
    
    init?(forInput input: String) {
        if input.isFileExtension() {
            self = .fileExtension
        } else if input.isURI() {
            self = .uri
        } else if input.isMimeType() {
            self = .mime
        } else if input.isUniformTypeIdentifier() {
            self = .identifier
        } else {
            return nil
        }
    }
}

fileprivate extension String {
    /// checks the string conforms to the format of a uniform type identifier
    ///
    /// > The identifier must contain only alphanumeric characters (a–z, A–Z, and 0–9), hyphens (-), and periods (.). For example, you might use com.example.greatAppDocument or com.example.greatApp-document for the
    /// > [Apple Documentation](https://developer.apple.com/documentation/uniformtypeidentifiers/defining-file-and-data-types-for-your-app)
    func isUniformTypeIdentifier() -> Bool {
        wholeMatch(of: /[\w,\d][\w,\d,\-,\.]*/) != nil
    }
    
    func isMimeType() -> Bool {
        wholeMatch(of: /[^\/]+\/[^\/]+?$/) != nil
    }
    
    func isURI() -> Bool {
        prefixMatch(of: /\w[\w,\d,\+,-,\.]*?:\/{0,2}/) != nil
    }
    
    func isFileExtension() -> Bool {
        starts(with: ".")
    }
}

