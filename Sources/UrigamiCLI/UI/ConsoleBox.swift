//
//  ConsoleBox.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//

import ConsoleKitTerminal
import Foundation
import UrigamiKit

struct ConsoleBox: ConsoleRepresentable {
    let style: ConsoleBoxStyle
    let content: ConsoleText
    let decorations: [Corner: String]

    init(
        style: ConsoleBoxStyle,
        decorations: [Corner: String] = [:],
        content: ConsoleText
    ) {
        self.style = style
        self.decorations = decorations
        self.content = content
    }

    func consoleRepresentation(width: Int? = nil) -> ConsoleText {
        let undecoratedContentLines = content
            .lines()

        var maxContentWidth = width.map { $0 - 4 } ?? undecoratedContentLines
            .map { $0.fragments.reduce(0) { $0 + $1.string.count } }
            .reduce(0, max)

        let topLineWidth = [Corner.bottomLeft, .bottomRight]
            .compactMap { decorations[$0]?.count }
            .reduce(0, +)

        let bottomLineWidth = [Corner.topLeft, .topRight]
            .compactMap { decorations[$0]?.count }
            .reduce(0, +)

        maxContentWidth = max(
            maxContentWidth,
            [bottomLineWidth, topLineWidth].max() ?? maxContentWidth
        )

        let contentLines = undecoratedContentLines
            .map {
                style.decorate(line: $0, contentWidth: maxContentWidth)
            }

        let boxWidth = maxContentWidth + 4

        let headerLine = style.top(
            contentWidth: boxWidth,
            leftDeco: decorations[.topLeft],
            rightDeco: decorations[.topRight]
        )

        let footerLine = style.bottom(
            contentWidth: boxWidth,
            leftDeco: decorations[.bottomLeft],
            rightDeco: decorations[.bottomRight]
        )

        let outputFragments: [ConsoleText] = ([headerLine] + contentLines + [footerLine])

        return outputFragments.joined(separator: "\n")
    }

    func consoleRepresentation() -> ConsoleText {
        consoleRepresentation(width: nil)
    }
}

enum Corner {
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
}

// MARK: Box Drawing Symbols

struct BoxDrawingSymbols {
    let horizontal: String
    let vertical: String
    let topLeft: String
    let topRight: String
    let bottomRight: String
    let bottomLeft: String

    let horizontalLeftHalf: String
    let horizontalRightHalf: String

    init(
        horizontal: String,
        vertical: String,
        horizontalLeftHalf: String?,
        horizontalRightHalf: String?,
        topLeft: String,
        topRight: String,
        bottomRight: String,
        bottomLeft: String
    ) {
        self.horizontal = horizontal
        self.vertical = vertical
        self.horizontalLeftHalf = horizontalLeftHalf ?? horizontal
        self.horizontalRightHalf = horizontalRightHalf ?? horizontal
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }

    static let lightHorizontal: String = "─"
    static let lightVertical: String = "│"

    static let arc = BoxDrawingSymbols(
        horizontal: lightHorizontal,
        vertical: lightVertical,
        horizontalLeftHalf: "╴",
        horizontalRightHalf: "╶",
        topLeft: "╭",
        topRight: "╮",
        bottomRight: "╯",
        bottomLeft: "╰"
    )
}

// MARK: Styles

extension ConsoleStyle {
    static let value = ConsoleStyle(color: .green, isBold: true)
}

// MARK: ConsoleBoxStyle

@dynamicMemberLookup
struct ConsoleBoxStyle {
    let style: ConsoleStyle
    let symbols: BoxDrawingSymbols

    init(
        symbols: BoxDrawingSymbols,
        style: ConsoleStyle = .info
    ) {
        self.style = style
        self.symbols = symbols
    }

    subscript(dynamicMember keyPath: KeyPath<BoxDrawingSymbols, Character>) -> Character {
        symbols[keyPath: keyPath]
    }
}

private extension ConsoleBoxStyle {
    func hLine(
        width: Int,
        leftDeco: String?,
        rightDeco: String?
    ) -> String {
        let leftDeco = leftDeco
            .map { symbols.horizontalLeftHalf + $0 + symbols.horizontalRightHalf } ?? ""

        let rightDeco = rightDeco
            .map { symbols.horizontalLeftHalf + $0 + symbols.horizontalRightHalf } ?? ""

        let contentWidth = width - (leftDeco.count + rightDeco.count)
        let line = String(repeating: symbols.horizontal, count: contentWidth)

        return leftDeco + line + rightDeco
    }

    func top(
        contentWidth: consuming Int,
        leftDeco: String?,
        rightDeco: String?
    ) -> ConsoleText {
        let line = hLine(
            width: contentWidth,
            leftDeco: leftDeco,
            rightDeco: rightDeco
        )

        return ConsoleText(fragments: [
            ConsoleTextFragment(
                string: symbols.topLeft + line + symbols.topRight,
                style: style
            ),
        ])
    }

    func bottom(
        contentWidth: consuming Int,
        leftDeco: String?,
        rightDeco: String?
    ) -> ConsoleText {
        let line = hLine(
            width: contentWidth,
            leftDeco: leftDeco,
            rightDeco: rightDeco
        )

        return ConsoleText(fragments: [
            ConsoleTextFragment(
                string: symbols.bottomLeft + line + symbols.bottomRight,
                style: style
            ),
        ])
    }

    func decorate(line: ConsoleText, contentWidth: Int) -> ConsoleText {
        var fragments = [
            ConsoleTextFragment(string: symbols.vertical + " ", style: style),
        ]

        var cursor = 0
        var lineFragments = line.fragments.makeIterator()

        while cursor < contentWidth, let content = lineFragments.next() {
            defer { cursor += content.string.count }
            if cursor + content.string.count < contentWidth {
                fragments.append(content)
            } else {
                fragments.append(.init(
                    string: String(content.string.prefix(contentWidth)),
                    style: content.style
                ))
            }
        }

        if 2 + contentWidth > cursor {
            fragments.append(
                .init(string: String(repeating: " ", count: 2 + contentWidth - cursor))
            )
        }

        fragments.append(ConsoleTextFragment(string: " " + symbols.vertical, style: style))
        return .init(fragments: fragments)
    }
}

extension ConsoleText {
    func lines() -> [ConsoleText] {
        var lines: [ConsoleText] = []
        var currentLine = ConsoleText()

        for fragment in fragments {
            let substrings = fragment.string.split(separator: "\n", omittingEmptySubsequences: false)

            for (index, substring) in substrings.enumerated() {
                currentLine.fragments.append(ConsoleTextFragment(string: String(substring), style: fragment.style))

                if index < substrings.count - 1 {
                    lines.append(currentLine)
                    currentLine = ConsoleText()
                }
            }
        }

        if !currentLine.fragments.isEmpty {
            lines.append(currentLine)
        }

        return lines
    }
}
