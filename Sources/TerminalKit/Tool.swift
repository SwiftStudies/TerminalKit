//
//  Application.swift
//  TerminalKit
//
//
import Foundation

public enum ExitCode {
    case success
    case failed(reason:String)
    case customFailure(code:Int, reason:String)
    
    public func exit(){
        switch self {
        case .success:
            Darwin.exit(EXIT_SUCCESS)
        case .failed(let reason):
            print(reason)
            Darwin.exit(EXIT_FAILURE)
        case .customFailure(let code, let reason):
            print(reason)
            Darwin.exit(Int32(code))
        }
    }
}

public struct Tool {
    let name : String
    let version : String
    let description : String
    let commands : [Command]
    
    public init(_ name:String, version:String, description:String, commands:[Command]){
        assert(commands.count > 0)
        self.name = name
        self.version = version
        self.description = description
        self.commands = commands
    }
    
    public func run(_ arguments:[String]) throws {
        var arguments = arguments
        
        if !arguments.isEmpty {
            for command in commands {
                if command.name == arguments[0] {
                    try command.execute(arguments: [String](arguments.dropFirst()), commandPath: [name]).exit()
                }
            }
        }
        
        try commands[0].execute(arguments: arguments, commandPath: [name]).exit()
    }
    
    public func usage(for command:Command? = nil, with path:[String])->String{
        let command = command ?? commands[0]
        return command.usage(command: path)
    }
}
