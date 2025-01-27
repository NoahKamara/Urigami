//
//  ConsoleBox.swift
//
//  Copyright © 2024 Noah Kamara.
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
        let undecoratedContentLines = self.content
            .lines()

        var maxContentWidth = width.map { $0 - 4 } ?? undecoratedContentLines
            .map { $0.fragments.reduce(0) { $0 + $1.string.count } }
            .reduce(0, max)

        let topLineWidth = [Corner.bottomLeft, .bottomRight]
            .compactMap { self.decorations[$0]?.count }
            .reduce(0, +)

        let bottomLineWidth = [Corner.topLeft, .topRight]
            .compactMap { self.decorations[$0]?.count }
            .reduce(0, +)

        maxContentWidth = max(
            maxContentWidth,
            [bottomLineWidth, topLineWidth].max() ?? maxContentWidth
        )

        let contentLines = undecoratedContentLines
            .map {
                self.style.decorate(line: $0, contentWidth: maxContentWidth)
            }

        let boxWidth = maxContentWidth + 4

        let headerLine = self.style.top(
            contentWidth: boxWidth,
            leftDeco: self.decorations[.topLeft],
            rightDeco: self.decorations[.topRight]
        )

        let footerLine = self.style.bottom(
            contentWidth: boxWidth,
            leftDeco: self.decorations[.bottomLeft],
            rightDeco: self.decorations[.bottomRight]
        )

        let outputFragments: [ConsoleText] = ([headerLine] + contentLines + [footerLine])

        return outputFragments.joined(separator: "\n")
    }

    func consoleRepresentation() -> ConsoleText {
        self.consoleRepresentation(width: nil)
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
        self.symbols[keyPath: keyPath]
    }
}

private extension ConsoleBoxStyle {
    func hLine(
        width: Int,
        leftDeco: String?,
        rightDeco: String?
    ) -> String {
        let leftDeco = leftDeco
            .map { self.symbols.horizontalLeftHalf + $0 + self.symbols.horizontalRightHalf } ?? ""

        let rightDeco = rightDeco
            .map { self.symbols.horizontalLeftHalf + $0 + self.symbols.horizontalRightHalf } ?? ""

        let contentWidth = width - (leftDeco.count + rightDeco.count)
        let line = String(repeating: symbols.horizontal, count: contentWidth)

        return leftDeco + line + rightDeco
    }

    func top(
        contentWidth: consuming Int,
        leftDeco: String?,
        rightDeco: String?
    ) -> ConsoleText {
        let line = self.hLine(
            width: contentWidth,
            leftDeco: leftDeco,
            rightDeco: rightDeco
        )

        return ConsoleText(fragments: [
            ConsoleTextFragment(
                string: self.symbols.topLeft + line + self.symbols.topRight,
                style: self.style
            ),
        ])
    }

    func bottom(
        contentWidth: consuming Int,
        leftDeco: String?,
        rightDeco: String?
    ) -> ConsoleText {
        let line = self.hLine(
            width: contentWidth,
            leftDeco: leftDeco,
            rightDeco: rightDeco
        )

        return ConsoleText(fragments: [
            ConsoleTextFragment(
                string: self.symbols.bottomLeft + line + self.symbols.bottomRight,
                style: self.style
            ),
        ])
    }

    func decorate(line: ConsoleText, contentWidth: Int) -> ConsoleText {
        var fragments = [
            ConsoleTextFragment(string: symbols.vertical + " ", style: self.style),
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

        fragments.append(ConsoleTextFragment(
            string: " " + self.symbols.vertical,
            style: self.style
        ))
        return .init(fragments: fragments)
    }
}

extension ConsoleText {
    func lines() -> [ConsoleText] {
        var lines: [ConsoleText] = []
        var currentLine = ConsoleText()

        for fragment in fragments {
            let substrings = fragment.string.split(
                separator: "\n",
                omittingEmptySubsequences: false
            )

            for (index, substring) in substrings.enumerated() {
                currentLine.fragments.append(ConsoleTextFragment(
                    string: String(substring),
                    style: fragment.style
                ))

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
