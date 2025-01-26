// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import AppKit
import Foundation
import UniformTypeIdentifiers

@main
struct UrigamiCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "urigami",
        abstract: "a command line utility for getting or setting default apps",
        version: "0.1.0",
        shouldDisplay: true,
        subcommands: [
            InfoCommand.self,
            AppCommand.self
        ]
//        defaultSubcommand: <#T##ParsableCommand#>,
//        helpNames: <#T##NameSpecification?#>
    )
    
    mutating func run() throws {
//        let workspace = NSWorkspace.shared
        
//        UTType(filenameExtension: <#T##String#>)
//        UTType(mimeType: <#T##String#>)
//        
//        UTType(String)
//        workspace.urlForApplication(toOpen: <#T##URL#>)
        print("Hello, world!")
    }
}




                        


//-d uti             display the default handler for uti and exit.
//
//-h                 print usage and exit.
//
//-l uti             display all handlers for uti and exit.
//
//-s                 set the handler from data provided on the command line.
//
//-V                 print version number and exit.
//
//-v                 verbose output.
//
//-x ext             print information describing the default application for extension ext.
