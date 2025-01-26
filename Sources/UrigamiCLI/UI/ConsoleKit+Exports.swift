//
//  File.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//

import ConsoleKitTerminal

typealias ConsoleText = ConsoleKitTerminal.ConsoleText
typealias Terminal = ConsoleKitTerminal.Terminal

extension ConsoleText {
    mutating func appendLine(_ value: ConsoleRepresentable) {
        self.appendLine(value.consoleRepresentation())
    }
    
    mutating func appendLine(_ text: ConsoleText) {
        self.fragments.append(.init(string: "\n"))
        self.fragments
            .append(contentsOf: text.consoleRepresentation().fragments)
    }
}

extension [ConsoleText] {
    func joined(separator: ConsoleText = "") -> ConsoleText {
        guard let first else {
            return ""
        }
        
        return dropFirst().reduce(first, { $0 + separator + $1 })
    }
}

extension ConsoleText.StringInterpolation {
    mutating func appendInterpolation(_ value: ConsoleRepresentable) {
        let text = value.consoleRepresentation()
        self.fragments.append(contentsOf: text.fragments)
    }
    
    mutating func appendInterpolation(value: ConsoleRepresentable) {
        let text = value.consoleRepresentation()
        self.fragments.append(contentsOf: text.fragments)
    }
    
    mutating func appendInterpolation(
        _ optional: String?,
        style: ConsoleStyle = .value
    ) {
        if let value = optional {
            self.appendLiteral("'")
            self.appendInterpolation(value, style: style)
            self.appendLiteral("'")
        } else {
            self.appendInterpolation("None", style: style)
        }
    }
}
