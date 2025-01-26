//
//  AppInfoCommand.swift
//  urigami
//
//  Created by Noah Kamara on 26.01.2025.
//

import ArgumentParser
import Foundation
import UrigamiKit

struct AppInfoCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "appinfo",
        abstract: "Get information about an installed application"
    )

    @Argument
    var nameOrPath: String

    @OptionGroup(title: "Configure which details to show")
    var detailOptions: AppDetailSectionOptions

    func run() throws {
        let console = Terminal()

        let apps = Application.find(nameOrPath)

        guard !apps.isEmpty else {
            console.error("Found no app '\(nameOrPath)'. \n try a relative or absolute path")
            return
        }

        if apps.count == 1 {
            let app = apps[0]
            let detailOptions = detailOptions.options

            try console.output(app.detail(detailOptions))
        } else {
            console.warning("Found multiple possible matches for '\(nameOrPath)'. \n try a relative or absolute path to be more precise")
            for app in apps {
                try console.output(app.detail(.none))
            }
        }
    }
}

struct AppDetailSectionOptions: ParsableArguments {
    @Flag(help: .init("all details", discussion: "equivalent to specifying all detail flags"))
    var detail = false

    @Flag(help: .init("declared types", discussion: "equivalent to specify --exported-utis and --imported-utis"))
    var uti = false

    @Flag(help: "exported ut-types")
    var exportUTI = false

    @Flag(help: "imported ut-types")
    var importUTI = false

    @Flag(name: .long, help: "document types")
    var doc = false

    @Flag(help: "declared URL types")
    var url = false

    var options: AppDetailSections {
        var options = AppDetailSections()

        if detail {
            return AppDetailSections.all
        }

        if uti { options.insert(.types) }
        else if exportUTI { options.insert(.exportedTypes) }
        else if importUTI { options.insert(.importedTypes) }

        if doc { options.insert(.documents) }

        if url { options.insert(.urls) }

        return options
    }
}
