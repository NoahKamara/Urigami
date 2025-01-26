//
//  File 2.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//

import ConsoleKitTerminal

protocol ConsoleRepresentable {
    consuming func consoleRepresentation() -> ConsoleText
}

extension ConsoleText: ConsoleRepresentable {
    func consoleRepresentation() -> ConsoleText { self }
}

extension Console {
    func output(_ content: some ConsoleRepresentable, newLine: Bool) {
        self.output(content.consoleRepresentation(), newLine: newLine)
    }
    
    func output(_ content: some ConsoleRepresentable) {
        self.output(content.consoleRepresentation())
    }
}
