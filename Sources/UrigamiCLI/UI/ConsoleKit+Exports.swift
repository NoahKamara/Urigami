//
//  ConsoleKit+Exports.swift
//
//  Copyright © 2024 Noah Kamara.
//

import ConsoleKitTerminal

typealias ConsoleText = ConsoleKitTerminal.ConsoleText
typealias Terminal = ConsoleKitTerminal.Terminal

extension ConsoleText {
    mutating func appendLine(_ value: ConsoleRepresentable) {
        self.appendLine(value.consoleRepresentation())
    }

    mutating func appendLine(_ text: ConsoleText) {
        fragments.append(.init(string: "\n"))
        fragments
            .append(contentsOf: text.consoleRepresentation().fragments)
    }
}

extension [ConsoleText] {
    func joined(separator: ConsoleText = "") -> ConsoleText {
        guard let first else {
            return ""
        }

        return dropFirst().reduce(first) { $0 + separator + $1 }
    }
}

extension ConsoleText.StringInterpolation {
    mutating func appendInterpolation(_ value: ConsoleRepresentable) {
        let text = value.consoleRepresentation()
        fragments.append(contentsOf: text.fragments)
    }

    mutating func appendInterpolation(value: ConsoleRepresentable) {
        let text = value.consoleRepresentation()
        fragments.append(contentsOf: text.fragments)
    }

    mutating func appendInterpolation(
        _ optional: String?,
        style: ConsoleStyle = .value
    ) {
        if let value = optional {
            appendLiteral("'")
            self.appendInterpolation(value, style: style)
            appendLiteral("'")
        } else {
            self.appendInterpolation("None", style: style)
        }
    }
}

extension ConsoleStyle {
    static let tip = ConsoleStyle(
        color: .brightBlue,
        isBold: false
    )
}

extension Console {
    func hint(_ text: String, newLine: Bool = true) {
        output(
            ("[i] " + text).consoleText(.tip),
            newLine: newLine
        )
    }
}
