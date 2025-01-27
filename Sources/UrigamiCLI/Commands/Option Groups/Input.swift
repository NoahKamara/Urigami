//
//  Input.swift
//
//  Copyright © 2024 Noah Kamara.
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
            throw ValidationError("'\(self.input)' isn't a valid input")
        }

        self.kind = kind
    }
}
