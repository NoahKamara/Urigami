//
//  Input.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//

import ArgumentParser

struct Input: ParsableArguments {
    @Argument(
        help: .init(
            "uri, mime type, extension or type identifier",
            discussion: """
            can be one of:
            - uri:        a uri starting with a scheme 'scheme:{optional rest}'
            - mime type:  a mime type like 'application/json'
            - file extension:  a mime type like 'application/json'
            - type identifier:  a mime type like 'application/json'
            """
        )
    )
    var input: String
    var kind: InputKind? = nil

    enum CodingKeys: CodingKey {
        case input
    }

    mutating func validate() throws {
        guard let kind = InputKind(forInput: input) else {
            throw ValidationError("'\(input)' isn't a valid input")
        }

        self.kind = kind
    }
}
